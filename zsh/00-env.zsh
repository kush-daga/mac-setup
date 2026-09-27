# ═══════════════════════════════════════════════════════════════════════
#  PATH and language runtimes
#  Loaded first: everything after this assumes the PATH is final.
# ═══════════════════════════════════════════════════════════════════════

# ── PATH ─────────────────────────────────────────────────────────────────
# `typeset -U` dedupes automatically, so re-sourcing never bloats PATH.
typeset -U path PATH fpath FPATH

# Homebrew (arm64). Cheaper than `eval $(brew shellenv)`.
export HOMEBREW_PREFIX=/opt/homebrew
export HOMEBREW_CELLAR=/opt/homebrew/Cellar
export HOMEBREW_REPOSITORY=/opt/homebrew
export INFOPATH="/opt/homebrew/share/info:$INFOPATH"

# Lowest priority first; each `path=(X $path)` below pushes X further up.
path=(
  /opt/homebrew/bin
  /opt/homebrew/sbin
  $path
)

# ── Language runtimes ────────────────────────────────────────────────────
# Paths are hardcoded on purpose: resolving them at startup (`nvm which 24`,
# `python -m site`, `go env GOPATH`) spawned 3 processes and cost ~400ms.
# If a version moves, run `dotfiles-doctor` and it will tell you.

# asdf 0.18 (Go rewrite) needs only its shim dir on PATH — no shell sourcing.
export ASDF_DATA_DIR="$HOME/.asdf"
path=("$ASDF_DATA_DIR/shims" $path)

# Node 24 via nvm, ahead of asdf shims and Homebrew's node.
export NVM_DIR="$HOME/.nvm"
path=("$NVM_DIR/versions/node/v24.15.0/bin" $path)

# Go and Rust.
# ~/.cargo/env only prepends ~/.cargo/bin, which is covered here — so it is
# deliberately not sourced (sourcing it would jump the ordering below).
path=("$HOME/go/bin" "$HOME/.cargo/bin" $path)

# Python user installs (`pip install --user`). A glob instead of a pinned
# version, so a Python upgrade doesn't silently drop these from PATH.
# N = no error if nothing matches; the loop is a glob, not a subprocess.
for _pybin in "$HOME/Library/Python"/*/bin(N); do
  path=("$_pybin" $path)
done
unset _pybin

# JS package managers
export BUN_INSTALL="$HOME/.bun"
export PNPM_HOME="$HOME/Library/pnpm"
path=("$BUN_INSTALL/bin" "$PNPM_HOME" $path)

# Java
export JAVA_HOME=/Library/Java/JavaVirtualMachines/zulu-17.jdk/Contents/Home

# ── Tools & personal scripts (highest priority) ──────────────────────────
export COMPOSIO_INSTALL_DIR="$HOME/.composio"
path=(
  "$HOME/.claude/local"
  "$HOME/.antigravity/antigravity/bin"
  "$COMPOSIO_INSTALL_DIR"
  "$HOME/Developer/scripts"
  "$HOME/.local/bin"
  "$DOTFILES/bin"
  $path
)

# Google Cloud SDK (path only; completion is lazy-loaded in 30-tools.zsh)
[[ -r "$HOME/google-cloud-sdk/path.zsh.inc" ]] && source "$HOME/google-cloud-sdk/path.zsh.inc"

export PATH
