# dotfiles

zsh, Neovim ([kickstart.nvim](https://github.com/nvim-lua/kickstart.nvim)), WezTerm, git and ssh
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
| `config/<package>` | stow packages mirroring `$HOME`: `zsh`, `nvim`, `wezterm`, `git`, `ssh`, `mise` |
| `Brewfile` | macOS packages |
| `packages/` | Ubuntu apt packages and mise tools |
| `lib/` | bootstrap helpers |
| `tests/` | `bash tests/test_common.sh`; `bash tests/ubuntu-container.sh` (needs Docker) |
