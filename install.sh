#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════════════════
#  install.sh — link this repo into place. Safe to re-run any time.
#
#    ./install.sh              link everything
#    ./install.sh --dry-run    show what would happen, change nothing
#    ./install.sh --packages   also install the Brewfile
#
#  Anything it replaces is moved to ~/.dotfiles-backup/<timestamp>/.
# ═══════════════════════════════════════════════════════════════════════
set -euo pipefail

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
BACKUP="$HOME/.dotfiles-backup/$(date +%Y%m%d-%H%M%S)"
DRY_RUN=0
DO_PACKAGES=0

for arg in "$@"; do
  case "$arg" in
    --dry-run)  DRY_RUN=1 ;;
    --packages) DO_PACKAGES=1 ;;
    -h|--help)  sed -n '2,11p' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
    *) printf 'unknown flag: %s\n' "$arg" >&2; exit 1 ;;
  esac
done

bold=$'\033[1m'; green=$'\033[32m'; yellow=$'\033[33m'; blue=$'\033[34m'; dim=$'\033[2m'; reset=$'\033[0m'
say()  { printf '%s\n' "$*"; }
step() { printf '\n%s%s%s\n' "$bold" "$*" "$reset"; }
run()  { if (( DRY_RUN )); then printf '  %swould run:%s %s\n' "$dim" "$reset" "$*"; else "$@"; fi; }

# link <source-in-repo> <destination>
link() {
  local src="$DOTFILES/$1" dst="$2"
  [[ -e "$src" ]] || { printf '  %s×%s %s %s(missing in repo)%s\n' "$yellow" "$reset" "$1" "$dim" "$reset"; return; }

  if [[ -L "$dst" ]]; then
    if [[ "$(readlink "$dst")" == "$src" ]]; then
      printf '  %s=%s %s\n' "$dim" "$reset" "${dst/#$HOME/~}"; return
    fi
    run rm -f "$dst"
  elif [[ -e "$dst" ]]; then
    run mkdir -p "$BACKUP/$(dirname "${dst#$HOME/}")"
    run mv "$dst" "$BACKUP/${dst#$HOME/}"
    printf '  %s↩%s backed up %s\n' "$yellow" "$reset" "${dst/#$HOME/~}"
  fi

  run mkdir -p "$(dirname "$dst")"
  run ln -sfn "$src" "$dst"
  printf '  %s→%s %s\n' "$green" "$reset" "${dst/#$HOME/~}"
}

# ── 1. Packages ──────────────────────────────────────────────────────────
if (( DO_PACKAGES )); then
  step "Installing packages from the Brewfile"
  command -v brew >/dev/null || {
    say "  installing Homebrew first…"
    run /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  }
  run brew bundle install --file="$DOTFILES/Brewfile"
fi

# ── 2. Shell ─────────────────────────────────────────────────────────────
step "Shell"
link .zshenv "$HOME/.zshenv"
link .zshrc  "$HOME/.zshrc"

# ── 3. Terminal, editor, multiplexer ─────────────────────────────────────
step "Terminal & editor"
link ghostty/config    "$XDG_CONFIG_HOME/ghostty/config"
link ghostty/themes    "$XDG_CONFIG_HOME/ghostty/themes"   # custom themes
link nvim              "$XDG_CONFIG_HOME/nvim"
link tmux/tmux.conf    "$XDG_CONFIG_HOME/tmux/tmux.conf"

# ── 4. Git ───────────────────────────────────────────────────────────────
step "Git"
link git/gitconfig "$HOME/.gitconfig"

# The default identity lives outside the repo so no email is ever committed.
if [[ -f "$HOME/.gitconfig.local" ]]; then
  printf '  %s=%s ~/.gitconfig.local\n' "$dim" "$reset"
else
  run cp "$DOTFILES/git/gitconfig.local.example" "$HOME/.gitconfig.local"
  printf '  %s→%s ~/.gitconfig.local %s(edit it — name and email are placeholders)%s\n' \
    "$yellow" "$reset" "$dim" "$reset"
fi

# ── 5. SSH (personal GitHub) ─────────────────────────────────────────────
step "SSH"
SSH_DIR="$HOME/.ssh"
SSH_CONFIG="$SSH_DIR/config"
[[ -d "$SSH_DIR" ]] || run mkdir -m 700 "$SSH_DIR"
if [[ ! -f "$SSH_CONFIG" ]]; then
  run touch "$SSH_CONFIG"
  run chmod 600 "$SSH_CONFIG"
fi

if grep -q '^Host github-personal' "$SSH_CONFIG" 2>/dev/null; then
  printf '  %s=%s ~/.ssh/config already has a github-personal block\n' "$dim" "$reset"
elif (( DRY_RUN )); then
  printf '  %swould append:%s ssh/config.personal -> ~/.ssh/config\n' "$dim" "$reset"
else
  { echo; cat "$DOTFILES/ssh/config.personal"; } >> "$SSH_CONFIG"
  printf '  %s→%s appended the github-personal Host block to ~/.ssh/config\n' "$green" "$reset"
fi

if [[ ! -f "$SSH_DIR/id_ed25519_personal" ]]; then
  printf '  %s×%s no personal key yet. Generate one (not run for you):%s\n' "$yellow" "$reset" "$reset"
  printf '      ssh-keygen -t ed25519 -f ~/.ssh/id_ed25519_personal -C "you@example.com"\n'
  printf '    then add the .pub key at https://github.com/settings/keys\n'
fi

# ── 6. CLI tools ─────────────────────────────────────────────────────────
step "CLI tools"
link bat/config        "$XDG_CONFIG_HOME/bat/config"
link bat/themes        "$XDG_CONFIG_HOME/bat/themes"
link yazi/yazi.toml    "$XDG_CONFIG_HOME/yazi/yazi.toml"
link yazi/keymap.toml  "$XDG_CONFIG_HOME/yazi/keymap.toml"
link atuin/config.toml "$XDG_CONFIG_HOME/atuin/config.toml"
link direnv/direnv.toml "$XDG_CONFIG_HOME/direnv/direnv.toml"
link gh-dash/config.yml "$XDG_CONFIG_HOME/gh-dash/config.yml"
link asdf/tool-versions "$HOME/.tool-versions"

# cmux embeds Ghostty and reads ~/.config/ghostty/config for terminal
# behaviour, so this file only carries cmux's own chrome and shortcuts.
link cmux/cmux.json "$XDG_CONFIG_HOME/cmux/cmux.json"

# Karabiner rewrites karabiner.json in place (write + atomic rename), which
# would break a symlink to just that file, so the whole directory is
# symlinked instead. automatic_backups/ stays out of git (see .gitignore).
link karabiner "$XDG_CONFIG_HOME/karabiner"

# ── 7. zsh plugins that aren't in Homebrew ───────────────────────────────
step "zsh plugins"
ZPLUG="$HOME/.local/share/zsh/plugins"
clone() {
  local repo="$1" dir="$ZPLUG/$2"
  if [[ -d "$dir" ]]; then printf '  %s=%s %s\n' "$dim" "$reset" "$2"
  else run git clone -q --depth 1 "$repo" "$dir"; printf '  %s→%s %s\n' "$green" "$reset" "$2"; fi
}
run mkdir -p "$ZPLUG"
clone https://github.com/Aloxaf/fzf-tab.git fzf-tab
clone https://github.com/MichaelAquilina/zsh-you-should-use.git zsh-you-should-use

# ── 8. tmux plugin manager ───────────────────────────────────────────────
step "tmux plugins"
TPM="$XDG_CONFIG_HOME/tmux/plugins/tpm"
if [[ -d "$TPM" ]]; then printf '  %s=%s tpm\n' "$dim" "$reset"
else
  run git clone -q --depth 1 https://github.com/tmux-plugins/tpm "$TPM"
  printf '  %s→%s tpm\n' "$green" "$reset"
fi
(( DRY_RUN )) || "$TPM/bin/install_plugins" >/dev/null 2>&1 || true
printf '  %s→%s plugins installed (prefix + I to refresh later)\n' "$green" "$reset"

# ── 9. Theme ─────────────────────────────────────────────────────────────
step "Theme"
if (( DRY_RUN )); then
  printf '  %swould run:%s theme "$(cat ~/.config/theme 2>/dev/null || echo tokyonight-storm)"\n' "$dim" "$reset"
else
  "$DOTFILES/bin/theme" "$(tr -d '[:space:]' < "$XDG_CONFIG_HOME/theme" 2>/dev/null || echo tokyonight-storm)" \
    | sed 's/^/  /' || true
fi

# ── 10. bat needs its theme cache built after the themes are linked ──────
step "bat theme cache"
run bat cache --build >/dev/null 2>&1 || true
printf '  %s→%s built\n' "$green" "$reset"

# ── 11. Neovim ───────────────────────────────────────────────────────────
step "Neovim plugins"
if (( DRY_RUN )); then
  printf '  %swould run:%s nvim --headless "+Lazy! sync" +qa, then MasonInstall\n' "$dim" "$reset"
else
  nvim --headless "+Lazy! sync" +qa 2>&1 | tail -3 | sed 's/^/  /' || true
  printf '  %s→%s plugins synced\n' "$green" "$reset"

  # Language servers need an explicit MasonInstall. The LSP spec is lazy on
  # BufReadPre, so it never loads if headless nvim opens no file — and
  # mason-lspconfig skips its own ensure_installed step under --headless by
  # design. Opening a real file plus naming the packages covers both.
  printf '  installing language servers (this takes a few minutes)…\n'
  nvim --headless "$DOTFILES/nvim/init.lua" \
    -c 'MasonInstall lua-language-server basedpyright ruff typescript-language-server gopls json-lsp yaml-language-server bash-language-server dockerfile-language-server taplo' \
    -c 'lua vim.defer_fn(function() vim.cmd("qa!") end, 600000)' >/dev/null 2>&1 || true
  printf '  %s→%s %s language servers and formatters installed\n' \
    "$green" "$reset" "$(ls ~/.local/share/nvim/mason/bin 2>/dev/null | wc -l | tr -d ' ')"
fi

# ── Done ─────────────────────────────────────────────────────────────────
step "Done"
[[ -d "$BACKUP" ]] && say "  Replaced files are in ${BACKUP/#$HOME/~}"
cat <<EOF

  ${bold}Next${reset}
    exec zsh                 reload the shell
    cmd+shift+,              reload Ghostty
    dotfiles-doctor          verify the install
    cheat                    the full keybinding reference

  ${bold}Machine-local config${reset} (secrets, work-specific bits, never committed)
    ~/.zshrc.local

  ${bold}Manual steps${reset}
    cmux, T3 Code            nothing to do (installed as brew casks)
    Ghostty                  grant Accessibility, for the global cmd+\` quick terminal
    macos/defaults.sh        optional (keyboard, Finder, screenshots)
EOF
