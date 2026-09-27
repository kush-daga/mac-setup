# ═══════════════════════════════════════════════════════════════════════
#  Shell behaviour: options, key bindings, completion
#  History, setopts, emacs key bindings, then the completion system
#  and fzf-tab. fzf-tab must come after compinit, which is why they
#  share a file.
# ═══════════════════════════════════════════════════════════════════════

# ── History ──────────────────────────────────────────────────────────────
HISTFILE="$XDG_STATE_HOME/zsh/history"
[[ -d "${HISTFILE:h}" ]] || mkdir -p "${HISTFILE:h}"
HISTSIZE=200000            # in-memory
SAVEHIST=200000            # on-disk

setopt EXTENDED_HISTORY          # record timestamp + duration
setopt INC_APPEND_HISTORY        # write as you go, not just on exit
setopt SHARE_HISTORY             # sync across live shells
setopt HIST_IGNORE_DUPS          # skip consecutive duplicates
setopt HIST_IGNORE_ALL_DUPS      # drop older duplicate of a re-run command
setopt HIST_IGNORE_SPACE         # ` cmd` stays out of history
setopt HIST_FIND_NO_DUPS
setopt HIST_REDUCE_BLANKS
setopt HIST_VERIFY               # expand !! for review instead of running it
setopt HIST_SAVE_NO_DUPS

# ── Directory navigation ─────────────────────────────────────────────────
setopt AUTO_CD                   # `..` or a bare dirname cd's
setopt AUTO_PUSHD                # every cd pushes onto the stack
setopt PUSHD_IGNORE_DUPS
setopt PUSHD_SILENT
DIRSTACKSIZE=20

# ── Globbing ─────────────────────────────────────────────────────────────
setopt EXTENDED_GLOB             # ^, #, ~ operators in patterns
setopt GLOB_DOTS                 # * matches dotfiles
setopt NUMERIC_GLOB_SORT         # file2 sorts before file10
setopt NO_NOMATCH                # pass unmatched globs through (curl ?q=1)

# ── Correctness & safety ─────────────────────────────────────────────────
setopt INTERACTIVE_COMMENTS      # # comments work at the prompt
setopt NO_FLOW_CONTROL           # frees ctrl+s / ctrl+q
setopt NO_BEEP
setopt NO_CLOBBER                # > won't overwrite; use >| to force
setopt LONG_LIST_JOBS
setopt NOTIFY                    # report finished jobs immediately
setopt NO_HUP                    # background jobs survive shell exit
unsetopt CASE_GLOB               # case-insensitive globbing

# ── Key bindings (emacs base — the macOS/readline muscle memory) ─────────
bindkey -e

# Needed by prompt-watch and any hook management.
autoload -Uz add-zsh-hook

bindkey '^[[1;3D' backward-word          # alt+left
bindkey '^[[1;3C' forward-word           # alt+right
bindkey '^[b'     backward-word          # alt+b
bindkey '^[f'     forward-word           # alt+f
bindkey '^[^?'    backward-kill-word     # alt+backspace
bindkey '^[[3;3~' kill-word              # alt+delete
bindkey '^[[H'    beginning-of-line      # home
bindkey '^[[F'    end-of-line            # end
bindkey '^A'      beginning-of-line
bindkey '^E'      end-of-line
bindkey '^U'      backward-kill-line     # kill to start of line (readline standard)
bindkey '^X^K'    kill-buffer
bindkey '^K'      kill-line
bindkey '^W'      backward-kill-word
bindkey '^[[3~'   delete-char

# Up and down search history for lines that START with the text typed so far.
# Type "up", press up: you get the last command that began with "up".
# With an empty line they step through history as normal.
autoload -Uz up-line-or-beginning-search down-line-or-beginning-search
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search
bindkey '^[[A'    up-line-or-beginning-search
bindkey '^[OA'    up-line-or-beginning-search
bindkey '^P'      up-line-or-beginning-search
bindkey '^[[B'    down-line-or-beginning-search
bindkey '^[OB'    down-line-or-beginning-search
bindkey '^N'      down-line-or-beginning-search

# Treat path separators as word boundaries so alt+backspace eats one dir.
autoload -Uz select-word-style && select-word-style bash

# ctrl+x ctrl+e — open the current command line in nvim, run it on save.
autoload -Uz edit-command-line
zle -N edit-command-line
bindkey '^X^E' edit-command-line

# alt+. — insert the last argument of the previous command.
bindkey '^[.' insert-last-word

# ctrl+z — toggle: suspend a job, or press again to foreground it.
_fg_or_suspend() {
  if [[ $#BUFFER -eq 0 ]]; then
    fg >/dev/null 2>&1 && zle redisplay
  else
    zle push-input
  fi
}
zle -N _fg_or_suspend && bindkey '^Z' _fg_or_suspend

# Paste large blocks without the syntax highlighter crawling char by char.
DISABLE_MAGIC_FUNCTIONS=true


# ── Completion system ────────────────────────────────────────────────────
# compinit's security audit is the single slowest part of zsh startup, so we
# run the full check once a day and take the cached dump otherwise.

fpath=(
  /opt/homebrew/share/zsh-completions
  /opt/homebrew/share/zsh/site-functions
  "$DOTFILES/zsh/completions"
  $fpath
)

ZCOMPDUMP="$XDG_CACHE_HOME/zsh/zcompdump-${ZSH_VERSION}"
[[ -d "${ZCOMPDUMP:h}" ]] || mkdir -p "${ZCOMPDUMP:h}"

autoload -Uz compinit
# -C skips the audit; we only pay for it if the dump is older than 20 hours.
if [[ -n ${ZCOMPDUMP}(#qNmh-20) ]]; then
  compinit -C -d "$ZCOMPDUMP"
else
  compinit -i -d "$ZCOMPDUMP"
  # Compile the dump to bytecode so the next shell loads it even faster.
  { [[ -s "$ZCOMPDUMP" && ( ! -s "${ZCOMPDUMP}.zwc" || "$ZCOMPDUMP" -nt "${ZCOMPDUMP}.zwc" ) ]] \
      && zcompile -R -- "${ZCOMPDUMP}.zwc" "$ZCOMPDUMP" } &!
fi

autoload -Uz bashcompinit && bashcompinit

setopt ALWAYS_TO_END             # cursor jumps to end after a completion
setopt COMPLETE_IN_WORD          # complete from the cursor, mid-word
setopt AUTO_MENU                 # second tab opens the menu
setopt AUTO_LIST
setopt AUTO_PARAM_SLASH          # dir completions get a trailing /
setopt NO_MENU_COMPLETE          # don't auto-insert the first match
setopt PATH_DIRS
unsetopt CASE_GLOB

# ── Matching: case-insensitive, then dash/underscore-insensitive, ────────
#    then partial-word, then substring. Each tier only runs if the last failed.
zstyle ':completion:*' matcher-list \
  'm:{a-zA-Z-_}={A-Za-z_-}' \
  'r:|[._-]=* r:|=*' \
  'l:|=* r:|=*'

zstyle ':completion:*' menu no                       # fzf-tab renders the menu
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path "$XDG_CACHE_HOME/zsh/compcache"
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' verbose yes
zstyle ':completion:*' group-name ''
zstyle ':completion:*' squeeze-slashes true
zstyle ':completion:*:descriptions' format '%F{blue}%B %d%b%f'
zstyle ':completion:*:messages'     format '%F{yellow} %d%f'
zstyle ':completion:*:warnings'     format '%F{red} no match%f'
zstyle ':completion:*:corrections' format '%F{yellow} %d (errors: %e)%f'

# Complete process names for kill, not PIDs you have to read off `ps`.
zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#)*=0=01;31'
zstyle ':completion:*:*:*:*:processes' command 'ps -u $USER -o pid,user,comm -w'

# Never suggest the directory you're already in when using cd ../
zstyle ':completion:*:cd:*' ignore-parents parent pwd
zstyle ':completion:*' special-dirs true

# Don't offer files that are already on the command line.
zstyle ':completion:*:(rm|kill|diff|cp|mv):*' ignore-line other

# ── fzf-tab: replaces the completion menu with an fzf picker + previews ───
source "$HOME/.local/share/zsh/plugins/fzf-tab/fzf-tab.plugin.zsh" 2>/dev/null

zstyle ':fzf-tab:*' fzf-command fzf
zstyle ':fzf-tab:*' switch-group '<' '>'          # cycle completion groups
zstyle ':fzf-tab:*' fzf-min-height 15
zstyle ':fzf-tab:*' prefix ''                     # no leading dot marker
zstyle ':fzf-tab:*' single-group color header
zstyle ':fzf-tab:*' fzf-flags --height=45% --layout=reverse --border=rounded --info=inline

# Preview panes: see what you're completing before you commit to it.
zstyle ':fzf-tab:complete:*:*' fzf-preview \
  'if [[ -d $realpath ]]; then eza -1 --color=always --icons --group-directories-first $realpath;
   elif [[ -f $realpath ]]; then bat --color=always --style=numbers --line-range=:200 $realpath 2>/dev/null || file $realpath;
   else echo ${(P)word}; fi'
zstyle ':fzf-tab:complete:(cd|z|pushd|ls|eza|tree):*' fzf-preview \
  'eza -1 --color=always --icons --group-directories-first $realpath'
zstyle ':fzf-tab:complete:(-command-|-parameter-|-brace-parameter-|export|unset|expand):*' \
  fzf-preview 'echo ${(P)word}'
zstyle ':fzf-tab:complete:git-(add|diff|restore|checkout|switch):*' fzf-preview \
  'git diff --color=always -- $realpath | delta 2>/dev/null || git diff --color=always -- $realpath'
zstyle ':fzf-tab:complete:git-(log|show):*' fzf-preview \
  'git log --color=always --oneline --graph -20 $word 2>/dev/null'
zstyle ':fzf-tab:complete:kill:argument-rest' fzf-preview 'ps --pid=$word -o cmd --no-headers -w -w 2>/dev/null'
zstyle ':fzf-tab:complete:(brew-install|brew-uninstall|brew-info):*' fzf-preview 'brew info $word'
zstyle ':fzf-tab:complete:systemctl-*:*' fzf-preview 'SYSTEMD_COLORS=1 systemctl status $word'
