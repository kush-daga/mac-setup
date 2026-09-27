# ═══════════════════════════════════════════════════════════════════════
#  Prompt — pure zsh. No starship, no framework, no fork to draw it.
#
#  Two properties that matter:
#
#  1. The path adapts to the pane width. starship's [directory] truncates to
#     a fixed number of components, so a narrow split and a full-width
#     window both showed "…/api". This shows as much real path as fits
#     (see _smart_pwd below).
#
#  2. Git status is ASYNCHRONOUS. The prompt draws immediately; the git
#     segment arrives a moment later and the line is redrawn. A slow
#     `git status` can therefore never hold the terminal.
#
#  Deliberately minimal: path, branch, git status, a caret that turns red on
#  a non-zero exit, and a duration in RPROMPT for anything over 2s. Nothing
#  else (no language versions, no cloud context): each of those cost either
#  a fork or attention.
#
#  Colours are written by `theme` into $XDG_CONFIG_HOME/prompt-theme.zsh.
# ═══════════════════════════════════════════════════════════════════════

zmodload zsh/datetime
autoload -Uz add-zsh-hook

# Deliberately NOT setopt PROMPT_SUBST. The prompt is assembled in precmd, so
# nothing needs late expansion — and with it on, a stash count of "$16" got
# expanded as positional parameter 16 and vanished. Leaving it off also means
# RPROMPT can be a plain string instead of '$(...)', saving a fork per prompt.

# ── Palette. Defaults are TokyoNight Storm; `theme` overwrites them. ─────
typeset -g P_BG='#1f2335'   P_SURFACE='#292e42' P_OVERLAY='#3b4261'
typeset -g P_FG='#c0caf5'   P_MUTED='#565f89'   P_BLUE='#7aa2f7'
typeset -g P_TEAL='#2ac3de' P_GREEN='#9ece6a'   P_YELLOW='#e0af68'
typeset -g P_ORANGE='#ff9e64' P_RED='#f7768e'   P_PURPLE='#bb9af7'
[[ -r "$XDG_CONFIG_HOME/prompt-theme.zsh" ]] && source "$XDG_CONFIG_HOME/prompt-theme.zsh"

# ── Glyphs as escapes. Literal Nerd Font bytes get stripped by pipes and
#    editors, which silently leaves blank gaps in the prompt. ────────────
typeset -g P_CAP=$''    # left half circle
typeset -g P_SEP=$''    # solid right-pointing separator
typeset -g P_OS=$''     # apple
typeset -g P_BRANCH=$'' # git branch
typeset -g P_CLOCK=$''
typeset -g P_UP=$'⇡' P_DOWN=$'⇣'

# ═══════════════════════════════════════════════════════════════════════
#  Path: shortened, not truncated
#
#  Every parent directory collapses to the shortest prefix that is still
#  unique among its siblings — .spawnpoint becomes .sp only because nothing
#  else in that directory starts with ".sp". The result stays unambiguous
#  while taking a fraction of the width, and the last component is always
#  shown in full.
#
#  If even that does not fit the pane, whole components are dropped from the
#  left behind an ellipsis.
#
#  This touches the filesystem (one glob per parent), so the result is cached
#  against $PWD and $COLUMNS — it recomputes on cd or a resize, not per
#  prompt.
# ═══════════════════════════════════════════════════════════════════════
typeset -g SMART_PWD='' SMART_PWD_TAIL=''
typeset -g _P_PWD_KEY=''

# Shortest prefix of $2 that no OTHER directory in $1 also begins with.
# Result lands in $REPLY rather than stdout — $( ) would fork a subshell for
# every component of the path, which is the entire cost of this operation.
_p_uniq_prefix() {
  local parent=$1 name=$2
  local -a paths sibs
  paths=("$parent"/*(N/))
  sibs=("${paths[@]:t}")
  if (( ${#sibs} <= 1 )); then
    REPLY="${name[1,1]}"
    return
  fi

  local pre s
  local -i len hits
  for (( len = 1; len < ${#name}; len++ )); do
    pre="${name[1,len]}"
    hits=0
    for s in "${sibs[@]}"; do
      if [[ "$s" == "${pre}"* ]]; then
        (( ++hits > 1 )) && break
      fi
    done
    if (( hits <= 1 )); then
      REPLY="$pre"
      return
    fi
  done
  REPLY="$name"
}

_smart_pwd() {
  local key="$PWD:${COLUMNS:-80}"
  [[ "$key" == "$_P_PWD_KEY" ]] && return
  _P_PWD_KEY="$key"

  local disp=${PWD/#$HOME/\~}
  # Unquoted split drops empty fields, so a leading "/" does not produce a
  # phantom first component.
  local -a parts=(${(s:/:)disp})
  local -i n=${#parts}

  if (( n <= 1 )); then
    SMART_PWD=''; SMART_PWD_TAIL="$disp"
    return
  fi

  # Build the shortened head one component at a time. head starts as "~" for
  # a home-relative path and empty for an absolute one, so the "/" prepended
  # each iteration gives the right leading separator in both cases.
  local head='' abs=''
  local -i start=1
  if [[ "${parts[1]}" == '~' ]]; then
    head='~'; abs=$HOME; start=2
  fi
  local -i i
  local REPLY
  for (( i = start; i < n; i++ )); do
    abs="$abs/${parts[i]}"
    _p_uniq_prefix "${abs:h}" "${parts[i]}"
    head+="/$REPLY"
  done

  local tail="${parts[n]}"

  # Still too wide? Drop leading components until it fits.
  local -i budget=$(( ${COLUMNS:-80} - 34 ))
  (( budget < 16 )) && budget=16
  if (( ${#head} + ${#tail} + 1 > budget )); then
    local -a hp=("${(s:/:)head}")
    while (( ${#hp} > 1 && ${#head} + ${#tail} + 3 > budget )); do
      shift hp
      head="${(j:/:)hp}"
    done
    head="…/${head#/}"
  fi

  SMART_PWD="$head"
  SMART_PWD_TAIL="$tail"
}

# ═══════════════════════════════════════════════════════════════════════
#  Async git
# ═══════════════════════════════════════════════════════════════════════
typeset -g _P_GIT=''      # rendered segment; empty outside a repo
typeset -g _P_GIT_FD=0

# Find the repo root for a directory WITHOUT running git. Sets REPLY to the
# directory holding .git; returns non-zero when there is no repo above us.
#
# This replaced `git rev-parse --git-dir`, which was the most expensive thing
# in the prompt: it blocks until git exits. A bare `/usr/bin/true` costs
# ~9 ms on this machine, git ~12 ms warm, and Apple's /usr/bin/git shim
# spikes past 140 ms whenever its Xcode lookup falls out of cache — which is
# what the intermittent prompt stalls were. This walk is stat() only, 0.3 ms,
# and answers exactly the same question.
#
# A submodule or linked worktree has .git as a FILE, so test -e, not -d.
_p_repo_root() {
  local d=${1:-$PWD}
  while true; do
    [[ -e $d/.git ]] && { REPLY=$d; return 0 }
    [[ $d == / || -z $d ]] && return 1
    d=${d:h}
  done
}

# Background subshell, and now exactly ONE git process. --branch reports the
# branch name in the same output as the file counts, so `git symbolic-ref`
# was redundant; the stash count is a line count of a reflog file, so it does
# not need `git stash list | grep -c` either. Three execs became one.
_p_git_worker() {
  builtin cd -q "$1" 2>/dev/null || return
  local -i staged=0 modified=0 untracked=0 conflict=0 ahead=0 behind=0 stashed=0
  local head='' oid='' line ab
  while IFS= read -r line; do
    case "$line" in
      '# branch.head '*) head=${line#\# branch.head } ;;
      '# branch.oid '*)  oid=${line#\# branch.oid } ;;
      '# branch.ab '*)
        ab=${line#\# branch.ab }
        ahead=${${ab%% *}#+}
        behind=${${ab##* }#-}
        ;;
      '1 '*|'2 '*)
        [[ ${line:2:1} != '.' ]] && (( staged++ ))
        [[ ${line:3:1} != '.' ]] && (( modified++ ))
        ;;
      'u '*) (( conflict++ )) ;;
      '? '*) (( untracked++ )) ;;
    esac
  done < <(command git --no-optional-locks status --porcelain=v2 --branch 2>/dev/null)

  # No branch.head line means the status call failed — not a repo after all.
  [[ -z $head ]] && return
  # Detached HEAD reports the literal "(detached)"; show a short oid instead.
  [[ $head == '(detached)' ]] && head=${oid[1,7]}

  # Stash count straight off the reflog. refs/stash lives in the COMMON git
  # dir, which is not the gitdir of a linked worktree — hence the commondir
  # hop. A missing file just means no stashes. $(<file) does not fork in zsh.
  local REPLY gd raw
  if _p_repo_root; then
    gd=$REPLY/.git
    if [[ -f $gd ]]; then          # submodule/worktree: "gitdir: <path>"
      raw=$(<$gd); gd=${raw#gitdir: }
      [[ $gd != /* ]] && gd=$REPLY/$gd
    fi
    if [[ -r $gd/commondir ]]; then
      raw=$(<$gd/commondir)
      [[ $raw == /* ]] && gd=$raw || gd=$gd/$raw
    fi
    if [[ -r $gd/logs/refs/stash ]]; then
      local -a sl=( ${(f)"$(<$gd/logs/refs/stash)"} )
      stashed=${#sl}
    fi
  fi

  print -r -- "${head}|${staged}|${modified}|${untracked}|${conflict}|${ahead}|${behind}|${stashed}"
}

_p_git_render() {
  local -a f=("${(@s:|:)1}")
  if [[ -z "${f[1]}" ]]; then _P_GIT=''; return; fi
  local st=''
  (( f[2] )) && st+="%F{$P_GREEN}+${f[2]}%f "
  (( f[3] )) && st+="%F{$P_YELLOW}!${f[3]}%f "
  (( f[4] )) && st+="%F{$P_MUTED}?${f[4]}%f "
  (( f[5] )) && st+="%F{$P_RED}=${f[5]}%f "
  (( f[6] )) && st+="%F{$P_TEAL}${P_UP}${f[6]}%f "
  (( f[7] )) && st+="%F{$P_TEAL}${P_DOWN}${f[7]}%f "
  (( f[8] )) && st+="%F{$P_PURPLE}\$${f[8]}%f "
  _P_GIT="%F{$P_TEAL}${P_BRANCH} ${f[1]}%f ${st}"
}

# NOTE THE BRACES around exec. `exec {fd}<&- 2>/dev/null` looks like it
# silences one close, but exec WITHOUT a command applies its redirections to
# the shell itself and keeps them: that one line pointed this shell's stderr
# at /dev/null permanently, from the first prompt onward. Every error message
# from every command afterwards was written to /dev/null — invisible failures
# with no clue why. Wrapping it in { } scopes the redirection to the block,
# which still swallows a stale-fd complaint but leaves fd 2 on the terminal.
_p_git_close() {
  if (( _P_GIT_FD )); then
    zle -F $_P_GIT_FD 2>/dev/null
    { exec {_P_GIT_FD}<&- } 2>/dev/null
    _P_GIT_FD=0
  fi
}

_p_git_cb() {
  local fd=$1 line=''
  read -r -u $fd line 2>/dev/null
  zle -F $fd 2>/dev/null
  { exec {fd}<&- } 2>/dev/null    # braces: see _p_git_close above
  _P_GIT_FD=0
  _p_git_render "$line"
  _p_build
  zle reset-prompt 2>/dev/null
}

_p_git_start() {
  _p_git_close
  # Gate: outside a repo, never spawn a worker. Pure stat walk, no subprocess.
  # GIT_DIR set means git works regardless of where we stand, so honour it.
  local REPLY
  if [[ -z $GIT_DIR ]] && ! _p_repo_root; then
    _P_GIT=''
    return
  fi
  exec {_P_GIT_FD}< <( _p_git_worker "$PWD" )
  zle -F $_P_GIT_FD _p_git_cb
}

# ═══════════════════════════════════════════════════════════════════════
#  Command duration — from EPOCHREALTIME, so it costs no forks
# ═══════════════════════════════════════════════════════════════════════
typeset -g _P_START=0 _P_DUR=''
_p_preexec_dur() { _P_START=$EPOCHREALTIME }
_p_duration() {
  _P_DUR=''
  (( _P_START == 0 )) && return
  local -F el=$(( EPOCHREALTIME - _P_START ))
  _P_START=0
  (( el < 2 )) && return          # only worth showing when you noticed the wait
  # Assigning arithmetic to an integer-declared variable truncates. Do NOT
  # use int() here: zsh's math functions live in the zsh/mathfunc module, and
  # without it this raises "unknown function: int" — which only surfaced on
  # commands slower than the 2s threshold above.
  local -i t
  (( t = el ))
  if (( t < 60 )); then
    _P_DUR="${t}s"
  elif (( t < 3600 )); then
    _P_DUR="$(( t / 60 ))m $(( t % 60 ))s"
  else
    _P_DUR="$(( t / 3600 ))h $(( (t % 3600) / 60 ))m"
  fi
}

# ═══════════════════════════════════════════════════════════════════════
#  Assembly — flat, no powerline blocks. The shortened parents sit in a
#  recessed colour and the current directory is bright, so the eye lands on
#  where you are without losing the path that got you there.
# ═══════════════════════════════════════════════════════════════════════
_p_build() {
  local p="%F{$P_BLUE}${P_DIR} %f"
  [[ -n "$SMART_PWD" ]] && p+="%F{$P_MUTED}${SMART_PWD}/%f"
  p+="%B%F{$P_FG}${SMART_PWD_TAIL}%f%b"
  [[ -n "$_P_GIT" ]] && p+="  ${_P_GIT}"
  p+=$'\n'"%(?.%F{$P_GREEN}.%F{$P_RED})"$'❯'"%f "
  PROMPT="$p"
  # Built with an if, not ${x:+...}: the brace in %F{...} would close the
  # parameter expansion early and leak a literal "}" into the prompt.
  if [[ -n "$_P_DUR" ]]; then
    RPROMPT="%F{$P_MUTED}${_P_DUR}%f"
  else
    RPROMPT=''
  fi
}

_p_precmd() {
  _p_duration
  _smart_pwd
  _p_git_start
  _p_build
}
add-zsh-hook precmd _p_precmd
add-zsh-hook preexec _p_preexec_dur

# ═══════════════════════════════════════════════════════════════════════
#  Transient prompt
#
#  Once a command has been submitted, its prompt has done its job — and a
#  full path repeated above every result turns scrollback into noise. On
#  accept-line the prompt collapses to a bare caret, so only the CURRENT
#  prompt carries the path and git state. History stays readable: you still
#  see every command you ran, just without the banner above it.
# ═══════════════════════════════════════════════════════════════════════
_p_accept_line() {
  PROMPT="%F{$P_MUTED}"$'❯'"%f "
  RPROMPT=''
  zle reset-prompt
  zle .accept-line
}
zle -N accept-line _p_accept_line

_p_build
