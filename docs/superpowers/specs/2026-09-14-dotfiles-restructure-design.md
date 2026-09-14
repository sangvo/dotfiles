# Dotfiles restructure and one-command bootstrap — Design

- Date: 2026-09-14
- Branch: `mac` (GitHub default branch; repository is **public**)
- Targets: macOS (Apple Silicon) and Ubuntu 24.04 LTS desktop with sudo

## Goals

1. Keep only the configs in daily use: zsh, nvim, wezterm, git, ssh — plus mise tool versions,
   which the bootstrap needs to install node/ruby/go/pnpm.
2. A single command sets up a fresh macOS or Ubuntu 24.04 machine.
3. Nothing machine-specific, company-specific or secret is committed (the repo is public).
4. Re-running the bootstrap is safe and converges to the same state.

## Non-goals

- Other distros, headless servers, machines without sudo.
- Encrypted secrets (age/sops/git-crypt).
- Rewriting git history (fonts etc. stay in history; removal is a normal commit).
- Uninstalling packages on existing machines (the Brewfile only affects what gets installed).
- Deleting old remote branches (`linux`, `master`, feature branches).

## Decisions

| Topic | Decision |
|---|---|
| Branches | One branch (`mac`) for both OSes; the script detects the OS |
| Linking | GNU stow, driven by `bootstrap.sh` |
| Ubuntu packages | apt for the base system, mise for CLI tools as prebuilt binaries |
| Secrets / company data | Kept in untracked local files; repo ships templates only |
| Removing old configs | A normal commit, no history rewrite |
| Brewfile | Curated by actual usage (zsh history + app last-used dates) |
| git `push.default` | `matching` → `simple`, plus `push.autoSetupRemote = true` |
| Editor | `vim` → `nvim` (git `core.editor` and `$EDITOR`) |

## Repository layout

```
dotfiles/
├── bootstrap.sh
├── lib/
│   ├── common.sh
│   ├── macos.sh
│   └── ubuntu.sh
├── Brewfile
├── packages/
│   ├── apt.txt
│   └── mise-linux.toml
├── config/                     # each directory is a stow package mirroring $HOME
│   ├── zsh/                    # .zshrc, .config/zsh/{zsh-core,zsh-fzf,zsh-export-path}.zsh
│   ├── nvim/                   # .config/nvim
│   ├── wezterm/                # .config/wezterm
│   ├── git/                    # .gitconfig, .gitignore_global, .gitmessage, .config/git/personal
│   ├── ssh/                    # .ssh/config (shared part only)
│   └── mise/                   # .config/mise/config.toml
├── templates/
│   ├── gitconfig.local
│   ├── git-company
│   └── ssh-company
├── docs/superpowers/specs/     # this document
├── .gitignore
└── README.md
```

### Removed

- Directories: `fonts/`, `wallpapers/`, `screenshots/`, `postgresql/`, `.ctags.d/`, `scripts/`, and `.config/`
  (only three tracked symlinks left over from the old layout: `kitty`, `xinit`, `zsh`)
- Files: `hyperfine_1.16.1_amd64.deb`, `hyperfine-packer.out`, old `install.sh`, root symlinks `.xinitrc` and `.zshrc`
- Configs: `alacritty`, `tmux`, `kitty`, `vm`, `xinit`, `ulauncher`, `mpd`, `ncmpcpp`, `flameshot`, `fontconfig`, `gnupg`, `vim-server`
- Renamed: `config/gitconfig` → `config/git`, `config/sshconfig` → `config/ssh`
- Git: `.gitattributes` and the `railsschema` / `bundlelock` merge drivers (never active: `core.attributesfile` is unset)

## Components

### `bootstrap.sh`

Entry point. Usage on a new machine:

```sh
bash -c "$(curl -fsSL https://raw.githubusercontent.com/sangvo/dotfiles/mac/bootstrap.sh)"
```

- `DOTFILES_DIR` defaults to `~/workspace/dotfiles`. If it is missing, clone over HTTPS
  (no SSH key needed yet), then re-exec the script from the clone.
- Flag `--links-only`: skip package installation, only do steps 4–7 below.
- `set -euo pipefail`; every step logs a header; a failure stops with the step name.

Order:

1. Detect OS: `uname -s` = Darwin → `lib/macos.sh`; `/etc/os-release` `ID=ubuntu` → `lib/ubuntu.sh`; anything else → exit with an error.
2. Install packages (OS-specific, below).
3. Install mise tools: `mise install` (reads `~/.config/mise/config.toml` and, on Ubuntu, `conf.d/linux.toml`).
4. Install zsh plugins.
5. Link packages with stow.
6. Create local files from templates and migrate the old SSH config.
7. Set zsh as login shell (interactive runs only); run `nvim --headless "+Lazy! sync" +qa`.

### `lib/common.sh`

| Function | Behaviour |
|---|---|
| `log`, `warn`, `die` | Prefixed output; `die` exits 1 |
| `backup_path <path>` | Moves a real file/dir to `~/.dotfiles-backup/<timestamp>/<path relative to $HOME>` |
| `clean_stale_links` | Removes symlinks in `~`, `~/.config`, `~/.ssh` (depth 1) that point into `$DOTFILES_DIR` and no longer resolve (e.g. old `config/gitconfig/*` links) |
| `stow_packages` | For each package: dry run (`stow -n -v`), back up every conflicting real target, then `stow --restow`. Packages `zsh`, `git`, `ssh`, `mise` use `--no-folding`; `nvim`, `wezterm` may fold |
| `install_zsh_plugins` | `git clone --depth 1` into `~/.local/share/zsh/plugins/<name>` if missing: zsh-defer, zsh-autosuggestions, zsh-syntax-highlighting, zsh-z |
| `setup_local_files` | Copy templates if the target does not exist: `~/.gitconfig.local`, `~/.config/git/company`, `~/.ssh/config.d/` (700) with `company` example commented out; create `~/.ssh/sockets` (700) |
| `migrate_ssh_config` | If `~/.ssh/config` is a regular file (not our symlink): move it to `~/.ssh/config.d/legacy` (600) before stowing |
| `set_default_shell` | If `$SHELL` is not zsh and stdin is a TTY: `chsh -s "$(command -v zsh)"` |

`--no-folding` is required for `ssh` (and applied to `git`, `mise`, `zsh`): without it, on a machine
with no `~/.ssh`, stow would make `~/.ssh` a symlink into the repo and new private keys would be
created inside the public repository's working tree.

### `lib/macos.sh`

1. `xcode-select --install` if the Command Line Tools are missing; wait until installed.
2. Install Homebrew non-interactively if `brew` is missing; `eval "$(/opt/homebrew/bin/brew shellenv)"`.
3. `brew bundle --file "$DOTFILES_DIR/Brewfile" --no-upgrade`.

### `lib/ubuntu.sh`

1. `sudo -v` once up front.
2. `sudo apt-get update` and install `packages/apt.txt`.
3. WezTerm: add the official apt repository (`apt.fury.io/wez`, key in `/usr/share/keyrings`), install `wezterm`.
4. Fonts: download JetBrains Mono and Nerd Fonts "Symbols Only" release archives into `~/.local/share/fonts`, `fc-cache -f`. Skip if already present.
5. mise: `curl https://mise.run | sh` into `~/.local/bin` if missing.
6. Symlink `packages/mise-linux.toml` to `~/.config/mise/conf.d/linux.toml`.

`packages/apt.txt`: `zsh git curl ca-certificates gnupg unzip build-essential stow xclip fontconfig libssl-dev libyaml-dev zlib1g-dev libffi-dev libreadline-dev`.

`packages/mise-linux.toml` (tools that come from Homebrew on macOS): `neovim lazygit delta fzf ripgrep fd bat lsd direnv btop jq lazydocker`.

Ruby: mise compiles Ruby by default (slow). During implementation, check whether the installed mise
version supports precompiled Ruby; if it does, enable it in `mise-linux.toml`, otherwise keep
compiling (the apt build deps above cover it).

### `Brewfile`

- brew: `neovim mise git git-delta gnupg pinentry-mac stow fzf fd ripgrep bat lsd direnv jq btop curl lazygit lazydocker sshs gitmoji git-quick-stats fastfetch kew thefuck colima docker docker-buildx docker-compose libpq openjdk openssl@3 libyaml`
- cask: `wezterm font-jetbrains-mono font-symbols-only-nerd-font gonhanh rectangle stats thaw appcleaner localsend betterdisplay tolaria numi`

### zsh

- Plugin paths in `.zshrc` and `zsh-core.zsh` change from `~/.config/zsh/<plugin>` to
  `~/.local/share/zsh/plugins/<plugin>`.
- `.gitignore` drops `config/zsh/.config/zsh/**`; the three zsh files become normally tracked.
- `EDITOR` becomes `nvim`.
- Optional tools are guarded with `(( $+commands[<tool>] ))` so a machine without them starts
  cleanly: `thefuck`, `direnv`, `gpgconf`, `mise`, and the `lsd` aliases (fall back to plain `ls`).
- Antigravity's `PATH` entry is kept but only added when the directory exists.

### git

`config/git/.gitconfig` (shared):

- `user.useConfigOnly = true`
- `core.editor = nvim`, `core.excludesfile = ~/.gitignore_global`, `core.pager = delta`
- `commit.template = ~/.gitmessage`
- `push.default = simple`, `push.autoSetupRemote = true`
- `alias.lg`, `[delta]` settings, `interactive.diffFilter`
- `includeIf "gitdir/i:~/workspace/"` → `~/.config/git/personal`
- last line: `[include] path = ~/.gitconfig.local`

`config/git/.config/git/personal`: personal name, email and signing key (already public in commits).

Removed: duplicate `[core]` sections, commented include, `gpg "x509"`, `color.ui = true` and
`commit.gpgsign = false` (both git defaults), merge drivers.

`templates/gitconfig.local` → `~/.gitconfig.local`:
`includeIf "gitdir/i:~/company/"` → `~/.config/git/company`.

`templates/git-company` → `~/.config/git/company`: placeholders for name/email, HTTPS credential
cache helper, `url "git@github.com-work:".insteadOf = "git@github.com:"`. The alias
`github.com-work` must match a `Host` in `~/.ssh/config.d/`.

### ssh

`config/ssh/.ssh/config` (shared):

```
Include ~/.ssh/config.d/*

Host github.com
  HostName github.com
  User git
  IdentityFile ~/.ssh/id_ed25519

Host *
  IgnoreUnknown UseKeychain
  UseKeychain yes
  AddKeysToAgent yes
  IdentitiesOnly yes
  PreferredAuthentications publickey
  IPQoS lowdelay
  ControlMaster auto
  ControlPath ~/.ssh/sockets/%r@%h-%p
  ControlPersist 10m
```

`templates/ssh-company` → `~/.ssh/config.d/company`: commented example `Host github.com-work` block.
Machine-specific entries (company hosts, bastions, personal servers, colima/orbstack `Include`s,
`KexAlgorithms` overrides) live only in `~/.ssh/config.d/`.

## Migrating the current Mac

Existing state: `~/.gitconfig`, `~/.gitconfig_company`, `~/.gitignore_global`, `~/.gitattributes` are
symlinks into `config/gitconfig/`; `~/.zshrc` and `~/.config/zsh` link into `config/zsh`;
`~/.ssh/config` is a regular file that has diverged from the repo; `~/.ssh/config 2` is a stray link;
zsh plugins live inside the repo's ignored `config/zsh/.config/zsh/`.

Steps (done once, before `bootstrap.sh --links-only`):

1. Write `~/.config/git/company` from the current uncommitted `.gitconfig_company`, fixing the
   broken `insteadOf` target (`github.com-<alias>`, which no SSH host defines) to the alias actually
   defined in `~/.ssh/config` for the company GitHub account.
2. Create `~/.gitconfig.local` from the template.
3. Remove the stray `~/.ssh/config 2` link.
4. Run `bootstrap.sh --links-only`: it migrates `~/.ssh/config` to `config.d/legacy`, clones zsh
   plugins to the new path, removes stale links and stows everything.
5. Delete the old plugin clones from `config/zsh/.config/zsh/` after zsh starts cleanly.

Uncommitted changes:

- `config/nvim/.../theme.lua`, `colorscheme.lua`: kept and committed.
- `config/kitty/.../kitty.conf`: dropped (kitty config is removed).
- `config/gitconfig/.gitignore_global` (adds `**/.claude/settings.local.json`): kept and committed
  as `config/git/.gitignore_global`.
- `config/gitconfig/.gitconfig_company`: not committed; its content moves to the local
  `~/.config/git/company` (step 1 above).

## Error handling

- `set -euo pipefail` in every script; `die` reports the failing step.
- Every step checks before acting (`command -v`, file exists, link already correct), so a failed run
  can simply be re-run.
- Nothing is deleted from `$HOME`: conflicting files go to `~/.dotfiles-backup/<timestamp>/`.
- Non-interactive runs (no TTY) skip `chsh`.

## Testing

Prerequisites on this Mac: `shellcheck` (not installed; run via `mise exec shellcheck@latest --`),
`colima start`, and `brew link docker` (the `docker` formula is installed but not linked, so the
CLI is not on `PATH`).

1. `shellcheck bootstrap.sh lib/*.sh`.
2. Ubuntu 24.04 container (`ubuntu:24.04`), non-root user with passwordless sudo, repo copied in:
   run `bootstrap.sh` twice. Assert: stow links exist and `~/.ssh` is a real directory;
   `zsh -i -c exit` prints no errors; `nvim --headless +qa` exits 0;
   `git config --global push.default` = `simple`; `neovim`, `lazygit`, `fzf`, `rg`, `lsd` resolve
   inside `zsh -i`; an interactive session (via `script`) shows no errors after deferred plugins
   load; the second run changes nothing.
3. This Mac: `bootstrap.sh --links-only`. Assert: backups created for replaced files;
   `zsh -i -c exit` clean; `git config user.email` inside `~/workspace/dotfiles` is the personal
   email; `ssh -G` resolves a host from `config.d/legacy`; `wezterm show-keys` loads.
4. First real run on the company Ubuntu machine is manual.
