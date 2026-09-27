# ═══════════════════════════════════════════════════════════════════════
#  Tool initialisation, personal workflow, and ZLE plugins
#  ORDER IS LOAD-BEARING inside this file:
# ═══════════════════════════════════════════════════════════════════════
#
#    1. Tool inits that define ZLE widgets (fzf ctrl+t, atuin ctrl+r)
#    2. Personal workflow functions
#    3. zsh-autosuggestions, you-should-use, fast-syntax-highlighting
#
#  fast-syntax-highlighting wraps whatever ZLE widgets exist when it
#  loads, so it has to be LAST. Before this consolidation it sat in its
#  own file that loaded BEFORE fzf and atuin registered their widgets.
# ═══════════════════════════════════════════════════════════════════════

# ── Tool initialisation ──────────────────────────────────────────────────
# Every `eval "$(tool init zsh)"` forks a process. Five of them cost ~150ms
# per shell, so we cache the generated code and only regenerate it when the
# binary itself is newer than the cache.

_ZCACHE="$XDG_CACHE_HOME/zsh/init"
[[ -d "$_ZCACHE" ]] || mkdir -p "$_ZCACHE"

_zcache() {
  local name=$1; shift
  local out="$_ZCACHE/$name.zsh"
  local bin=${commands[$1]}
  [[ -z $bin ]] && return 1
  if [[ ! -s $out || $bin -nt $out ]]; then
    "$@" >| "$out" 2>/dev/null || { rm -f "$out"; return 1; }
  fi
  # Deliberately NOT zcompiled. Tried it: wordcode made startup measurably
  # WORSE here (median 85 -> 93 ms over 25 runs a side, reproduced twice),
  # because zcompile -R reads the whole file in eagerly and adds two stats per
  # source, which costs more than parsing a few hundred lines ever did.
  source "$out"
}

# ── Prompt ───────────────────────────────────────────────────────────────
# Lives in 20-prompt.zsh — pure zsh, no starship, no fork to draw it.

# ── zoxide: frecency-ranked cd. `z proj` jumps, `zi` picks interactively ──
export _ZO_DATA_DIR="$XDG_DATA_HOME/zoxide"
export _ZO_RESOLVE_SYMLINKS=1
_zcache zoxide zoxide init zsh --cmd z

# ── fzf: ctrl+t files, alt+c dirs, ** completion trigger ─────────────────
if (( $+commands[fzf] )); then
  export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git --exclude node_modules'
  export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
  export FZF_ALT_C_COMMAND='fd --type d --hidden --follow --exclude .git --exclude node_modules'

  export FZF_DEFAULT_OPTS="
    --height=60% --layout=reverse --border=rounded --info=inline-right
    --prompt=' ' --pointer='▌' --marker='┃'
    --scrollbar='│' --separator='─'
    --bind='ctrl-/:toggle-preview'
    --bind='ctrl-u:preview-page-up,ctrl-d:preview-page-down'
    --bind='ctrl-a:select-all,ctrl-y:execute-silent(echo {+} | pbcopy)'
    --bind='alt-up:preview-up,alt-down:preview-down'"

  # ctrl+t INSERTS the path into the command line — that is its whole job.
  # Do not add `become(nvim ...)` here: become() execs over the fzf process
  # while the zle widget is still waiting to read fzf's output, which hangs
  # the shell on a blank screen. Use `f` to pick a file and open it instead.
  export FZF_CTRL_T_OPTS="
    --preview 'if [ -d {} ]; then eza -T --level=2 --color=always --icons {}; else bat -n --color=always --line-range :300 {}; fi'
    --preview-window='right,60%,border-left'
    --bind='ctrl-y:execute-silent(printf %s {+} | pbcopy)+abort'"

  export FZF_ALT_C_OPTS="--preview 'eza -T --level=2 --color=always --icons {}' --preview-window='right,50%,border-left'"
  export FZF_CTRL_R_OPTS="--preview 'echo {}' --preview-window='down,3,wrap' --bind='ctrl-y:execute-silent(echo -n {2..} | pbcopy)+abort'"

  # Theme colours live in one file the `theme` command rewrites.
  [[ -r "$XDG_CONFIG_HOME/fzf-theme.sh" ]] && source "$XDG_CONFIG_HOME/fzf-theme.sh"

  _zcache fzf fzf --zsh
fi

# ── atuin: SQLite-backed shell history with context and sync ─────────────
# Takes over ctrl+r. Up-arrow stays plain zsh prefix search on purpose —
# muscle memory for "the thing I just ran" shouldn't open a full-screen UI.
if (( $+commands[atuin] )); then
  export ATUIN_NOBIND=true
  _zcache atuin atuin init zsh --disable-up-arrow
  bindkey '^R' atuin-search
fi

# ── direnv: per-project env vars from .envrc ──────────────────────────────
export DIRENV_LOG_FORMAT=''      # silence the "loading .envrc" chatter
_zcache direnv direnv hook zsh

# direnv's hook forks `direnv export zsh` on EVERY prompt, whether or not the
# directory has anything to do with direnv. Measured at ~17 ms a prompt here,
# to serve the single .envrc that exists on this machine.
#
# So gate it on a stat walk. The real hook still runs whenever it could have
# work: when direnv is already loaded (it must get the chance to UNLOAD as you
# leave the tree) or when an .envrc sits at or above $PWD. Only .envrc is
# checked because direnv.toml sets load_dotenv = false, so a plain .env is not
# an RC file — if you ever flip that back, add .env to the test below.
# The second test stops a re-source of .zshrc from wrapping the wrapper, which
# would copy this function into _direnv_hook_real and recurse forever.
if (( $+functions[_direnv_hook] )) && [[ $functions[_direnv_hook] != *_direnv_hook_real* ]]; then
  functions -c _direnv_hook _direnv_hook_real
  _direnv_hook() {
    [[ -n $DIRENV_DIR || -n $DIRENV_WATCHES ]] && { _direnv_hook_real; return }
    local d=$PWD
    while true; do
      [[ -e $d/.envrc ]] && { _direnv_hook_real; return }
      [[ $d == / || -z $d ]] && return 0
      d=${d:h}
    done
  }
fi

# ── try: throwaway project dirs under ~/src/tries ────────────────────────
if [[ -x "$HOME/.local/try.rb" ]]; then
  _try_out="$_ZCACHE/try.zsh"
  if [[ ! -s $_try_out || "$HOME/.local/try.rb" -nt $_try_out ]]; then
    ruby "$HOME/.local/try.rb" init "$HOME/src/tries" >| "$_try_out" 2>/dev/null
  fi
  source "$_try_out" 2>/dev/null
  unset _try_out
fi

# ── Google Cloud SDK: completion is 240ms, so load it on first tab ───────
_lazy_gcloud_completion() {
  unfunction _lazy_gcloud_completion
  compdef -d gcloud gsutil bq gsutil.py 2>/dev/null
  source "$HOME/google-cloud-sdk/completion.zsh.inc"
  return 1
}
if [[ -r "$HOME/google-cloud-sdk/completion.zsh.inc" ]]; then
  compdef _lazy_gcloud_completion gcloud gsutil bq
fi

# ── nvm: lazy. PATH already points at node 24 (see 00-env.zsh), so the ──
#    370ms nvm.sh source only happens when you actually manage versions.
nvm() {
  unfunction nvm
  [[ -s "$NVM_DIR/nvm.sh" ]] && source "$NVM_DIR/nvm.sh"
  nvm "$@"
}
# ── bun completions ──────────────────────────────────────────────────────
[[ -s "$BUN_INSTALL/_bun" ]] && source "$BUN_INSTALL/_bun"

# ── OrbStack (docker/linux VMs) ──────────────────────────────────────────
[[ -r "$HOME/.orbstack/shell/init.zsh" ]] && source "$HOME/.orbstack/shell/init.zsh" 2>/dev/null

# ── JetBrains Toolbox CLI launchers ──────────────────────────────────────
[[ -d "$HOME/Library/Application Support/JetBrains/Toolbox/scripts" ]] \
  && path+=("$HOME/Library/Application Support/JetBrains/Toolbox/scripts")

# ── Active colour theme ──────────────────────────────────────────────────
# `theme <name>` regenerates this file (BAT_THEME and friends) plus the
# matching config for ghostty, nvim, fzf, delta, tmux and lazygit.
[[ -r "$XDG_CONFIG_HOME/theme-env.sh" ]] && source "$XDG_CONFIG_HOME/theme-env.sh"
: ${BAT_THEME:=tokyonight_storm}
export BAT_THEME
export EZA_COLORS='di=34:ln=35:so=32:pi=33:ex=31:bd=34;46:cd=34;43:su=30;41:sg=30;46:tw=30;42:ow=30;43'

# lazygit merges a static config with the generated theme file.
export LG_CONFIG_FILE="$DOTFILES/lazygit/config.yml,$XDG_CONFIG_HOME/lazygit/theme.yml"


# ── git worktree automation ──────────────────────────────────────────────
if [[ -r "$HOME/Developer/worktree-automate/run.sh" ]]; then
  unalias wt 2>/dev/null
  wt() { source "$HOME/Developer/worktree-automate/run.sh" "$@"; }
fi

# ── spawnpoint: create a workspace and cd into it ────────────────────────
if (( $+commands[spawnpoint] )); then
  sp() {
    local cmd="${1:-create}"; shift 2>/dev/null
    local cd_file="$HOME/.spawnpoint/.cd_path"
    rm -f "$cd_file"
    case "$cmd" in
      create)  spawnpoint create -y "$@" ;;
      list|ls) spawnpoint list --cd "$@" ;;
      *)       spawnpoint "$cmd" "$@" ;;
    esac
    if [[ -f "$cd_file" ]]; then
      local dir; dir=$(command cat "$cd_file"); rm -f "$cd_file"
      [[ -n "$dir" ]] && cd "$dir"
    fi
  }
fi

# ── T3 Code: `t3` CLI, open workspaces as new threads ────────────────────
# The desktop app ships the `t3` CLI. Use it when no standalone `t3` is
# installed. The filter removes the Electron warning that each run prints.
if (( ! $+commands[t3] )) && [[ -d "/Applications/T3 Code (Alpha).app" ]]; then
  t3() {
    setopt localoptions nomultios
    local app="/Applications/T3 Code (Alpha).app/Contents"
    { ELECTRON_RUN_AS_NODE=1 "$app/MacOS/T3 Code (Alpha)" \
        "$app/Resources/app.asar/apps/server/dist/bin.mjs" "$@" 2>&1 >&3 \
        | grep -v 'node_main\.cc' >&2 } 3>&1
    return $pipestatus[1]
  }
fi

if (( $+commands[t3] || $+functions[t3] )); then
  # Open a dir (default: cwd) in a new T3 Code thread. Adds the project if
  # it is new. Starts the app if it is not running.
  t3open() {
    local dir=${${1:-$PWD}:A}
    if ! pgrep -qf '/MacOS/T3 Code \(Alpha\)$'; then
      open -a "T3 Code (Alpha)" || return
      local i
      for i in {1..30}; do t3 app "$dir" 2>/dev/null && return; sleep 1; done
    fi
    t3 app "$dir"
  }

  # Create a workspace (`spt ls` picks one), cd into it, open it in T3 Code.
  (( $+functions[sp] )) && spt() {
    local before=$PWD
    sp "$@"
    [[ $PWD != "$before" ]] && t3open
  }
fi

# ── diffity workspace diff viewer (local patched build) ──────────────────
_DIFFITY="$HOME/Developer/claude-temp/diffity-spawnpoint/packages/cli/dist/index.js"
[[ -r "$_DIFFITY" ]] && changes() { node "$_DIFFITY" "$@"; }
unset _DIFFITY

# ── clias ────────────────────────────────────────────────────────────────
(( $+commands[clias] )) && alias ca='clias'

# ═══════════════════════════════════════════════════════════════════════
#  AWS
#
#  [default] carries credential_process (~/.aws/login-creds.sh), which vends
#  fresh keys from the `aws login` session (profile "login") on demand. The
#  CLI and SDKs re-invoke it whenever the previous 15-minute keys expire, so
#  nothing goes stale while the login session lives. Refresh with: aws login
# ═══════════════════════════════════════════════════════════════════════

# awssync [profile] — copy the login session's temporary keys into
# ~/.aws/credentials under [synced], for GUI apps that can run neither login
# sessions nor credential_process.
#
# Never write [default]: static keys there would shadow credential_process and
# everything would go stale 15 minutes later.
awssync() {
  local target="${1:-synced}" creds
  creds=$(AWS_SHARED_CREDENTIALS_FILE=/dev/null command aws configure export-credentials --profile login) || return 1
  command aws configure set aws_access_key_id     "$(jq -r .AccessKeyId     <<<"$creds")" --profile "$target"
  command aws configure set aws_secret_access_key "$(jq -r .SecretAccessKey <<<"$creds")" --profile "$target"
  command aws configure set aws_session_token     "$(jq -r .SessionToken    <<<"$creds")" --profile "$target"
  print "synced login session → [$target] keys (expire $(jq -r .Expiration <<<"$creds"))"
}

# `aws login` signs in the "login" profile (where login_session lives) unless
# another profile is named, then refreshes the [synced] copy. Login ignores the
# credentials file so copied keys never interfere with the browser sign-in flow.
aws() {
  if [[ "$1" == "login" ]]; then
    local args=("$@") has_profile=0 arg
    for arg in "$@"; do
      [[ "$arg" == "--profile" || "$arg" == --profile=* ]] && has_profile=1
    done
    (( has_profile )) || args+=(--profile login)
    AWS_SHARED_CREDENTIALS_FILE=/dev/null command aws "${args[@]}" || return $?
    awssync
  else
    command aws "$@"
  fi
}

# ── AI commit message provider (ai-commits) ──────────────────────────────
export PROVIDER=ollama
export MODEL=mistral


# ── Plugins ──────────────────────────────────────────────────────────────
# Installed via Homebrew (updated with `brew upgrade`) plus two git clones.
# No plugin framework: sourcing four files directly costs ~15ms total, and
# omz/zinit both add hundreds of milliseconds for machinery we don't use.

BREW_SHARE=/opt/homebrew/share
ZPLUG="$HOME/.local/share/zsh/plugins"

# ── Autosuggestions: greys out the rest of the line as you type ───────────
if [[ -r "$BREW_SHARE/zsh-autosuggestions/zsh-autosuggestions.zsh" ]]; then
  ZSH_AUTOSUGGEST_STRATEGY=(history completion)
  ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=#565f89'   # readable on every oceanic theme
  ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=25             # don't suggest against huge pastes
  ZSH_AUTOSUGGEST_MANUAL_REBIND=1                # skip the rebind-on-every-precmd cost
  source "$BREW_SHARE/zsh-autosuggestions/zsh-autosuggestions.zsh"

  bindkey '^[[C'  forward-char                   # right arrow: accept one char
  bindkey '^ '    autosuggest-accept             # ctrl+space: accept whole line
  bindkey '^[[1;5C' forward-word                 # ctrl+right: accept one word
fi

# ── you-should-use: nags when you type a command you already aliased ─────
export YSU_MESSAGE_POSITION="after"
# Do NOT set YSU_HARDCORE, not even to 0. The plugin tests it with
# (( ${+YSU_HARDCORE} )), which asks whether the variable EXISTS, not what it
# holds — so `YSU_HARDCORE=0` switched hardcore mode ON. In that mode the
# plugin sends SIGINT to the shell to abort any command that has an alias, so
# `cd ..` (alias ..) and `claude` (alias cl) were killed before they ran. The
# explanation went to stderr, which another bug had pointed at /dev/null, so
# both simply appeared to do nothing. Reminder only is what we want here:
unset YSU_HARDCORE
export YSU_MESSAGE_FORMAT="$(printf '\033[38;5;110m alias: %%alias\033[0m')"
[[ -r "$ZPLUG/zsh-you-should-use/you-should-use.plugin.zsh" ]] \
  && source "$ZPLUG/zsh-you-should-use/you-should-use.plugin.zsh"

# ── Syntax highlighting — MUST be sourced last of all the ZLE widgets ────
[[ -r "$BREW_SHARE/zsh-fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh" ]] \
  && source "$BREW_SHARE/zsh-fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh"
