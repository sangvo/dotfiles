# dotfiles

zsh, Neovim ([sangvo/nvim](https://github.com/sangvo/nvim)), WezTerm, git and ssh
config for macOS (Apple Silicon) and Ubuntu 24.04.

## Install

```sh
bash -c "$(curl -fsSL https://raw.githubusercontent.com/sangvo/dotfiles/mac/bootstrap.sh)"
```

The script clones this repo to `~/workspace/dotfiles` (override with `DOTFILES_DIR`), installs
packages (Homebrew + `Brewfile` on macOS; apt + mise on Ubuntu), links configs with GNU stow and
installs zsh and Neovim plugins. Re-running it is safe; files it replaces are moved to
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
| `config/<package>` | stow packages mirroring `$HOME`: `zsh`, `wezterm`, `git`, `ssh`, `mise` |
| `Brewfile` | macOS packages |
| `packages/` | Ubuntu apt packages and mise tools |
| `lib/` | bootstrap helpers |
| `tests/` | `bash tests/test_common.sh`; `bash tests/ubuntu-container.sh` (needs Docker) |

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
