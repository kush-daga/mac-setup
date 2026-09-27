# Cheatsheet

Read this any time with `cheat`. Layer by layer, outermost first.

---

## Ghostty (the terminal) — `cmd` keys

Splits are the fast path. Tabs are for separate contexts.

| Key | Action |
|-|-|
| `cmd+d` | split right |
| `cmd+shift+d` | split down |
| `cmd+alt+←↑↓→` | move focus between splits |
| `cmd+[` / `cmd+]` | previous / next split |
| `cmd+shift+enter` | zoom this split full-window (toggle) |
| `cmd+ctrl+←↑↓→` | resize the split |
| `cmd+alt+=` | make all splits equal |
| `cmd+w` | close split (or tab, if it's the last split) |

| Key | Action |
|-|-|
| `cmd+t` | new tab |
| `cmd+shift+[` / `cmd+shift+]` | previous / next tab |
| `ctrl+tab` | next tab |
| `cmd+shift+\` | tab overview (grid of all tabs) |
| `cmd+shift+i` | rename this tab |
| `cmd+n` | new window |
| `cmd+enter` | fullscreen |
| `cmd+` `` ` `` | drop-down quick terminal (works from any app) |

Ghostty has no vertical/sidebar tabs — tabs are top-only, and there is no
config option for it in 1.2.3. For a vertical list of workspaces use
`ctrl+a w` in tmux, or lean on splits (`cmd+d`) instead of tabs.

| Key | Action |
|-|-|
| `cmd+↑` / `cmd+↓` | jump to the previous / next shell prompt |
| `cmd+home` / `cmd+end` | top / bottom of scrollback |
| `shift+pgup` / `shift+pgdn` | page through scrollback |
| `cmd+f` | search the scrollback |
| `cmd+g` / `cmd+shift+g` | next / previous match |
| `cmd+e` | search for the current selection |
| `esc` | end search |
| `cmd+k` | clear the screen |
| `cmd+shift+s` | dump the whole scrollback into nvim |
| `cmd+shift+,` | reload the Ghostty config |
| `cmd+ +` / `cmd+ -` / `cmd+0` | font bigger / smaller / reset |

---

## Shell

### Line editing
| Key | Action |
|-|-|
| `ctrl+a` / `ctrl+e` | start / end of line |
| `alt+←` / `alt+→` | back / forward one word |
| `alt+backspace` | delete the previous word |
| `cmd+backspace` | kill to the start of the line (same as `ctrl+u`) |
| `cmd+delete` | delete to the end of the line |
| `cmd+←` / `cmd+→` | start / end of line |
| `ctrl+u` | delete to the start of the line (readline standard) |
| `ctrl+k` | delete to the end of the line |
| `alt+.` | insert the last argument of the previous command |
| `ctrl+x ctrl+e` | open the current line in nvim, run it on save |
| `ctrl+z` | suspend a job — press again on an empty line to resume it |

### Completion & history
| Key | Action |
|-|-|
| `tab` | fzf completion menu with a live preview pane |
| `<` / `>` | inside the menu: cycle completion groups |
| `→` | accept one character of the greyed-out suggestion |
| `ctrl+space` | accept the whole suggestion |
| `ctrl+r` | atuin — full history search |
| `↑` | plain prefix search through history |
| `ctrl+t` | fzf file picker → inserts the path into your command line |
| `alt+c` | fzf directory picker → cd there |
| `**` + `tab` | fuzzy-complete any path mid-command |

### Getting around
| Command | What it does |
|-|-|
| `z <part-of-name>` | jump to a directory you've visited before |
| `zi` | pick from that list interactively |
| `d [project]` | go to `~/Developer[/project]` |
| `..` `...` `....` | up 1 / 2 / 3 levels |
| `up 4` | up 4 levels |
| `-` | back to the previous directory |
| `y` | yazi file manager — the shell follows you out |

### Workspaces
| Command | What it does |
|-|-|
| `sp` | create a spawnpoint workspace and cd into it |
| `spt` | `sp`, then open the new workspace as a T3 Code thread |
| `t3open [dir]` | open a directory (default: cwd) as a T3 Code thread |
| `t3` | the CLI bundled in the T3 Code app |

---

## Reading and finding things

| Command | What it does |
|-|-|
| `cat file` | syntax-highlighted, line-numbered (this is `bat`) |
| `catp file` | plain — no numbers, no border, good for copying |
| `md README.md` | render markdown, paged |
| `l` / `ll` / `la` | list: long / long+git / everything |
| `lt` / `lt3` | tree, 2 or 3 levels deep |
| `f` | fuzzy-find a file and open it in nvim |
| `rgi [query]` | **live grep the whole repo** — enter jumps nvim to that line |
| `rg pattern` | ripgrep, smart-case, includes hidden files |
| `ff name` | find files by name |
| `als [word]` | search your own aliases |
| `t <command>` | `tldr` — the short version of a man page |
| `mman <cmd>` | man page with syntax colouring |

Global pipe shortcuts: `cmd B` pages through bat, `cmd L` through less,
`cmd J` pretty-prints JSON, `cmd C` copies to the clipboard, `cmd N` silences it.

---

## Git

`gg` opens **lazygit** — stage hunks, rebase, browse. `?` lists its keys.

Alias names match oh-my-zsh's git plugin, so everything you already type
still works even though the framework is gone.

| Alias | Command |
|-|-|
| `gs` / `gst` | short status / full status |
| `ga` / `gaa` / `gapa` | add / add all / add hunk by hunk |
| `gc -m "msg"` | commit, with the diff visible while you write |
| `gca` / `gcam "msg"` | commit all / commit all with a message |
| `gcan` | amend, keep the message |
| `gco` / `gcb <name>` | checkout / checkout a new branch |
| `gcm` | checkout whatever this repo calls its main branch |
| `gsw` / `gswc` | switch / switch and create |
| `gd` / `gds` | diff / diff staged — side-by-side through delta |
| `gdt` | difftool — structural diff via difftastic |
| `glog` / `glga` | log graph, this branch / all branches |
| `gl` / `gpl` | pull / pull rebasing and autostashing |
| `gp` / `gpf` / `gpsup` | push / force-with-lease / push and set upstream |
| `gf` / `gfa` | fetch / fetch all and prune |
| `grb` / `grbi` / `grbc` / `grba` | rebase / interactive / continue / abort |
| `gr` / `gra` | remote / remote add |
| `gsta` / `gstp` | stash / pop |
| `gundo` | undo the last commit, keep the changes |
| `gnuke` | throw away everything uncommitted |
| `gabs` | fold staged fixups into the commits they belong to |

Fuzzy pickers: `fco` checkout a branch, `fshow` browse commits with full
patches. Inside a delta diff, `n` / `N` jump between files.

**Identity:** work email is the default everywhere. `~/.dotfiles` and
`~/personal/` use the personal identity automatically.

---

## Neovim

Leader is `space`. `space` then wait — which-key shows every option.

| Key | Action |
|-|-|
| `space space` | find files |
| `space f g` | live grep the project |
| `space f w` | grep the word under the cursor |
| `space f b` | switch buffer |
| `space f r` | recent files |
| `space s r` | find and replace across the project |
| `space s w` | find and replace the word under the cursor |
| `space s f` | find and replace in this file only |

**Inside any picker** the input line owns your keys, so `j`/`k` type into the
query. Move the list with these instead:

|-|-|
| `ctrl+j` / `ctrl+k` | down / up one result |
| `ctrl+f` / `ctrl+b` | half page down / up |
| `alt+j` / `alt+k` | scroll the preview pane |
| `ctrl+g` | in live grep: stop re-running ripgrep and fuzzy-filter the results you already have |
| `ctrl+q` | send every result to the quickfix list, where real vim motions work |
| `tab` | multi-select |
| `ctrl+u` | clear the query |
| `space e` | file tree sidebar |
| `-` | edit the current directory as a buffer (oil) |
| `space g g` | lazygit, full screen |
| `space g d` | diff view |
| `space x x` | all diagnostics |
| `K` | hover docs |
| `g r d` / `g r r` | go to definition / references |
| `g r n` / `g r a` | rename / code action |
| `s` | flash — jump anywhere on screen |
| `shift+h` / `shift+l` | previous / next buffer |
| `space q l` | restore the last session |

Markdown files render in place — headings, tables, checkboxes, code blocks.

| Key | Action |
|-|-|
| `space m t` | toggle the in-buffer render for this markdown file |
| `space m p` | preview pane, fully rendered, cursor stays in sync |
| `space m g` | open in `glow`, in a floating terminal |
| `space m z` | zen reader mode: centred, no side columns |
| `space u s` | toggle spellcheck |

---

## tmux — for sessions that must survive

Local work doesn't need it; use Ghostty splits. Reach for tmux over ssh,
or when a session has to outlive the terminal. Prefix is `ctrl+a`.

| Key | Action |
|-|-|
| `tm` | attach to the `main` session, creating it if needed |
| `ctrl+a │` / `ctrl+a -` | split vertical / horizontal |
| `alt+←↑↓→` | move between panes, no prefix needed |
| `ctrl+a h/j/k/l` | move between panes |
| `ctrl+a H/J/K/L` | resize (hold the key to repeat) |
| `ctrl+a z` | zoom this pane |
| `ctrl+a c` | new window |
| `alt+1`…`alt+5` | jump to window 1–5 |
| `ctrl+a w` | tree of all windows — the closest thing to a tab sidebar |
| `ctrl+a W` | tree of all sessions |
| `ctrl+a s` | fzf session picker |
| `ctrl+a g` | lazygit in a popup |
| `ctrl+a e` | yazi in a popup |
| `ctrl+a t` | scratch shell in a popup |
| `ctrl+a u` | pick any URL on screen and open it |
| `ctrl+a O` | send the scrollback to nvim |
| `ctrl+a enter` | copy mode — `v` select, `y` copy, `/` search |
| `ctrl+a r` | reload the tmux config |
| `ctrl+a ?` | every keybinding |

Sessions save every 10 minutes and restore themselves after a reboot.

---

## cmux

cmux embeds Ghostty and reads `~/.config/ghostty/config` for font, size,
ligatures, transparency, blur and keybindings — so there is nothing to
duplicate. Change the Ghostty config, then `cmux reload-config`.

The theme is the one exception: cmux keeps its own override, which is why it
was still rendering Kanagawa Wave while the Ghostty config said TokyoNight
Storm. `theme <name>` now sets both and reloads cmux in place.

| Key | Action |
|-|-|
| `cmd+b` | toggle the vertical workspace sidebar |
| `cmd+n` | new workspace (a sidebar entry) |
| `cmd+1`…`cmd+9` | select workspace |
| `ctrl+cmd+[` / `]` | previous / next workspace |
| `cmd+t` | new surface (a tab inside the pane) |
| `ctrl+1`…`ctrl+9` | select surface |
| `cmd+shift+[` / `]` | previous / next surface |
| `cmd+d` / `cmd+shift+d` | split right / down — same as Ghostty |
| `cmd+alt+←↑↓→` | move focus between panes — same as Ghostty |
| `cmd+shift+enter` | zoom the pane — same as Ghostty |
| `cmd+enter` | fullscreen (remapped from `cmd+ctrl+f` to match Ghostty) |
| `cmd+shift+p` | command palette |
| `cmd+p` | go to workspace |
| `cmd+shift+,` | reload config |

`cmux config doctor` validates the config. `cmux shortcuts` lists every key.

---

## The prompt

Pure zsh — no starship, no framework, no subprocess to draw it.

**Parents shorten, they don't disappear.** Each parent directory collapses to
the shortest prefix still unique among its siblings, so
`~/Developer/.spawnpoint/workspaces/feat-login/api` becomes
`~/Dev/.s/w/feat-lo/api`. Nothing is lost — `.s` is only `.s` because
nothing else in that directory starts with it. The directory you are actually
in is always shown in full and in bold; the path that got you there sits in a
recessed grey.

If even the shortened form is wider than the pane, whole components drop from
the left behind a `…`. Result recomputes on `cd` or a resize, not per prompt.

**Only the current prompt shows it.** Once you submit a command, its prompt
collapses to a bare `❯`, so the path and git state appear once, at the bottom,
instead of repeating above every result down the scrollback.

**Git status is asynchronous.** The prompt draws instantly and the git segment
lands a moment later, so a slow `git status` in a huge repo can never hold the
terminal.

| Marker | Meaning |
|-|-|
| `+3` | staged |
| `!3` | modified |
| `?3` | untracked |
| `=3` | conflicts |
| `⇡3` / `⇣3` | ahead / behind the remote |
| `$3` | stashes |

A red `❯` means the last command exited non-zero. A duration appears on the
right only for commands that took longer than two seconds.

It all lives in `zsh/20-prompt.zsh`. Colours come from
`~/.config/prompt-theme.zsh`, written by `theme`.

---

## Themes

Seven oceanic schemes. One command switches the terminal, editor, prompt,
diffs, file listings, and multiplexer together.

```
theme                    pick one interactively
theme nord               switch straight to it
theme list               what's available
theme current            what's active
```

`tokyonight-storm` · `oceanic-next` · `nord` · `kanagawa-wave`
`material-ocean` · `material-ocean-bright` · `catppuccin-macchiato`

`material-ocean-bright` is a custom theme, not a Ghostty built-in. It keeps
Material Ocean's near-black `#0f111a` ground but lifts the text from
`#8f93a2` to `#d5dae8` — 6.1:1 contrast to 13.5:1 — and lifts the dim grey
used for comments from 3.5:1 to 5.2:1. The six accent hues are unchanged, so
syntax highlighting looks identical. It lives in `ghostty/themes/`.

Note: cmux cannot be told to use a custom theme (`cmux themes set` only
knows Ghostty's built-ins). `theme` clears cmux's override instead, so cmux
resolves the theme from the Ghostty config, which does support custom ones.

After switching: `reload` in each shell, `cmd+shift+,` in Ghostty,
`:ThemeReload` in any open nvim.

---

## Maintenance

| Command | What it does |
|-|-|
| `dotfiles-doctor` | check every path, symlink, and binary; print startup time |
| `reload` | restart the shell |
| `timezsh` | measure startup, three runs |
| `profzsh` | which lines are slow |
| `dots` | cd to `~/.dotfiles` |
| `vd` | open the dotfiles repo in nvim |
| `bu` | update everything from Homebrew |
| `bdump` | rewrite the Brewfile from what's installed |
| `zwhere <name>` | which file defines this alias, function, or variable |
| `prompt-selftest` | exercise every prompt branch — run after editing the prompt |
| `prompt-watch on` | log any prompt slower than 400ms, to catch an intermittent stall |
| `prompt-watch log` | show what it caught |
| `scrub-history --scan` | find API keys and tokens sitting in your shell history |
| `scrub-history --apply` | redact them (backs up the originals first) |

Work-specific things and secrets live in `~/.zshrc.local`, which is never
committed. Everything else is in `~/.dotfiles`.
