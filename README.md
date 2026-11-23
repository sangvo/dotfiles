# dotfiles

zsh, Neovim ([sangvo/nvim](https://github.com/sangvo/nvim)), WezTerm, Alacritty + tmux, VS Code,
git and ssh config for macOS (Apple Silicon) and Ubuntu 24.04.

## Install

```sh
bash -c "$(curl -fsSL https://raw.githubusercontent.com/sangvo/dotfiles/mac/bootstrap.sh)"
```

The script clones this repo to `~/workspace/dotfiles` (override with `DOTFILES_DIR`), installs
packages (Homebrew + `Brewfile` on macOS; apt + mise on Ubuntu), links configs with GNU stow and
installs zsh, tmux and Neovim plugins. Re-running it is safe; files it replaces are moved to
`~/.dotfiles-backup/<timestamp>/`.

Relink configs only:

```sh
~/workspace/dotfiles/bootstrap.sh --links-only
```

## Machine-local config (not in git)

| File | Purpose |
|---|---|
| `~/.gitconfig.local` | Included last by `~/.gitconfig` |
| `~/.config/git/company` | Identity for repositories under `~/company/` |
| `~/.ssh/config.d/*` | Extra SSH hosts; `legacy` holds a migrated old `~/.ssh/config` |

They are created from `templates/` on first run.

## Layout

| Path | Contents |
|---|---|
| `config/<package>` | stow packages mirroring `$HOME`: `zsh`, `wezterm`, `alacritty`, `tmux`, `fontconfig`, `git`, `ssh`, `mise` |
| `vscode/` | VS Code settings, keybindings and extension list; linked into the OS's VS Code user dir |
| `Brewfile` | macOS packages |
| `packages/` | Ubuntu apt packages and mise tools |
| `lib/` | bootstrap helpers |
| `scripts/` | standalone scripts, not run by `bootstrap.sh` |
| `tests/` | `bash tests/test_common.sh`; `bash tests/ubuntu-container.sh` (needs Docker) |

## Yaak (Ubuntu)

[Yaak](https://github.com/mountain-loop/yaak)'s prebuilt binaries need a paid license for work
use; its MIT source, built yourself, does not. `scripts/build-yaak.sh` installs the build
dependencies, builds a release without the license check and auto-updater, and installs the
resulting `.deb` (replacing a prebuilt Yaak, keeping its data). The build takes a while and keeps
~5 GB of cache in `~/.cache/yaak-src`. Run it again to update:

```sh
~/workspace/dotfiles/scripts/build-yaak.sh             # latest release
~/workspace/dotfiles/scripts/build-yaak.sh v2026.9.1   # a specific tag
```

## Neovim config

The Neovim config lives in its own repository, [sangvo/nvim](https://github.com/sangvo/nvim), a
fork of [kickstart.nvim](https://github.com/nvim-lua/kickstart.nvim). `bootstrap.sh` clones it to
`~/.config/nvim` over HTTPS (backing up anything else already there). Commit and push changes from
that directory; to push over SSH instead:

```sh
git -C ~/.config/nvim remote set-url origin git@github.com:sangvo/nvim.git
```

### Plugins

In Neovim, run `:lua vim.pack.update()`, review the changes in the buffer that opens, then `:write`
to apply them (`:quit` discards). This updates `nvim-pack-lock.json`:

```sh
cd ~/.config/nvim
git commit -m "Update plugins" -- nvim-pack-lock.json
git push
```

LSP servers and tools: `:MasonToolsUpdate`. Treesitter parsers: `:TSUpdate`.

Undo the last plugin update: `git -C ~/.config/nvim checkout HEAD -- nvim-pack-lock.json`, then
`:restart` Neovim and run `:lua vim.pack.update(nil, { offline = true, target = 'lockfile' })`,
confirming with `:write`.

On another machine: `git -C ~/.config/nvim pull`, `:restart` Neovim, then run
`:lua vim.pack.update(nil, { target = 'lockfile' })` and `:write`.

### Upstream kickstart.nvim changes

```sh
cd ~/.config/nvim
git remote add kickstart https://github.com/nvim-lua/kickstart.nvim.git   # once
git fetch kickstart
git merge kickstart/master
```

Resolve conflicts (keep your own changes), `git commit`, check that Neovim starts with
`nvim --headless +qa`, then `git push`. The config from before kickstart moved to `vim.pack` is on
the `lazy-legacy` branch.
