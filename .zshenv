# ~/.zshenv — sourced for EVERY zsh (scripts included). Keep it cheap and silent.

# ── XDG base directories ─────────────────────────────────────────────────
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"
export XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
export XDG_STATE_HOME="${XDG_STATE_HOME:-$HOME/.local/state}"

export DOTFILES="$HOME/.dotfiles"
export ZDOTDIR="${ZDOTDIR:-$HOME}"

# ── Locale ───────────────────────────────────────────────────────────────
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

# ── Editor ───────────────────────────────────────────────────────────────
export EDITOR=nvim
export VISUAL=nvim
export GIT_EDITOR=nvim
export SUDO_EDITOR=nvim

# ── Pager ────────────────────────────────────────────────────────────────
# -R  keep colors     -F  quit if it fits one screen    -X  don't clear on exit
# -i  smart-case      --mouse  scrollwheel works inside less
export PAGER=less
export LESS='-R -F -X -i --mouse --wheel-lines=3'
export LESSHISTFILE="$XDG_STATE_HOME/less/history"

# Colourised man pages, rendered through bat.
export MANPAGER="sh -c 'sed -u -e \"s/\\x1b\\[[0-9;]*m//g; s/.\\x08//g\" | bat -p -l man'"
export MANROFFOPT='-c'

# ── Homebrew ─────────────────────────────────────────────────────────────
export HOMEBREW_NO_ANALYTICS=1
export HOMEBREW_NO_ENV_HINTS=1
export HOMEBREW_NO_INSTALL_CLEANUP=1
export HOMEBREW_BUNDLE_FILE="$DOTFILES/Brewfile"

# ── Misc tool hygiene ────────────────────────────────────────────────────
export DO_NOT_TRACK=1
export PYTHONDONTWRITEBYTECODE=1
export PIP_REQUIRE_VIRTUALENV=false
export DOCKER_CLI_HINTS=false
