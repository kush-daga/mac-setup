# mac-setup

A macOS terminal and editor setup: zsh, Ghostty, cmux, Neovim, tmux, and a
one-command theme system that switches all of them together. Shell startup
is 2.4s down to about 0.07s; see [Startup speed](#startup-speed).

Keybindings and commands: `cheat` (or read [CHEATSHEET.md](CHEATSHEET.md)).

---

## Set up a new Mac

```sh
xcode-select --install
```

Then Homebrew (`install.sh --packages` below installs it automatically if
it's missing, so this step can be skipped):

```sh
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

Clone this repo. The path has to be `~/.dotfiles`: it's hardcoded in
`.zshenv` (`$DOTFILES`), and in `git/gitconfig`'s `includeIf`, its
`core.excludesfile`, and its `commit.template`.

```sh
git clone https://github.com/kush-daga/mac-setup.git ~/.dotfiles
cd ~/.dotfiles
./install.sh --packages
```

`install.sh` is idempotent: re-run it any time. Anything it replaces is
moved to `~/.dotfiles-backup/<timestamp>/`, never deleted.

- `--dry-run` shows what it would do and changes nothing.
- `--packages` also runs `brew bundle install` from the Brewfile.
- With neither flag, it only links files (fast, no downloads).

Then, the parts that stay outside the repo on purpose:

- **`~/.gitconfig.local`**: install.sh creates it from
  `git/gitconfig.local.example` if it's missing. Edit the name and email:
  this is the default git identity everywhere except `~/.dotfiles/` and
  `~/personal/`, which use the personal identity in
  `git/gitconfig-personal` instead.
- **`~/.zshrc.local`**: not created automatically. Make it yourself for
  machine-private aliases and secrets. It's sourced last and never
  committed.
- **Personal SSH key**: install.sh appends `ssh/config.personal` (the
  `github-personal` host alias) to `~/.ssh/config`, creating `~/.ssh` and
  the config file with the right permissions if they don't exist yet, and
  skipping the append if that host block is already there. If
  `~/.ssh/id_ed25519_personal` doesn't exist, install.sh prints (does not
  run) the `ssh-keygen` command to make one, plus a reminder to add the
  `.pub` key at github.com/settings/keys.
- **`./macos/defaults.sh`**: optional. Keyboard repeat rate, Finder
  settings, screenshot location, and similar.
- **Permissions**: grant Ghostty Accessibility access, for the global
  `` cmd+` `` quick terminal to work from any app. Grant it Notifications
  access too, for `notify-on-command-finish`.
- **`theme <name>`**: pick a colour scheme. See [Themes](#theme-system).

### Helpers this setup can use, but doesn't install

None of these are in the Brewfile, and every place that calls them checks
first and no-ops if they're absent: `nvm` (and a Node version under it),
`asdf` (with a Python version, see `asdf/tool-versions`), `rustup`, `bun`,
the Google Cloud SDK, `pipx` with `spawnpoint`, `try.rb`, a
`worktree-automate` checkout, a local `diffity` build, and `clias`. Install
whichever ones you actually use.

---

## Layout

```
.
├── install.sh              symlink everything into place, idempotent
├── Brewfile                every package this setup needs
├── CHEATSHEET.md           the keybinding reference (`cheat`)
├── bin/
│   ├── theme               switch the colour scheme of every tool at once
│   ├── prompt-selftest     exercise every prompt branch after editing it
│   └── scrub-history       find and redact secret-shaped shell history
├── themes/*.sh             colour definitions, one file per theme
├── .zshrc                  the entry point, at the root so you see it first
├── .zshenv                 env for every zsh, interactive or not
├── zsh/                    the pieces .zshrc loads, in numeric order
│   ├── 00-env.zsh          PATH and runtimes
│   ├── 10-shell.zsh        options, key bindings, completion, fzf-tab
│   ├── 20-prompt.zsh       the prompt
│   ├── 30-tools.zsh        tool init, workflow, then ZLE plugins last
│   ├── 40-shell.zsh        aliases and functions
│   └── vendor/             oh-my-zsh's git plugin, MIT, attributed
├── ghostty/                config, plus a custom theme in themes/
├── cmux/cmux.json          the vertical workspace sidebar
├── nvim/                   init.lua + lua/{config,plugins}/
├── tmux/tmux.conf
├── direnv/direnv.toml
├── ssh/config.personal     the github-personal host alias, appended by install.sh
├── git/                    gitconfig, personal identity, global ignore, template
├── karabiner/              the whole ~/.config/karabiner directory
├── gh-dash/config.yml
├── asdf/tool-versions
├── bat/  lazygit/  yazi/  atuin/
└── macos/defaults.sh
```

What's symlinked where (see `install.sh` for the exact list): `.zshenv` and
`.zshrc` to `~/`; `git/gitconfig` to `~/.gitconfig`; `asdf/tool-versions` to
`~/.tool-versions`; everything else under its matching name in
`$XDG_CONFIG_HOME` (`~/.config`), except `karabiner/`, which is symlinked as
a whole directory (Karabiner rewrites `karabiner.json` in place, which would
break a symlink to just that file).

`theme` generates files that live outside this repo and are never
committed: `~/.config/theme`, `theme-nvim`, `theme-env.sh`, `fzf-theme.sh`,
`prompt-theme.zsh`, `git/delta-theme.conf`, `tmux/theme.conf`, and
`lazygit/theme.yml`.

---

## zsh

Five files, loaded in numeric order by `.zshrc`, and that order is
load-bearing, not cosmetic:

```
.zshenv → .zshrc → zsh/00-env → 10-shell → 20-prompt → 30-tools → 40-shell → ~/.zshrc.local
```

`00-env` sets PATH before anything later uses it. `30-tools` loads
fast-syntax-highlighting last of all, because it wraps whatever ZLE widgets
already exist (fzf's, atuin's), so it has to see them first.

Key bindings include emacs-style line editing, and up/down arrow do a plain
prefix history search (type `up`, press up, get the last command that
started with `up`).

Plugins, sourced directly with no framework: `fzf-tab` (fzf-driven
completion menu with previews), `zsh-autosuggestions`, `you-should-use` (in
reminder mode; `YSU_HARDCORE` is deliberately left unset, see the comment in
`30-tools.zsh` for why setting it to `0` is actually worse), and
`fast-syntax-highlighting`.

`zsh/vendor/omz-git.zsh` is oh-my-zsh's git plugin, vendored (MIT,
attributed) rather than pulled in through the framework: it's 196 aliases
and 12 functions of muscle memory, with no framework overhead.

Don't remember which file something is in? Ask:

```sh
zwhere gcb          # alias -> vendor/omz-git.zsh:189
zwhere rgi          # function -> zsh/40-shell.zsh:249
zwhere EDITOR        # export -> .zshenv:17
```

### The prompt

Pure zsh, no starship, no fork to draw it. Two lines: path and git status on
top, a caret on the bottom that turns red on a non-zero exit.

- **Path shortening**: each parent directory collapses to the shortest
  prefix still unique among its siblings, and the current directory is
  always shown in full. Recomputed on `cd` or a resize, not per prompt.
- **Async git**: a single `git status --porcelain=v2 --branch` runs in a
  background subshell, read back with `zle -F`, so a slow repo never
  blocks the terminal.
- **Duration**: a command that took over 2 seconds gets its elapsed time in
  `RPROMPT`.
- **Transient prompt**: once a command is submitted, its prompt collapses
  to a bare caret, so only the current prompt carries the path and git
  state.
- `PROMPT_SUBST` is deliberately off (see the comment at the top of
  `20-prompt.zsh` for the bug that caused).

### Startup speed

| Was | Fix |
|-|-|
| starship (one fork per prompt) | pure-zsh prompt, git status async |
| oh-my-zsh framework | removed; four plugins sourced directly |
| `eval "$(brew shellenv)"` | Homebrew's prefix hardcoded in `00-env.zsh` |
| `nvm which` / `python -m site` / `go env GOPATH` at startup (~400ms) | hardcoded in `00-env.zsh`; `dotfiles-doctor` flags a stale path |
| five `eval "$(tool init zsh)"` calls (~150ms) | `_zcache` caches the output, regenerates when the binary is newer |
| `nvm.sh` sourced eagerly (~370ms) | lazy: only sourced the first time `nvm` is actually called |
| gcloud completion (~240ms) | lazy: loads on the first tab-completion |
| `compinit` full security audit | once per ~20 hours, then a bytecode-compiled cache |
| direnv hook forking on every prompt (~17ms) | only runs the real hook when an `.envrc` is at or above `$PWD` |
| `git rev-parse --git-dir` to find the repo root | a stat walk instead |
| three git execs for branch, status, and stash | one `git status --porcelain=v2 --branch` exec |
| `$(...)` subshells for small string results | `$REPLY` returns instead, no fork |
| Apple's `/usr/bin/git` shim (140ms+ cold, Xcode lookup) | Homebrew's `git` on PATH instead |

Result: shell startup went from 2.4s to about 0.07s, and median prompt
render time from 20.7ms to 3.7ms.

One thing that was tried and deliberately NOT kept: `zcompile`-ing the
completion dump measured slower (85 to 93ms), not faster, so it stays
plain-parsed. Neovim itself isn't part of shell startup, but it follows the
same philosophy: `lazy.nvim` loads plugins on demand rather than eagerly,
for a startup time of about 40ms.

Measure it yourself:

- `timezsh`: three real startup runs
- `profzsh`: `ZSH_PROFILE=1 zsh -i -c exit`, which line is slow
- `prompt-watch on [ms]` / `log` / `off` / `clear`: logs any prompt slower
  than the threshold, with the directory, to catch an intermittent stall
- `dotfiles-doctor`: checks every hardcoded path, symlink, and binary,
  prints startup time
- `hyperfine`: general-purpose benchmarking, if you want more than
  `timezsh` gives you

---

## Neovim

Neovim 0.12, plain `lazy.nvim` (not LazyVim). `nvim/lazy-lock.json` pins
every plugin version and is committed. Plugins are grouped by concern under
`nvim/lua/plugins/`.

- **Treesitter** is pinned to the `main` branch, not `master`: `master` is
  archived and throws a Lua error opening a markdown buffer on Neovim 0.12.
  `main` compiles grammars by shelling out to the standalone `tree-sitter`
  CLI (in the Brewfile as `tree-sitter-cli`; deliberately not the npm
  package, which disappears on a node version switch).
- **LSPs** (mason-managed, via `vim.lsp.config`/`vim.lsp.enable`): `lua_ls`,
  `basedpyright`, `ruff`, `ts_ls`, `gopls`, `jsonls`, `yamlls`, `bashls`,
  `dockerls`, `taplo`. `install.sh` runs `MasonInstall` for all of them, so
  they're ready on first use rather than installing the first time you open
  a matching file.
- **Formatters** (via conform.nvim, format-on-save): `stylua`, `ruff`,
  `prettierd`, `gofumpt`, `goimports`, `shfmt`.
- **Theme**: `nvim/lua/config/theme.lua` is the single source of truth,
  reading `~/.config/theme` (written by the `theme` command). `:ThemeReload`
  re-applies it, `:TransparencyToggle` flips whether Ghostty's translucent
  background shows through. Transparent is the default, so most highlight
  groups have their background stripped after every colorscheme change.
- **Markdown reading mode**: `<leader>mt` toggles the in-buffer render,
  `<leader>mp` opens a synced preview pane, `<leader>mg` opens the file in
  `glow` in a floating terminal, `<leader>mz` is a centred zen reader.
  Prose filetypes (markdown, gitcommit, text) wrap like a document; spell
  stays off in markdown by default (`<leader>us` toggles it, since
  technical docs are full of identifiers that read as false positives).
- **Main keymaps**: leader is space; `space space` finds files, `space f g`
  live-greps the project, `space e` toggles the file tree, `-` opens the
  current directory as a buffer (oil.nvim), `space g g` opens lazygit full
  screen, `space g d` opens diffview, `s`/`S` are flash jumps. Full list in
  [CHEATSHEET.md](CHEATSHEET.md).

## Ghostty

Custom theme, Material Ocean Bright (in `ghostty/themes/`): Material
Ocean's near-black background, with the foreground text lifted from 6.1:1
to about 13.5:1 contrast, since the original was hard to read at a glance.
Font is FiraCode Nerd Font Mono at size 14, with Symbols Nerd Font Mono as
an icon fallback for glyphs FiraCode doesn't have. Background opacity 0.88
with a blur radius of 20, and 16 MiB of scrollback.

`notify-on-command-finish` pops a notification when a long command finishes
in a window you're not looking at. The quick terminal (`` cmd+` ``) is bound
globally, so it drops down from any app. Splits and tabs match iTerm/Warp
muscle memory; the full list is in the cheatsheet.

`cmd+backspace` is deliberately left at Ghostty's own default (`\x15`, kill
to the start of the line): an earlier override only worked inside this
zsh config and did nothing in Claude Code, nvim's command line, or any
other REPL.

## cmux

A vertical workspace sidebar that embeds Ghostty. It reads
`~/.config/ghostty/config` for font, size, opacity, blur, and keybindings,
so `cmux/cmux.json` only carries cmux's own chrome (sidebar behaviour,
dashboard settings, the one keybinding that diverges from Ghostty). Because
cmux keeps its own theme override outside of Ghostty's config, `theme` runs
`cmux themes clear` plus `cmux reload-config` on every switch, so the two
can't drift apart.

## tmux

For sessions that need to survive an ssh disconnect or a reboot; local work
uses Ghostty splits instead. Prefix is `ctrl+a`. Includes popups (a scratch
shell, lazygit, yazi), TPM-managed plugins (session persistence via
`tmux-resurrect`/`tmux-continuum`, `vim-tmux-navigator` for ctrl+hjkl across
tmux and nvim panes).

## Theme system

```sh
theme                    pick a theme interactively
theme nord               switch straight to it
theme list               show what's available
theme current            print the active theme
```

Seven themes, each a single file in `themes/*.sh`: `tokyonight-storm`,
`oceanic-next`, `nord`, `kanagawa-wave`, `material-ocean`,
`material-ocean-bright`, `catppuccin-macchiato`. `bin/theme` reads one of
those and rewrites Ghostty, Neovim, the prompt, bat, fzf, delta, tmux, and
lazygit together, reloading whichever of them are already running.

One quirk worth knowing: switching themes edits the `theme = ` line
directly inside the tracked `ghostty/config`, so a theme switch shows up as
a one-line git diff in this repo.

## git

`delta` for side-by-side diffs, `difftastic` as the diff/merge tool for
structural comparisons, `zdiff3` conflict markers (shows the common
ancestor), `rerere` (remembers conflict resolutions and replays them),
`fsmonitor` (watches the filesystem instead of stat-ing every file on a
big repo), autostash-and-rebase on pull, and a commit template
(`git/gitmessage`).

**Two GitHub accounts, no interference.** The work identity is the default
everywhere, and it lives outside this repo in `~/.gitconfig.local`, so no
email address is ever committed. The personal identity in
`git/gitconfig-personal` applies only inside `~/.dotfiles/` and
`~/personal/`, via `includeIf "gitdir:"` in `git/gitconfig`, and pushes
over the `github-personal` SSH alias (`ssh/config.personal`) with a
separate key, so the work SSH key and the personal one never cross paths.

## lazygit

Configured via `LG_CONFIG_FILE`, which points at two files at once
(`lazygit/config.yml` plus the generated theme file): it's merged in, not
symlinked.

## Other tools

- **atuin**: SQLite-backed shell history (`ctrl+r`). `history_filter` in
  `atuin/config.toml` keeps anything that looks like a key, token, or
  password out of the database in the first place.
- **fzf**, **bat**, **yazi**: the fuzzy-finding, file-reading, and
  file-browsing layer; see the cheatsheet for keys.
- **direnv**: `load_dotenv = false` in `direnv/direnv.toml`, on purpose. A
  plain `.env` is config for the application, not the shell, and the
  default of `true` meant seven different repos were printing a "blocked"
  error on every single prompt.
- **Karabiner**: one rule, tap left-shift-then-right-shift to toggle caps
  lock. The whole `~/.config/karabiner/` directory is symlinked (see
  Layout above for why).
- **gh-dash**: a GitHub CLI extension (`gh extension install
  dlvhdr/gh-dash`), not a Homebrew formula, hence it's not in the Brewfile.
  Its sections all filter on `@me`, so the config has nothing private in
  it.
- **asdf**: `asdf/tool-versions` pins a global Python version.
- **macos/defaults.sh**: optional, reversible (each line's default is in a
  comment). Sets keyboard repeat rate, disables the "helpful" text
  substitutions, speeds up window animations, sets Dock autohide with no
  delay, shows hidden files and path bar in Finder, sets the screenshot
  location and format, and turns on trackpad tap-to-click.

## Workflow helpers

- `sp [create|list] ...`: create (or pick) a spawnpoint workspace and cd
  into it.
- `spt`: `sp`, then open the new workspace as a T3 Code thread (`spt ls`
  picks an existing one instead of creating).
- `t3open [dir]`: open a directory (default: cwd) as a new T3 Code thread,
  adding the project first if it's new, and starting the app if it isn't
  running.
- `t3`: the CLI the T3 Code app ships. A standalone `t3` on PATH wins if
  one is installed.
- `wt`: git worktree automation, if `~/Developer/worktree-automate` exists.
- `changes`: the diffity workspace diff viewer, if a local build exists.
- `ca`: alias for `clias`, if installed.
- `aws login` / `awssync`: a thin wrapper so `aws login` always signs in
  a dedicated profile and then syncs those temporary keys into a second
  profile for tools that can't run a login session themselves. Needs
  `~/.aws/config`, which is private and not in this repo.
- `cheat`: print this cheatsheet.
- `zwhere <name>`: which file defines this alias, function, or variable.
- `y`: yazi, and the shell follows you to wherever you quit it.
- `rgi [query]`: live ripgrep across the repo, enter jumps nvim to that
  line.
- Also in `zsh/40-shell.zsh`: `mkcd`, `up [n]`, `d [project]`, `c <file>`
  (copy contents to clipboard), `backup <file>`, `extract <archive>`,
  `fkill`, `fco`, `fshow`, `fenv`, `als`, `gprune`, `groot`, `gclone`,
  `serve [port]`, `genpass [len]`, `jsonf <file>`, `mman <cmd>`.

## Maintenance

- `dotfiles-doctor`: checks every hardcoded path in `00-env.zsh`, every
  symlink, every expected binary, and prints startup time.
- `bin/prompt-selftest`: exercises every branch of the prompt (every
  duration bucket, every path-shortening width, every git state) and fails
  loudly. Run it after editing `zsh/20-prompt.zsh`.
- `bin/scrub-history`: scans `~/.zsh_history`, the zsh state history file,
  and the atuin database for secret-shaped strings. `--scan` (the default)
  only counts them; `--apply` redacts them and backs up the originals
  first. Rotating an exposed key still comes first: redaction doesn't undo
  a leak that's already in a backup snapshot somewhere.
- `bdump`: rewrites the Brewfile from whatever's actually installed. It
  overwrites the curated, commented one in this repo, so review the diff
  before committing.

---

## Not in this repo, on purpose

- `~/.zshrc.local`, machine-private aliases and secrets, sourced last
- `~/.gitconfig.local`, the default git identity (name and email)
- `~/.aws/`, AWS profiles and credentials
- `~/.ssh/` keys and the rest of `~/.ssh/config` (this repo only appends
  one host block)
- Claude Code's own config (`~/.claude/`), which is work-specific
- Theme files `theme` generates (see Layout above)
- Plugin clones (`fzf-tab`, `zsh-you-should-use`, tmux's TPM plugins,
  Neovim's `lazy.nvim` plugins): `install.sh` clones or syncs them, but
  the checkouts themselves aren't tracked
