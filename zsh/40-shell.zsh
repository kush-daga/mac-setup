# ═══════════════════════════════════════════════════════════════════════
#  Aliases and functions
#  Everything you type. `als <word>` searches aliases;
#  `zwhere <name>` prints the file and line that defines anything.
# ═══════════════════════════════════════════════════════════════════════

# ── Listing (eza) ────────────────────────────────────────────────────────
alias ls='eza --icons --group-directories-first'
alias l='eza -lbF --icons --group-directories-first --git'
alias ll='eza -lbGF --icons --group-directories-first --git --time-style=long-iso'
alias la='eza -lbhHigUmuSa --icons --group-directories-first --git --time-style=long-iso'
alias lt='eza --tree --level=2 --icons --group-directories-first'
alias lt3='eza --tree --level=3 --icons --group-directories-first'
alias ltg='eza --tree --level=3 --icons --git-ignore --group-directories-first'
alias lsd='eza -D --icons'                     # directories only
alias lsn='eza -lbF --icons --sort=newest'     # newest last
alias lss='eza -lbF --icons --sort=size'       # biggest last

# ── Reading files ────────────────────────────────────────────────────────
alias cat='bat --paging=never'
alias catp='bat -pp'                           # plain: no line numbers, no border
alias rcat='command cat'                       # the real cat, for piping
alias md='glow -p'                             # render markdown, paged
alias jsonl='jq -C . | less -R'
alias -g B='| bat --paging=always'             # global: `cmd B` pipes to bat
alias -g L='| less -R'
alias -g G='| rg'
alias -g J='| jq -C .'
alias -g C='| pbcopy'
alias -g NE='2>/dev/null'
alias -g N='>/dev/null 2>&1'

# ── Navigation ───────────────────────────────────────────────────────────
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'
alias -- -='cd -'
alias dl='cd ~/Downloads'
alias dev='cd ~/Developer'
alias dots='cd ~/.dotfiles'
alias cfg='cd ~/.config'

# ── Search ───────────────────────────────────────────────────────────────
alias rg='rg --smart-case --hidden --glob=!.git'
alias rgf='rg --files'
alias rgl='rg --smart-case --hidden --glob=!.git --files-with-matches'
alias grep='grep --color=auto'
alias ff='fd --type f --hidden --exclude .git'  # find file
alias fdir='fd --type d --hidden --exclude .git'

# ── Git ──────────────────────────────────────────────────────────────────
# oh-my-zsh's git plugin is vendored into zsh/vendor/omz-git.zsh: all 196
# aliases and 12 functions (ggpull, ggpush, ggl, gbda, grename, gccd, gdv…),
# with no framework and no oh-my-zsh install required. Sourced first so the
# overrides below win.
source "$DOTFILES/zsh/vendor/omz-git.zsh"

# ── Overrides and additions on top of the vendored set ───────────────────
# `gg`: omz maps this to `git gui citool`, a Tk app that is effectively dead
# on modern macOS. lazygit is what it should have been.
alias gg='lazygit'
alias lzd='lazydocker'

# Names omz leaves free — no collisions, nothing shadowed.
alias gs='git status --short --branch'
alias gdft='git difftool'                  # structural diff via difftastic
alias gblame='git blame -w -C -C -C'       # ignore whitespace AND moved code
alias glga='git log --oneline --graph --decorate --all -30'
alias gcamend='git commit --verbose --amend'
alias gabs='git absorb --and-rebase'       # fold fixups into the right commits
alias gundo='git reset --soft HEAD~1'      # drop the commit, keep the changes
alias gnuke='git reset --hard HEAD && git clean -fd'

# ── GitHub CLI ───────────────────────────────────────────────────────────
alias ghpr='gh pr create --fill'
alias ghprv='gh pr view --web'
alias ghprc='gh pr checks --watch'
alias ghprl='gh pr list --limit 20'
alias ghrun='gh run watch'

# ── Editor ───────────────────────────────────────────────────────────────
alias v='nvim'
alias vi='nvim'
alias vim='nvim'
alias nv='nvim'
alias vz='nvim ~/.zshrc'
alias vd='cd ~/.dotfiles && nvim .'
alias vg='nvim ~/.dotfiles/ghostty/config'
alias vn='nvim ~/.dotfiles/nvim/init.lua'

# ── System ───────────────────────────────────────────────────────────────
alias top='btop'
alias htop='btop'
alias ps='procs'
alias du='dust'
alias df='duf'
alias t='tldr'
alias ports='lsof -iTCP -sTCP:LISTEN -n -P'
alias myip='curl -s https://checkip.amazonaws.com'
alias localip="ipconfig getifaddr en0"
alias path='echo -e ${PATH//:/\\n}'
alias reload='exec zsh'
alias timezsh='for i in 1 2 3; do /usr/bin/time -p zsh -i -c exit; done'
alias profzsh='ZSH_PROFILE=1 zsh -i -c exit'

# ── Safety nets ──────────────────────────────────────────────────────────
alias cp='cp -iv'
alias mv='mv -iv'
alias rm='rm -Iv'                              # prompt once for 3+ files
alias mkdir='mkdir -pv'
alias ln='ln -iv'
alias chmod='chmod -v'
alias chown='chown -v'

# ── Homebrew ─────────────────────────────────────────────────────────────
alias bi='brew install'
alias bic='brew install --cask'
alias bu='brew update && brew upgrade && brew cleanup'
alias bs='brew search'
alias binfo='brew info'
alias bdump='brew bundle dump --force --describe --file=~/.dotfiles/Brewfile'
alias bleaves='brew leaves'

# ── Package managers ─────────────────────────────────────────────────────
alias ni='npm install'
alias nr='npm run'
alias pn='pnpm'
alias pnr='pnpm run'
alias pni='pnpm install'
alias bx='bunx'
alias py='python3'
alias pip='pip3'
alias venv='python3 -m venv .venv && source .venv/bin/activate'
alias act='source .venv/bin/activate'
alias uvr='uv run'

# ── Docker ───────────────────────────────────────────────────────────────
alias dk='docker'
alias dkc='docker compose'
alias dkps='docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"'
alias dkclean='docker system prune -af --volumes'

# ── Claude Code ──────────────────────────────────────────────────────────
alias cl='claude'
alias clc='claude --continue'
alias clr='claude --resume'

# ── macOS ────────────────────────────────────────────────────────────────
alias o='open'
alias o.='open .'
alias finder='open -a Finder .'
alias flushdns='sudo dscacheutil -flushcache && sudo killall -HUP mDNSResponder'
alias showfiles='defaults write com.apple.finder AppleShowAllFiles YES && killall Finder'
alias hidefiles='defaults write com.apple.finder AppleShowAllFiles NO && killall Finder'
alias cleands='find . -name ".DS_Store" -delete'

# ── tmux ─────────────────────────────────────────────────────────────────
alias tm='tmux new-session -A -s main'         # attach-or-create
alias tma='tmux attach -t'
alias tml='tmux list-sessions'
alias tmk='tmux kill-session -t'
alias tmks='tmux kill-server'


# NOTE: a function cannot share a name with an existing alias — zsh raises
# "defining function based on alias" and the whole file stops parsing. The
# vendored omz git plugin defines 197 aliases before this file loads, so
# check with `alias <name>` before adding a function here.

# ── Directories ──────────────────────────────────────────────────────────

# mkcd <dir> — make it and go there.
mkcd() { mkdir -p "$1" && cd "$1"; }

# up [n] — climb n directories (default 1).
up() {
  local n=${1:-1} p=""
  for ((i = 0; i < n; i++)); do p="../$p"; done
  cd "$p" || return
}

# d [name] — jump into ~/Developer, or a project inside it.
d() { cd "$HOME/Developer/${1:-}"; }
_d() { _files -W "$HOME/Developer" -/; }
compdef _d d

# ── Files ────────────────────────────────────────────────────────────────

# c <file> — copy a file's contents to the clipboard.
c() {
  [[ -f "$1" ]] || { print -u2 "c: not a file: ${1:-<missing>}"; return 1; }
  pbcopy < "$1" && print "copied: $1 ($(wc -c < "$1" | tr -d ' ') bytes)"
}
_c() { _files }
compdef _c c

# backup <file> — file -> file.2026-08-21T14-03-11.bak
backup() {
  local f
  for f in "$@"; do cp -a "$f" "$f.$(date +%FT%H-%M-%S).bak" && print "backed up: $f"; done
}

# extract <archive> — one command for every archive format.
extract() {
  local f
  for f in "$@"; do
    [[ -f "$f" ]] || { print -u2 "extract: no such file: $f"; continue }
    case "$f" in
      *.tar.bz2|*.tbz2) tar xjf "$f" ;;
      *.tar.gz|*.tgz)   tar xzf "$f" ;;
      *.tar.xz|*.txz)   tar xJf "$f" ;;
      *.tar.zst)        tar --zstd -xf "$f" ;;
      *.tar)            tar xf "$f" ;;
      *.zip|*.jar)      unzip -q "$f" ;;
      *.gz)             gunzip "$f" ;;
      *.bz2)            bunzip2 "$f" ;;
      *.7z)             7zz x "$f" ;;
      *.rar)            unrar x "$f" ;;
      *.Z)              uncompress "$f" ;;
      *) print -u2 "extract: don't know how to open $f" ;;
    esac
  done
}

# y — yazi file manager; on quit, the shell follows you to the last directory.
y() {
  local tmp="$(mktemp -t yazi-cwd.XXXXXX)" cwd
  yazi "$@" --cwd-file="$tmp"
  if cwd="$(command cat -- "$tmp")" && [[ -n "$cwd" && "$cwd" != "$PWD" ]]; then
    builtin cd -- "$cwd"
  fi
  rm -f -- "$tmp"
}

# ── fzf-powered pickers ──────────────────────────────────────────────────

# f — fuzzy-find a file and open it in nvim (with a bat preview).
f() {
  local file
  file=$(fd --type f --hidden --exclude .git --exclude node_modules \
    | fzf --preview 'bat -n --color=always --line-range :400 {}' \
          --preview-window='right,60%' --prompt='open ❯ ') || return
  [[ -n "$file" ]] && nvim "$file"
}

# rgi [query] — live ripgrep across the repo; enter opens nvim at that line.
# This is the main way to read code without an editor open.
rgi() {
  local rg_cmd="rg --column --line-number --no-heading --color=always --smart-case --hidden --glob=!.git"
  fzf --ansi --disabled --query "${1:-}" \
      --bind "start:reload:$rg_cmd {q} || true" \
      --bind "change:reload:sleep 0.1; $rg_cmd {q} || true" \
      --delimiter : \
      --preview 'bat --color=always --highlight-line {2} --style=numbers {1}' \
      --preview-window 'right,60%,border-left,+{2}/3' \
      --prompt 'rg ❯ ' --header 'enter: open in nvim   ctrl-/: toggle preview' \
      --bind 'enter:become(nvim {1} +{2})'
}

# fkill — pick a process from a list and kill it.
fkill() {
  local pid
  pid=$(procs --no-header 2>/dev/null | fzf -m --header='select process(es) to kill' | awk '{print $1}')
  [[ -n "$pid" ]] && print "$pid" | xargs kill -${1:-15} && print "killed: $pid"
}

# fco — fuzzy-checkout a local or remote branch.
fco() {
  local branch
  branch=$(git branch --all --sort=-committerdate --format='%(refname:short)' \
    | sed 's#^origin/##' | awk '!seen[$0]++' \
    | fzf --preview 'git log --oneline --graph --color=always -20 {}' --prompt='branch ❯ ') || return
  [[ -n "$branch" ]] && git switch "$branch" 2>/dev/null || git switch -c "$branch" "origin/$branch"
}

# fshow — browse git history; enter shows the full patch through delta.
fshow() {
  git log --color=always --format='%C(auto)%h %C(blue)%ad %C(green)%an%C(auto)%d %s' --date=short "$@" \
    | fzf --ansi --no-sort --reverse --prompt='commit ❯ ' \
          --preview 'git show --color=always {1} | delta' \
          --preview-window='right,60%,border-left' \
          --bind 'enter:execute(git show --color=always {1} | delta | less -R)'
}

# fenv — search environment variables.
fenv() { env | sort | fzf --prompt='env ❯ ' --preview 'echo {}' --preview-window='down,3,wrap'; }

# zwhere <name> — where is this defined? Works for aliases, functions,
# exported variables, and files on PATH. Saves guessing which file to open.
zwhere() {
  local q=$1
  [[ -z "$q" ]] && { print -u2 "usage: zwhere <alias|function|VAR|command>"; return 1 }
  local -i found=0

  # zsh already tracks where every function was defined.
  if (( $+functions[$q] )); then
    local src=${functions_source[$q]}
    if [[ -n "$src" ]]; then
      local ln=$(command grep -n "^${q}()" "$src" 2>/dev/null | head -1 | cut -d: -f1)
      print -P "  %F{cyan}function%f  ${src/#$HOME/~}${ln:+:$ln}"
    else
      print -P "  %F{cyan}function%f  (autoloaded)"
    fi
    found=1
  fi

  # Aliases and exports need a grep across the config.
  local -a searched=("$DOTFILES"/.zshrc "$DOTFILES"/.zshenv "$DOTFILES"/zsh/[0-9]*.zsh \
                     "$DOTFILES"/zsh/vendor/*.zsh "$HOME/.zshrc.local")
  local f hit
  for f in $searched; do
    [[ -r "$f" ]] || continue
    hit=$(command grep -nE "^[[:space:]]*(alias|export|typeset|[a-zA-Z_]+=)[[:space:]]*${q}[=[:space:]]|^[[:space:]]*alias .*[[:space:]]${q}=" "$f" 2>/dev/null | head -2)
    if [[ -n "$hit" ]]; then
      print -r -- "$hit" | while IFS=: read -r n rest; do
        print -P "  %F{yellow}${f:t}%f:$n  ${rest##[[:space:]]#}"
      done
      found=1
    fi
  done

  if (( $+aliases[$q] )); then
    print -P "  %F{green}alias%f     $q='${aliases[$q]}'"
    found=1
  fi

  # Finally, a real command.
  if (( $+commands[$q] )); then
    print -P "  %F{blue}command%f   ${commands[$q]/#$HOME/~}"
    found=1
  fi

  (( found )) || { print -P "  %F{red}not found%f: $q"; return 1 }
}

# als [pattern] — search your own aliases.
als() {
  if [[ -n "$1" ]]; then alias | rg --smart-case "$1"
  else alias | fzf --prompt='alias ❯ ' --preview 'echo {}' --preview-window='down,3,wrap'
  fi
}

# ── Git helpers ──────────────────────────────────────────────────────────

# git_current_branch is the one helper the vendored omz git plugin expects
# but does not define itself (it lived in oh-my-zsh's lib/git.zsh).
# git_main_branch and git_develop_branch come from the plugin.
git_current_branch() {
  local ref
  ref=$(command git symbolic-ref --quiet HEAD 2>/dev/null) || return
  print "${ref#refs/heads/}"
}

# gclone <url> — clone into ~/Developer and cd in.
gclone() {
  local url="$1" name
  name=$(basename "$url" .git)
  git clone "$url" "$HOME/Developer/$name" && cd "$HOME/Developer/$name"
}

# groot — cd to the repository root.
groot() { cd "$(git rev-parse --show-toplevel 2>/dev/null || print .)"; }

# gprune — delete local branches whose remote is gone.
# (Named gprune, not gclean: omz's gclean is `git clean --interactive -d`.)
gprune() {
  git fetch --prune
  git branch -vv | rg ': gone]' | awk '{print $1}' | xargs -r git branch -D
}

# ── Utilities ────────────────────────────────────────────────────────────

# serve [port] — static HTTP server for the current directory.
serve() { python3 -m http.server "${1:-8000}"; }

# genpass [len] — random password to stdout and clipboard.
genpass() {
  local p; p=$(LC_ALL=C tr -dc 'A-Za-z0-9!@#$%^&*_+-' < /dev/urandom | head -c "${1:-32}")
  print "$p"; print -n "$p" | pbcopy; print -u2 "(copied to clipboard)"
}

# jsonf <file> — pretty-print and page a JSON file.
jsonf() { jq -C . "$1" | less -R; }

# man wrapper — render man pages through bat with syntax colouring.
mman() { man "$@" | bat -p -l man; }

# ── Diagnosing an intermittent slow prompt ───────────────────────────────
# Prompt latency here measures ~100ms, but an occasional multi-second stall
# is exactly the kind of thing a one-off benchmark misses. Turn this on and
# it times every prompt, logging only the slow ones with the directory and
# which hook was responsible. Survives until you turn it off.
#
#   prompt-watch on [threshold_ms]   default 400
#   prompt-watch off
#   prompt-watch log                 show what it caught
PROMPT_WATCH_LOG="$XDG_STATE_HOME/zsh/slow-prompts.log"

_prompt_watch_pre() { _PW_START=$EPOCHREALTIME }
_prompt_watch_post() {
  [[ -z "$_PW_START" ]] && return
  local ms=$(( (EPOCHREALTIME - _PW_START) * 1000 ))
  if (( ms > ${PROMPT_WATCH_MS:-400} )); then
    printf '%s  %7.0fms  %s\n' "$(date +%H:%M:%S)" "$ms" "$PWD" >> "$PROMPT_WATCH_LOG"
  fi
  unset _PW_START
}

prompt-watch() {
  [[ -d "${PROMPT_WATCH_LOG:h}" ]] || mkdir -p "${PROMPT_WATCH_LOG:h}"
  case "${1:-status}" in
    on)
      zmodload zsh/datetime
      export PROMPT_WATCH_MS="${2:-400}"
      # preexec fires before the command, precmd after — bracketing the gap.
      add-zsh-hook preexec _prompt_watch_pre 2>/dev/null
      add-zsh-hook precmd  _prompt_watch_post 2>/dev/null
      print "watching prompts slower than ${PROMPT_WATCH_MS}ms → ${PROMPT_WATCH_LOG/#$HOME/~}"
      print "reproduce the stall, then run: prompt-watch log"
      ;;
    off)
      add-zsh-hook -d preexec _prompt_watch_pre 2>/dev/null
      add-zsh-hook -d precmd  _prompt_watch_post 2>/dev/null
      print "stopped."
      ;;
    log)
      if [[ -s "$PROMPT_WATCH_LOG" ]]; then tail -40 "$PROMPT_WATCH_LOG"
      else print "nothing logged — no prompt exceeded the threshold."; fi
      ;;
    clear) : >| "$PROMPT_WATCH_LOG"; print "cleared." ;;
    *) print "usage: prompt-watch on [ms] | off | log | clear" ;;
  esac
}

# ── Dotfiles ─────────────────────────────────────────────────────────────

# cheat — print the keybinding and command reference.
cheat() {
  if [[ -r "$DOTFILES/CHEATSHEET.md" ]]; then glow -p "$DOTFILES/CHEATSHEET.md"
  else print -u2 "no cheatsheet at $DOTFILES/CHEATSHEET.md"; fi
}

# dotfiles-doctor — verify the hardcoded paths in 00-env.zsh still resolve.
# Run this after upgrading node, python, or asdf.
dotfiles-doctor() {
  local ok=0 bad=0
  _chk() {
    if [[ -e "$2" ]]; then print "  \e[32m✓\e[0m $1"; ((ok++))
    else print "  \e[31m✗\e[0m $1 → $2 \e[33m(missing)\e[0m"; ((bad++)); fi
  }
  print "\e[1mHardcoded paths\e[0m"
  _chk "node 24 (nvm)"   "$NVM_DIR/versions/node/v24.15.0/bin/node"
  _chk "asdf shims"      "$ASDF_DATA_DIR/shims"
  # Python user bin dirs are globbed, so "none yet" is fine — only a
  # *stale pinned* path would be a problem, and there is no longer one.
  local _pyb=("$HOME/Library/Python"/*/bin(N))
  if (( ${#_pyb} )); then print "  \e[32m✓\e[0m python user bin (${#_pyb} found)"; ((ok++))
  else print "  \e[90m·\e[0m python user bin (none installed — fine)"; fi
  _chk "go bin"          "$HOME/go/bin"
  _chk "java home"       "$JAVA_HOME"
  _chk "bun"             "$BUN_INSTALL/bin"
  _chk "pnpm"            "$PNPM_HOME"

  print "\n\e[1mSymlinks\e[0m"
  local l
  for l in ~/.zshrc ~/.zshenv ~/.gitconfig ~/.config/ghostty/config \
           ~/.config/nvim ~/.config/tmux/tmux.conf ~/.config/cmux/cmux.json; do
    if [[ -L "$l" ]]; then
      [[ -e "$l" ]] && print "  \e[32m✓\e[0m $l" || { print "  \e[31m✗\e[0m $l \e[33m(broken link)\e[0m"; ((bad++)); }
    else
      print "  \e[33m·\e[0m $l \e[33m(not a symlink)\e[0m"
    fi
  done

  print "\n\e[1mBinaries\e[0m"
  local t
  for t in nvim git lazygit fzf rg fd bat eza zoxide atuin delta glow yazi tmux gh jq btop tree-sitter; do
    (( $+commands[$t] )) && print "  \e[32m✓\e[0m $t" || { print "  \e[31m✗\e[0m $t"; ((bad++)); }
  done

  # tree-sitter must be the Homebrew one; an nvm-local copy vanishes on a
  # node switch and nvim-treesitter then installs no parsers at all.
  if (( $+commands[tree-sitter] )); then
    if [[ ${commands[tree-sitter]} == /opt/homebrew/* ]]; then
      print "\n\e[1mtree-sitter CLI:\e[0m \e[32m${commands[tree-sitter]}\e[0m"
    else
      print "\n\e[1mtree-sitter CLI:\e[0m \e[33m${commands[tree-sitter]}\e[0m"
      print "  \e[33mnot the Homebrew build — run: brew install tree-sitter-cli\e[0m"
    fi
  fi

  print "\n\e[1mPrompt\e[0m"
  if "$DOTFILES/bin/prompt-selftest" &>/dev/null; then
    print "  \e[32m✓\e[0m all prompt branches render correctly"
  else
    print "  \e[31m✗\e[0m prompt-selftest failed — run it for detail"
    ((bad++))
  fi

  print "\n\e[1mNode version actually on PATH:\e[0m $(node --version 2>/dev/null || print none)"
  print "\e[1mStartup time:\e[0m"
  local i; for i in 1 2 3; do /usr/bin/time -p zsh -i -c exit 2>&1 | rg real; done

  print ""
  (( bad == 0 )) && print "\e[32mAll good.\e[0m" || print "\e[31m$bad problem(s).\e[0m Fix the paths in \$DOTFILES/zsh/00-env.zsh"
  unfunction _chk
}
