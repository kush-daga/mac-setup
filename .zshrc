# ═══════════════════════════════════════════════════════════════════════
#  ~/.zshrc — the entry point. Kept at the repo root so it is the first
#  thing you see; the pieces it loads live in zsh/.
#
#  Files are sourced in numeric order, and that order is load-bearing:
#
#    00-env      PATH and runtimes — everything later assumes it is final
#    10-shell    options, key bindings, completion, fzf-tab
#    20-prompt   the prompt, and its accept-line widget
#    30-tools    tool inits, workflow, then the ZLE plugins LAST
#    40-shell    aliases and functions
#
#  `zwhere <name>` prints the file and line that defines any alias,
#  function, or exported variable.
#  Profile a slow start with:  ZSH_PROFILE=1 zsh -i -c exit
# ═══════════════════════════════════════════════════════════════════════

[[ -n "$ZSH_PROFILE" ]] && zmodload zsh/zprof

# Amazon Q — must stay first. Guarded: it is a no-op now that q is gone.
[[ -f "$HOME/Library/Application Support/amazon-q/shell/zshrc.pre.zsh" ]] \
  && builtin source "$HOME/Library/Application Support/amazon-q/shell/zshrc.pre.zsh"

for _f in "$DOTFILES"/zsh/[0-9]*.zsh; do
  [[ -r "$_f" ]] && source "$_f"
done
unset _f

# Machine-local overrides: secrets, work-specific bits, anything not in git.
[[ -r "$HOME/.zshrc.local" ]] && source "$HOME/.zshrc.local"

# Amazon Q — must stay last.
[[ -f "$HOME/Library/Application Support/amazon-q/shell/zshrc.post.zsh" ]] \
  && builtin source "$HOME/Library/Application Support/amazon-q/shell/zshrc.post.zsh"

[[ -n "$ZSH_PROFILE" ]] && zprof
