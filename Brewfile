# ═══════════════════════════════════════════════════════════════════════
#  Brewfile — everything this setup needs.
#  Install:  brew bundle install --file=~/.dotfiles/Brewfile
#  Refresh:  bdump   (alias for brew bundle dump --force --describe)
# ═══════════════════════════════════════════════════════════════════════

# ── Terminal ─────────────────────────────────────────────────────────────
cask "ghostty"                          # GPU-accelerated terminal
cask "cmux"                             # Ghostty-embedding workspace sidebar
cask "t3-code"                          # T3 Code app (also ships the `t3` CLI)
cask "font-fira-code-nerd-font"         # Ghostty's actual font: icons + ligatures
cask "font-jetbrains-mono-nerd-font"    # alternate font, swap in ghostty/config
cask "font-symbols-only-nerd-font"      # icon fallback for other fonts

# ── Shell ────────────────────────────────────────────────────────────────
brew "zsh-autosuggestions"              # greys out the rest of the line
brew "zsh-completions"                  # extra completion definitions
brew "zsh-fast-syntax-highlighting"     # colours the command as you type
# starship removed: the prompt is pure zsh now (zsh/20-prompt.zsh),
# which draws with no subprocess and renders git status asynchronously.
brew "atuin"                            # SQLite shell history (ctrl+R)
brew "zoxide"                           # frecency cd (`z proj`)
brew "direnv"                           # per-directory env vars
brew "tmux"                             # persistent sessions

# ── Editor ───────────────────────────────────────────────────────────────
brew "neovim"
brew "luajit"
brew "tree-sitter"                      # the parser library
# REQUIRED, not optional: nvim-treesitter's `main` branch compiles grammars
# by shelling out to this CLI. Without it, treesitter silently fails to
# install any parser. Deliberately the brew formula and not `npm i -g
# tree-sitter-cli` — the npm one installs into the *active nvm node version's*
# bin dir, so it disappears the moment the node version changes.
brew "tree-sitter-cli"

# ── Search & navigate ────────────────────────────────────────────────────
brew "fzf"                              # fuzzy finder, used everywhere
brew "fd"                               # fast `find`
brew "ripgrep"                          # fast `grep`
brew "eza"                              # `ls` with icons and git status
brew "yazi"                             # TUI file manager
brew "tree"

# ── Read files ───────────────────────────────────────────────────────────
brew "bat"                              # `cat` with syntax highlighting
brew "bat-extras"                       # batgrep, batman, batdiff, batwatch
brew "glow"                             # render markdown in the terminal
brew "jq"                               # JSON
brew "yq"                               # YAML/XML/TOML

# yazi preview backends
brew "ffmpegthumbnailer"                # video thumbnails
brew "sevenzip"                         # archive contents
brew "poppler"                          # PDF text
brew "resvg"                            # SVG
brew "imagemagick"                      # everything else

# ── Git ──────────────────────────────────────────────────────────────────
brew "git"
brew "git-lfs"
brew "git-delta"                        # side-by-side diff pager
brew "difftastic"                       # syntax-aware structural diff
brew "git-absorb"                       # auto-fixup into the right commit
brew "lazygit"                          # git TUI
brew "gh"                               # GitHub CLI

# ── System ───────────────────────────────────────────────────────────────
cask "karabiner-elements"               # keyboard remapping (karabiner/)
brew "btop"                             # process/resource monitor
brew "dust"                             # `du` as a tree
brew "duf"                              # `df` with colour
brew "procs"                            # `ps` that's readable
brew "hyperfine"                        # benchmark shell commands
brew "tealdeer"                         # `tldr` man-page summaries
brew "gum"                              # pretty prompts in shell scripts
brew "sd"                              # `sed` for humans
brew "curlie"                           # `curl` with httpie's ergonomics
brew "lazydocker"                       # docker TUI

# ── Runtimes (managed elsewhere, listed for a fresh machine) ─────────────
brew "asdf"                             # generic version manager
brew "nvm"                              # node versions
