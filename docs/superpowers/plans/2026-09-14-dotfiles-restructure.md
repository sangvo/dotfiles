# Dotfiles Restructure and Bootstrap Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Reduce the dotfiles repo to zsh, Neovim (kickstart.nvim), WezTerm, git, ssh and mise configs, and add a one-command, re-runnable bootstrap for macOS and Ubuntu 24.04.

**Architecture:** `bootstrap.sh` detects the OS, sources `lib/common.sh` plus `lib/macos.sh` or `lib/ubuntu.sh`, installs packages (Homebrew `Brewfile` / apt + mise), then links `config/<package>` into `$HOME` with GNU stow. Machine-local and company data live in untracked files created from `templates/`. Shell helpers are unit-tested with plain bash tests; the Ubuntu path is tested end-to-end in an `ubuntu:24.04` container.

**Tech Stack:** bash, GNU stow, Homebrew bundle, apt, mise, zsh, Neovim 0.12 (`vim.pack`), shellcheck, Docker (colima).

**Spec:** `docs/superpowers/specs/2026-09-14-dotfiles-restructure-design.md` (read its "Amendments" section — it overrides earlier sections).

## Global Constraints

- The GitHub repo is **public**: never commit company names, company hostnames, IPs, emails other than `sangvo111@gmail.com`, or private keys. Company data only goes to `~/.config/git/company` and `~/.ssh/config.d/`.
- Targets: macOS on Apple Silicon (`/opt/homebrew`) and Ubuntu 24.04 LTS desktop with sudo. Nothing else.
- Neovim ≥ 0.12 (kickstart.nvim uses `vim.pack`).
- stow packages `zsh git ssh mise` are stowed with `--no-folding`; `nvim wezterm` may fold.
- zsh plugins live in `~/.local/share/zsh/plugins/<name>`.
- Replaced files are moved to `~/.dotfiles-backup/<timestamp>/`; scripts never delete user files.
- Shell scripts start with `#!/usr/bin/env bash`, pass `shellcheck`, and use `if` blocks (not `[[ … ]] && cmd`) for control flow inside functions so `set -e` behaves predictably.
- Run all commands from `~/workspace/dotfiles` unless a step says otherwise.
- Every commit message ends with a blank line and these two trailers:
  `Co-Authored-By: Claude Opus 5 (1M context) <noreply@anthropic.com>` and
  `Claude-Session: https://claude.ai/code/session_018ywgepRmodAzEUUgUidtfg`.
- Commit only the paths each task lists (`git commit -- <paths>` or explicit `git add`). Do not push.

---

### Task 0: Prepare the working copy

Task 3 renames `config/gitconfig`, which breaks this Mac's `~/.gitconfig` symlink until Task 10 relinks it. Without a user identity git would silently commit as `sangvo@<hostname>`.

**Files:** none tracked (writes `.git/config` only)

- [ ] **Step 1: Set a repo-local commit identity**

```bash
git config user.name sangvo
git config user.email sangvo111@gmail.com
```

- [ ] **Step 2: Verify**

Run: `git config --local --get user.email`
Expected: `sangvo111@gmail.com`

- [ ] **Step 3: Confirm the starting state**

Run: `git status --short`
Expected: only these entries (from before this plan):
```
 M config/gitconfig/.gitconfig_company
 M config/gitconfig/.gitignore_global
 M config/kitty/.config/kitty/kitty.conf
 M config/nvim/.config/nvim/lua/sang/config/theme.lua
 M config/nvim/.config/nvim/lua/sang/plugins/colorscheme.lua
```
If anything else shows up, stop and ask.

---

### Task 1: Test helpers and the file-handling half of `lib/common.sh`

**Files:**
- Create: `tests/lib.sh`
- Create: `tests/test_common.sh`
- Create: `lib/common.sh`

**Interfaces:**
- Produces (in `lib/common.sh`, all read `DOTFILES_DIR`, `HOME`, `BACKUP_DIR`):
  - vars `BACKUP_DIR` (default `~/.dotfiles-backup/<YYYYmmdd-HHMMSS>`), `ZSH_PLUGIN_DIR` (default `~/.local/share/zsh/plugins`), `CURRENT_STEP`
  - `log MSG…`, `warn MSG…`, `die MSG…` (exit 1)
  - `run_step NAME CMD…` — sets `CURRENT_STEP`, logs, runs `CMD…`
  - `backup_path PATH` — moves PATH to `$BACKUP_DIR/<PATH relative to $HOME>`; no-op if missing
  - `clean_stale_links` — removes broken symlinks in `~`, `~/.config`, `~/.ssh` whose target contains the repo path
  - `migrate_ssh_config` — moves a regular `~/.ssh/config` to `~/.ssh/config.d/legacy` (600)
  - `copy_if_missing SRC DEST MODE`
  - `setup_local_files` — creates `~/.ssh/config.d`, `~/.ssh/sockets` (700) and copies the three templates
- Produces (in `tests/lib.sh`): `fail`, `assert_eq ACTUAL EXPECTED`, `assert_file`, `assert_dir`, `assert_missing`, `assert_link_to LINK TARGET`, `assert_mode PATH MODE`, `check DESC CMD…`, `finish`, counters `TESTS_RUN`, `TESTS_FAILED`
- Produces (in `tests/test_common.sh`): `setup_fixture` (fresh `HOME`, fixture repo at `$HOME/workspace/dotfiles`, sources `lib/common.sh`); runner that executes each `test_*` function in its own `bash` process

- [ ] **Step 1: Write the assertion helpers**

Create `tests/lib.sh`:

```bash
#!/usr/bin/env bash
# Tiny assertion helpers shared by the test scripts. Source this file.

TESTS_RUN=0
TESTS_FAILED=0

fail() {
  printf '    %s\n' "$*" >&2
  return 1
}

assert_eq() {
  if [[ $1 != "$2" ]]; then
    fail "expected [$2], got [$1]"
  fi
}

assert_file() {
  if [[ ! -f $1 || -L $1 ]]; then
    fail "expected a regular file: $1"
  fi
}

assert_dir() {
  if [[ ! -d $1 || -L $1 ]]; then
    fail "expected a real directory: $1"
  fi
}

assert_missing() {
  if [[ -e $1 || -L $1 ]]; then
    fail "expected nothing at: $1"
  fi
}

assert_link_to() {
  if [[ ! -L $1 ]]; then
    fail "expected a symlink: $1"
    return 1
  fi
  if [[ "$(realpath "$1" 2>/dev/null)" != "$(realpath "$2")" ]]; then
    fail "expected $1 -> $2, got $(readlink "$1")"
  fi
}

assert_mode() {
  local mode
  mode=$(stat -c %a "$1" 2>/dev/null || stat -f %Lp "$1")
  assert_eq "$mode" "$2"
}

# check DESC CMD...: run CMD as one named check and record the result.
check() {
  local desc=$1
  shift
  TESTS_RUN=$((TESTS_RUN + 1))
  if "$@" >/dev/null; then
    printf 'PASS %s\n' "$desc"
  else
    printf 'FAIL %s\n' "$desc"
    TESTS_FAILED=$((TESTS_FAILED + 1))
  fi
}

finish() {
  printf '\n%d checks, %d failed\n' "$TESTS_RUN" "$TESTS_FAILED"
  [[ $TESTS_FAILED -eq 0 ]]
}
```

- [ ] **Step 2: Write the failing tests**

Create `tests/test_common.sh`:

```bash
#!/usr/bin/env bash
# Unit tests for lib/common.sh.
#   bash tests/test_common.sh
# Each test_* function runs in its own bash process with `set -euo pipefail`, a fresh HOME
# and a fixture repository, so a failing assertion stops only that test.
set -uo pipefail

REPO_ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
# shellcheck source=tests/lib.sh
source "$REPO_ROOT/tests/lib.sh"

setup_fixture() {
  TEST_TMP=$(mktemp -d)
  export TEST_TMP
  export HOME="$TEST_TMP/home"
  export DOTFILES_DIR="$HOME/workspace/dotfiles"
  export BACKUP_DIR="$HOME/.dotfiles-backup/test"
  export ZSH_PLUGIN_DIR="$HOME/.local/share/zsh/plugins"
  local d=$DOTFILES_DIR
  mkdir -p "$d/config/zsh/.config/zsh" "$d/config/git/.config/git" "$d/config/ssh/.ssh" \
    "$d/config/mise/.config/mise" "$d/config/nvim/.config/nvim/lua" \
    "$d/config/wezterm/.config/wezterm" "$d/templates"
  echo '# zshrc' >"$d/config/zsh/.zshrc"
  echo '# core' >"$d/config/zsh/.config/zsh/zsh-core.zsh"
  echo '[core]' >"$d/config/git/.gitconfig"
  echo '[user]' >"$d/config/git/.config/git/personal"
  echo 'Include ~/.ssh/config.d/*' >"$d/config/ssh/.ssh/config"
  echo '[tools]' >"$d/config/mise/.config/mise/config.toml"
  echo '-- init' >"$d/config/nvim/.config/nvim/init.lua"
  echo '-- wezterm' >"$d/config/wezterm/.config/wezterm/wezterm.lua"
  echo '# local' >"$d/templates/gitconfig.local"
  echo '# company' >"$d/templates/git-company"
  echo '# ssh company' >"$d/templates/ssh-company"
  # shellcheck source=lib/common.sh
  source "$REPO_ROOT/lib/common.sh"
}

test_backup_path_keeps_relative_path() {
  mkdir -p "$HOME/.config/app"
  echo old >"$HOME/.config/app/a.conf"
  backup_path "$HOME/.config/app/a.conf"
  assert_missing "$HOME/.config/app/a.conf"
  assert_eq "$(cat "$BACKUP_DIR/.config/app/a.conf")" old
}

test_backup_path_ignores_missing_path() {
  backup_path "$HOME/does-not-exist"
  assert_missing "$BACKUP_DIR"
}

test_clean_stale_links_removes_only_broken_repo_links() {
  mkdir -p "$HOME/.config" "$HOME/.ssh"
  ln -s workspace/dotfiles/config/gitconfig/.gitconfig "$HOME/.gitconfig"
  ln -s ../workspace/dotfiles/config/sshconfig/.ssh/config "$HOME/.ssh/config 2"
  ln -s workspace/dotfiles/config/zsh/.zshrc "$HOME/.zshrc"
  ln -s /nonexistent/elsewhere "$HOME/.config/other"
  clean_stale_links
  assert_missing "$HOME/.gitconfig"
  assert_missing "$HOME/.ssh/config 2"
  assert_link_to "$HOME/.zshrc" "$DOTFILES_DIR/config/zsh/.zshrc"
  if [[ ! -L $HOME/.config/other ]]; then
    fail "an unrelated broken link was removed"
  fi
}

test_migrate_ssh_config_moves_regular_file() {
  mkdir -p "$HOME/.ssh"
  echo 'Host example' >"$HOME/.ssh/config"
  migrate_ssh_config
  assert_missing "$HOME/.ssh/config"
  assert_eq "$(cat "$HOME/.ssh/config.d/legacy")" 'Host example'
  assert_mode "$HOME/.ssh/config.d/legacy" 600
  assert_mode "$HOME/.ssh/config.d" 700
}

test_migrate_ssh_config_leaves_symlink_alone() {
  mkdir -p "$HOME/.ssh"
  ln -s "$DOTFILES_DIR/config/ssh/.ssh/config" "$HOME/.ssh/config"
  migrate_ssh_config
  assert_link_to "$HOME/.ssh/config" "$DOTFILES_DIR/config/ssh/.ssh/config"
  assert_missing "$HOME/.ssh/config.d/legacy"
}

test_migrate_ssh_config_backs_up_when_legacy_exists() {
  mkdir -p "$HOME/.ssh/config.d"
  echo 'Host first' >"$HOME/.ssh/config.d/legacy"
  echo 'Host second' >"$HOME/.ssh/config"
  migrate_ssh_config
  assert_eq "$(cat "$HOME/.ssh/config.d/legacy")" 'Host first'
  assert_eq "$(cat "$BACKUP_DIR/.ssh/config")" 'Host second'
}

test_setup_local_files_creates_without_overwriting() {
  mkdir -p "$HOME/.config/git"
  echo mine >"$HOME/.config/git/company"
  setup_local_files
  assert_eq "$(cat "$HOME/.config/git/company")" mine
  assert_eq "$(cat "$HOME/.gitconfig.local")" '# local'
  assert_eq "$(cat "$HOME/.ssh/config.d/company")" '# ssh company'
  assert_mode "$HOME/.ssh/config.d/company" 600
  assert_mode "$HOME/.ssh/sockets" 700
}

if [[ ${1:-} == --run ]]; then
  set -euo pipefail
  setup_fixture
  "$2"
  exit 0
fi

for name in $(declare -F | awk '{ print $3 }' | grep '^test_'); do
  TESTS_RUN=$((TESTS_RUN + 1))
  if bash "${BASH_SOURCE[0]}" --run "$name" >/dev/null; then
    printf 'PASS %s\n' "$name"
  else
    printf 'FAIL %s\n' "$name"
    TESTS_FAILED=$((TESTS_FAILED + 1))
  fi
done
finish
```

- [ ] **Step 3: Run the tests to verify they fail**

Run: `bash tests/test_common.sh`
Expected: every test prints `FAIL` (stderr shows `lib/common.sh: No such file or directory`), last line `7 checks, 7 failed`, exit code 1.

- [ ] **Step 4: Write the implementation**

Create `lib/common.sh`:

```bash
#!/usr/bin/env bash
# Helpers shared by bootstrap.sh. Source this file; it expects DOTFILES_DIR to be set.

: "${DOTFILES_DIR:?DOTFILES_DIR must point at the dotfiles checkout}"
BACKUP_DIR="${BACKUP_DIR:-$HOME/.dotfiles-backup/$(date +%Y%m%d-%H%M%S)}"
ZSH_PLUGIN_DIR="${ZSH_PLUGIN_DIR:-$HOME/.local/share/zsh/plugins}"
CURRENT_STEP=""

log() { printf '\033[1;34m==>\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33mwarn:\033[0m %s\n' "$*" >&2; }
die() {
  printf '\033[1;31merror:\033[0m %s\n' "$*" >&2
  exit 1
}

# run_step NAME CMD...: bootstrap.sh's ERR trap reports CURRENT_STEP when CMD fails.
run_step() {
  CURRENT_STEP=$1
  shift
  log "$CURRENT_STEP"
  "$@"
}

# Move a file, directory or symlink under $HOME into $BACKUP_DIR, keeping its relative path.
backup_path() {
  local path=$1 rel dest
  if [[ ! -e $path && ! -L $path ]]; then
    return 0
  fi
  rel=${path#"$HOME"/}
  dest="$BACKUP_DIR/$rel"
  mkdir -p "$(dirname "$dest")"
  mv "$path" "$dest"
  log "backed up ~/$rel to $dest"
}

# Remove broken symlinks in ~, ~/.config and ~/.ssh that point into the repository,
# e.g. links left behind when a package directory is renamed.
clean_stale_links() {
  local dir link target repo_rel
  repo_rel=${DOTFILES_DIR#"$HOME"/}
  for dir in "$HOME" "$HOME/.config" "$HOME/.ssh"; do
    if [[ ! -d $dir ]]; then
      continue
    fi
    while IFS= read -r -d '' link; do
      if [[ -e $link ]]; then
        continue
      fi
      target=$(readlink "$link")
      if [[ $target == *"$repo_rel/"* ]]; then
        rm "$link"
        log "removed stale link ~/${link#"$HOME"/}"
      fi
    done < <(find "$dir" -maxdepth 1 -type l -print0)
  done
}

# Keep a hand-written ~/.ssh/config by moving it to ~/.ssh/config.d/legacy,
# which the shared config includes.
migrate_ssh_config() {
  local cfg="$HOME/.ssh/config" legacy="$HOME/.ssh/config.d/legacy"
  if [[ ! -f $cfg || -L $cfg ]]; then
    return 0
  fi
  mkdir -p "$HOME/.ssh/config.d"
  chmod 700 "$HOME/.ssh" "$HOME/.ssh/config.d"
  if [[ -e $legacy ]]; then
    backup_path "$cfg"
    return 0
  fi
  mv "$cfg" "$legacy"
  chmod 600 "$legacy"
  log "moved ~/.ssh/config to ~/.ssh/config.d/legacy"
}

# copy_if_missing SRC DEST MODE
copy_if_missing() {
  local src=$1 dest=$2 mode=$3
  if [[ -e $dest ]]; then
    return 0
  fi
  mkdir -p "$(dirname "$dest")"
  cp "$src" "$dest"
  chmod "$mode" "$dest"
  log "created ~/${dest#"$HOME"/} from template"
}

# Machine-local files that tracked configs include but that never enter git.
setup_local_files() {
  mkdir -p "$HOME/.ssh/config.d" "$HOME/.ssh/sockets"
  chmod 700 "$HOME/.ssh" "$HOME/.ssh/config.d" "$HOME/.ssh/sockets"
  copy_if_missing "$DOTFILES_DIR/templates/gitconfig.local" "$HOME/.gitconfig.local" 644
  copy_if_missing "$DOTFILES_DIR/templates/git-company" "$HOME/.config/git/company" 600
  copy_if_missing "$DOTFILES_DIR/templates/ssh-company" "$HOME/.ssh/config.d/company" 600
}
```

- [ ] **Step 5: Run the tests to verify they pass**

Run: `bash tests/test_common.sh`
Expected: 7 `PASS` lines, last line `7 checks, 0 failed`, exit code 0.

- [ ] **Step 6: shellcheck**

Run: `mise exec shellcheck@latest -- shellcheck -x lib/common.sh tests/lib.sh tests/test_common.sh`
Expected: no output, exit code 0. (If mise cannot install shellcheck, use `brew install shellcheck` and run `shellcheck -x …`.)

- [ ] **Step 7: Commit**

```bash
git add lib/common.sh tests/lib.sh tests/test_common.sh
git commit -m "bootstrap: add common helpers with tests" -- lib/common.sh tests/lib.sh tests/test_common.sh
```

---

### Task 2: stow linking and zsh plugin install in `lib/common.sh`

**Files:**
- Modify: `lib/common.sh` (append)
- Modify: `tests/test_common.sh` (add tests above the `if [[ ${1:-} == --run ]]` block)

**Interfaces:**
- Consumes: `backup_path`, `log`, `DOTFILES_DIR`, `ZSH_PLUGIN_DIR` from Task 1
- Produces:
  - arrays `NO_FOLD_PACKAGES=(zsh git ssh mise)`, `FOLD_PACKAGES=(nvim wezterm)`, `ZSH_PLUGINS=("<name> <url>" …)`
  - `is_repo_owned PATH PKG` — true if PATH resolves inside `config/PKG`
  - `package_targets PKG fold|no-fold` — prints the `$HOME` paths stow will create
  - `prepare_package PKG fold|no-fold` — backs up blocking targets
  - `stow_packages` — prepares and stows all packages
  - `install_zsh_plugins` — clones missing plugins into `$ZSH_PLUGIN_DIR`

- [ ] **Step 1: Write the failing tests**

Insert into `tests/test_common.sh`, directly above the line `if [[ ${1:-} == --run ]]; then`:

```bash
test_stow_packages_fresh_home() {
  stow_packages
  assert_link_to "$HOME/.zshrc" "$DOTFILES_DIR/config/zsh/.zshrc"
  assert_dir "$HOME/.ssh"
  assert_link_to "$HOME/.ssh/config" "$DOTFILES_DIR/config/ssh/.ssh/config"
  assert_dir "$HOME/.config/git"
  assert_dir "$HOME/.config/mise"
  assert_dir "$HOME/.config/zsh"
  assert_link_to "$HOME/.config/nvim" "$DOTFILES_DIR/config/nvim/.config/nvim"
  assert_link_to "$HOME/.config/wezterm" "$DOTFILES_DIR/config/wezterm/.config/wezterm"
  assert_missing "$BACKUP_DIR"
}

test_stow_packages_backs_up_conflicts() {
  echo old >"$HOME/.zshrc"
  mkdir -p "$HOME/.config/nvim/lua" "$HOME/.config/mise"
  echo old >"$HOME/.config/nvim/init.lua"
  echo old >"$HOME/.config/mise/config.toml"
  stow_packages
  assert_link_to "$HOME/.zshrc" "$DOTFILES_DIR/config/zsh/.zshrc"
  assert_link_to "$HOME/.config/nvim" "$DOTFILES_DIR/config/nvim/.config/nvim"
  assert_link_to "$HOME/.config/mise/config.toml" "$DOTFILES_DIR/config/mise/.config/mise/config.toml"
  assert_eq "$(cat "$BACKUP_DIR/.zshrc")" old
  assert_eq "$(cat "$BACKUP_DIR/.config/nvim/init.lua")" old
  assert_eq "$(cat "$BACKUP_DIR/.config/mise/config.toml")" old
}

test_stow_packages_unfolds_existing_repo_link() {
  mkdir -p "$HOME/.config"
  ln -s ../workspace/dotfiles/config/zsh/.config/zsh "$HOME/.config/zsh"
  stow_packages
  assert_dir "$HOME/.config/zsh"
  assert_link_to "$HOME/.config/zsh/zsh-core.zsh" "$DOTFILES_DIR/config/zsh/.config/zsh/zsh-core.zsh"
  assert_missing "$BACKUP_DIR"
}

test_stow_packages_is_idempotent() {
  local before after
  stow_packages
  before=$(cd "$HOME" && find . -type l | sort)
  stow_packages
  after=$(cd "$HOME" && find . -type l | sort)
  assert_eq "$after" "$before"
  assert_missing "$BACKUP_DIR"
}

make_plugin_repo() {
  local dir=$1
  mkdir -p "$dir"
  git -C "$dir" init --quiet
  echo '# plugin' >"$dir/plugin.zsh"
  git -C "$dir" add plugin.zsh
  git -C "$dir" -c user.name=test -c user.email=test@example.com commit --quiet -m init
}

test_install_zsh_plugins_clones_once() {
  make_plugin_repo "$TEST_TMP/src/alpha"
  # shellcheck disable=SC2034 # read by install_zsh_plugins
  ZSH_PLUGINS=("alpha file://$TEST_TMP/src/alpha")
  install_zsh_plugins
  assert_file "$ZSH_PLUGIN_DIR/alpha/plugin.zsh"
  echo keep >"$ZSH_PLUGIN_DIR/alpha/marker"
  install_zsh_plugins
  assert_file "$ZSH_PLUGIN_DIR/alpha/marker"
}
```

- [ ] **Step 2: Run the tests to verify the new ones fail**

Run: `bash tests/test_common.sh`
Expected: the 7 Task 1 tests `PASS`; `test_stow_packages_*` (4) and `test_install_zsh_plugins_clones_once` `FAIL` with `command not found`; last line `12 checks, 5 failed`.

- [ ] **Step 3: Write the implementation**

Append to `lib/common.sh`:

```bash
# Packages whose directories must stay real, so machine-local files (ssh keys, company git
# config, mise conf.d) are never created inside the repository.
NO_FOLD_PACKAGES=(zsh git ssh mise)
# Packages that may be linked as a whole directory.
FOLD_PACKAGES=(nvim wezterm)

# "<name> <clone url>" per plugin
ZSH_PLUGINS=(
  "zsh-defer https://github.com/romkatv/zsh-defer.git"
  "zsh-autosuggestions https://github.com/zsh-users/zsh-autosuggestions.git"
  "zsh-syntax-highlighting https://github.com/zsh-users/zsh-syntax-highlighting.git"
  "zsh-z https://github.com/agkozak/zsh-z.git"
)

# is_repo_owned PATH PKG: PATH resolves to something inside config/PKG.
is_repo_owned() {
  local real pkg_real
  real=$(realpath "$1" 2>/dev/null) || return 1
  pkg_real=$(realpath "$DOTFILES_DIR/config/$2")
  [[ $real == "$pkg_real"/* ]]
}

# package_targets PKG MODE: print the $HOME paths stow creates for PKG. no-fold links every
# file; fold links top-level entries, and entries directly under .config.
package_targets() {
  local pkg_dir="$DOTFILES_DIR/config/$1" mode=$2 entry sub rel
  if [[ $mode == no-fold ]]; then
    while IFS= read -r -d '' entry; do
      rel=${entry#"$pkg_dir"/}
      printf '%s\n' "$HOME/$rel"
    done < <(find "$pkg_dir" \( -type f -o -type l \) -print0)
    return 0
  fi
  for entry in "$pkg_dir"/* "$pkg_dir"/.[!.]*; do
    if [[ ! -e $entry ]]; then
      continue
    fi
    if [[ ${entry##*/} != .config ]]; then
      printf '%s\n' "$HOME/${entry##*/}"
      continue
    fi
    for sub in "$entry"/* "$entry"/.[!.]*; do
      if [[ -e $sub ]]; then
        printf '%s\n' "$HOME/.config/${sub##*/}"
      fi
    done
  done
}

# prepare_package PKG MODE: back up anything that would block stow — real files or
# directories, and links that resolve outside the package.
prepare_package() {
  local target
  while IFS= read -r target; do
    if [[ ! -e $target && ! -L $target ]]; then
      continue
    fi
    if is_repo_owned "$target" "$1"; then
      continue
    fi
    backup_path "$target"
  done < <(package_targets "$1" "$2")
}

stow_packages() {
  local pkg
  for pkg in "${NO_FOLD_PACKAGES[@]}"; do
    prepare_package "$pkg" no-fold
  done
  for pkg in "${FOLD_PACKAGES[@]}"; do
    prepare_package "$pkg" fold
  done
  stow --dir "$DOTFILES_DIR/config" --target "$HOME" --no-folding --restow "${NO_FOLD_PACKAGES[@]}"
  stow --dir "$DOTFILES_DIR/config" --target "$HOME" --restow "${FOLD_PACKAGES[@]}"
}

install_zsh_plugins() {
  local entry name url
  mkdir -p "$ZSH_PLUGIN_DIR"
  for entry in "${ZSH_PLUGINS[@]}"; do
    read -r name url <<<"$entry"
    if [[ -d $ZSH_PLUGIN_DIR/$name/.git ]]; then
      continue
    fi
    git clone --quiet --depth 1 "$url" "$ZSH_PLUGIN_DIR/$name"
    log "installed zsh plugin $name"
  done
}
```

- [ ] **Step 4: Run the tests to verify they pass**

Run: `bash tests/test_common.sh`
Expected: 12 `PASS`, last line `12 checks, 0 failed`.

- [ ] **Step 5: shellcheck**

Run: `mise exec shellcheck@latest -- shellcheck -x lib/common.sh tests/lib.sh tests/test_common.sh`
Expected: no output.

- [ ] **Step 6: Commit**

```bash
git commit -m "bootstrap: add stow linking and zsh plugin install" -- lib/common.sh tests/test_common.sh
```

---

### Task 3: Remove unused configs; restructure git, ssh and mise packages

**Files:**
- Delete: `fonts/ wallpapers/ screenshots/ postgresql/ .ctags.d/ .config/ scripts/ hyperfine_1.16.1_amd64.deb hyperfine-packer.out install.sh .xinitrc .zshrc`
- Delete: `config/{alacritty,tmux,kitty,vm,xinit,ulauncher,mpd,ncmpcpp,flameshot,fontconfig,gnupg,vim-server}`
- Rename: `config/gitconfig` → `config/git`, `config/sshconfig` → `config/ssh`
- Delete: `config/git/.gitattributes`, `config/git/.gitconfig_company`, `config/git/.gitconfig_personal`
- Rewrite: `config/git/.gitconfig`, `config/ssh/.ssh/config`
- Create: `config/git/.config/git/personal`, `config/mise/.config/mise/config.toml`, `templates/gitconfig.local`, `templates/git-company`, `templates/ssh-company`
- Keep (content from working tree): `config/git/.gitignore_global`, `config/git/.gitmessage`
- Local only (not tracked): `~/.config/git/company`

- [ ] **Step 1: Save the company git config locally before it is removed**

The uncommitted `config/gitconfig/.gitconfig_company` rewrites GitHub URLs to `git@github.com-<alias>`, an alias no SSH `Host` defines. Write it to `~/.config/git/company` with the alias that `~/.ssh/config` actually defines for the company GitHub account:

```bash
mkdir -p ~/.config/git
alias=$(awk '$1 == "Host" && $2 ~ /^github\.com-/ { print $2; exit }' ~/.ssh/config)
test -n "$alias"
sed -E \
  -e "s#^\[url \"git@github\.com-[^\"]*\"\]#[url \"git@${alias}:\"]#" \
  -e 's#^([[:space:]]*insteadOf = )git@github\.com$#\1git@github.com:#' \
  config/gitconfig/.gitconfig_company >~/.config/git/company
chmod 600 ~/.config/git/company
```

Run: `git config --file ~/.config/git/company --get-regexp '^url\.'`
Expected: one line `url.git@<alias>:.insteadof git@github.com:` where `<alias>` is the `github.com-…` host from `~/.ssh/config`.

- [ ] **Step 2: Delete unused files and configs**

```bash
git rm -r -q fonts wallpapers screenshots postgresql .ctags.d .config scripts \
  hyperfine_1.16.1_amd64.deb hyperfine-packer.out install.sh .xinitrc .zshrc
git rm -r -q -f config/alacritty config/tmux config/kitty config/vm config/xinit config/ulauncher \
  config/mpd config/ncmpcpp config/flameshot config/fontconfig config/gnupg config/vim-server
rm -rf fonts wallpapers screenshots postgresql .ctags.d .config scripts \
  config/alacritty config/tmux config/kitty config/vm config/xinit config/ulauncher \
  config/mpd config/ncmpcpp config/flameshot config/fontconfig config/gnupg config/vim-server
```

Run: `ls -A`
Expected exactly: `.git  .gitignore  config  docs  lib  README.md  tests`

Run: `ls config`
Expected: `gitconfig nvim sshconfig wezterm zsh`

- [ ] **Step 3: Rename the git and ssh packages and drop unused git files**

```bash
git mv config/gitconfig config/git
git mv config/sshconfig config/ssh
git rm -q -f config/git/.gitattributes config/git/.gitconfig_company config/git/.gitconfig_personal
```

Run: `ls -A config/git config/ssh/.ssh`
Expected:
```
config/git:
.gitconfig  .gitignore_global  .gitmessage

config/ssh/.ssh:
config
```

- [ ] **Step 4: Write the shared git config**

Replace the whole content of `config/git/.gitconfig`:

```ini
# Shared git config. Machine-specific settings (company identity, credentials)
# go in ~/.gitconfig.local, which is included last.

[user]
	useConfigOnly = true

[core]
	editor = nvim
	excludesfile = ~/.gitignore_global
	pager = delta

[commit]
	template = ~/.gitmessage

[push]
	default = simple
	autoSetupRemote = true

[interactive]
	diffFilter = delta --color-only

[delta]
	line-numbers = true
	syntax-theme = base16
	side-by-side = false
	file-modified-label = modified:

[alias]
	lg = log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit

[includeIf "gitdir/i:~/workspace/"]
	path = ~/.config/git/personal

[include]
	path = ~/.gitconfig.local
```

Create `config/git/.config/git/personal`:

```ini
# Personal identity for repositories under ~/workspace/.
[user]
	name = sangvo
	email = sangvo111@gmail.com
	signingkey = F92731A32AFD526E
```

Run: `cat config/git/.gitignore_global`
Expected (the previously uncommitted change is kept):
```
tags

**/.claude/settings.local.json
```

- [ ] **Step 5: Write the shared ssh config**

Replace the whole content of `config/ssh/.ssh/config`:

```
# Shared SSH config. Machine-specific hosts (company servers, bastions, VM tools)
# live in ~/.ssh/config.d/, which is not tracked.
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

- [ ] **Step 6: Add the mise package and templates**

```bash
mkdir -p config/mise/.config/mise templates
cp ~/.config/mise/config.toml config/mise/.config/mise/config.toml
```

Run: `cat config/mise/.config/mise/config.toml`
Expected:
```toml
[tools]
go = "1.22"
node = "24.3.0"
pnpm = "latest"
ruby = "3.4.5"

[settings]
idiomatic_version_file_enable_tools = []
```

Create `templates/gitconfig.local`:

```ini
# Machine-local git config (not tracked). Included last by ~/.gitconfig.
# Repositories under ~/company/ use the company identity.
[includeIf "gitdir/i:~/company/"]
	path = ~/.config/git/company
```

Create `templates/git-company`:

```ini
# Company identity for repositories under ~/company/ (not tracked).
[user]
	name = your-company-username
	email = you@company.example

# Cache HTTPS credentials for 80 days.
[credential]
	helper = cache --timeout=6912000

# Use the company SSH key for GitHub; the alias must match a Host in ~/.ssh/config.d/company.
[url "git@github.com-work:"]
	insteadOf = git@github.com:
```

Create `templates/ssh-company`:

```
# Machine-local SSH hosts (not tracked). Included by ~/.ssh/config.
#
# Host github.com-work
#   HostName github.com
#   User git
#   IdentityFile ~/.ssh/work_ed25519
```

- [ ] **Step 7: Verify the configs parse**

Run: `git config --file config/git/.gitconfig push.default && git config --file config/git/.gitconfig --get-regexp '^include'`
Expected:
```
simple
includeif.gitdir/i:~/workspace/.path ~/.config/git/personal
include.path ~/.gitconfig.local
```

Run: `ssh -G -F config/ssh/.ssh/config github.com | grep -E '^(hostname|user|identityfile|controlpath|controlpersist) '`
Expected:
```
user git
hostname github.com
identityfile ~/.ssh/id_ed25519
controlpath ~/.ssh/sockets/%r@%h-%p
controlpersist 600
```
(order may differ)

Run: `git grep -nIiE '<company>|<old-company>|<project-prefix>|bastion|[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' -- config/git config/ssh config/mise templates || echo clean`
Expected: `clean`

- [ ] **Step 8: Commit**

```bash
git add config/git config/ssh config/mise templates
git commit -m "remove unused configs; split git and ssh into shared and local parts" -- . ':!config/nvim' ':!config/zsh' ':!lib' ':!tests' ':!docs'
git status --short
```
Expected `git status --short`: only `config/nvim/...` modifications remain.

---

### Task 4: Replace the Neovim config with the kickstart.nvim config in use

**Files:**
- Replace: `config/nvim/.config/nvim/` with the contents of `~/.config/nvim/` minus upstream-only files

- [ ] **Step 1: Replace the package contents**

```bash
git rm -r -q -f config/nvim
rm -rf config/nvim
mkdir -p config/nvim/.config/nvim
rsync -a \
  --exclude .git --exclude .github --exclude .claude --exclude doc \
  --exclude LICENSE.md --exclude README.md --exclude .gitignore --exclude .DS_Store \
  ~/.config/nvim/ config/nvim/.config/nvim/
```

- [ ] **Step 2: Verify the copy matches the live config**

Run: `diff -rq -x .git -x .github -x .claude -x doc -x LICENSE.md -x README.md -x .gitignore -x .DS_Store ~/.config/nvim config/nvim/.config/nvim && echo identical`
Expected: `identical`

Run: `find config/nvim -type f | sed 's#config/nvim/.config/nvim/##' | sort`
Expected:
```
.stylua.toml
init.lua
lua/custom/plugins/harpoon.lua
lua/custom/plugins/init.lua
lua/custom/plugins/toggleterm.lua
lua/kickstart/health.lua
lua/kickstart/plugins/autopairs.lua
lua/kickstart/plugins/debug.lua
lua/kickstart/plugins/gitsigns.lua
lua/kickstart/plugins/indent_line.lua
lua/kickstart/plugins/lint.lua
lua/kickstart/plugins/neo-tree.lua
nvim-pack-lock.json
```

- [ ] **Step 3: Verify it loads from the repo path**

Run: `XDG_CONFIG_HOME=$PWD/config/nvim/.config nvim --headless +qa; echo "exit=$?"`
Expected: `exit=0` (nvim reads `config/nvim/.config/nvim` as its config directory, including `lua/` modules)

- [ ] **Step 4: Commit**

```bash
git add config/nvim
git commit -m "nvim: replace old config with the kickstart.nvim config in use" -- config/nvim
```

---

### Task 5: zsh — new plugin location and guards for optional tools

**Files:**
- Rewrite: `config/zsh/.zshrc`
- Modify: `config/zsh/.config/zsh/zsh-core.zsh` (zsh-z paths)
- Rewrite: `config/zsh/.config/zsh/zsh-fzf.zsh`
- Rewrite: `.gitignore`
- Delete (untracked): `config/zsh/.config/zsh/{z,zsh-defer,zsh-autosuggestions,zsh-syntax-highlighting,zsh-z}`

**Interfaces:**
- Consumes: `install_zsh_plugins` from Task 2

- [ ] **Step 1: Install plugins at the new location**

```bash
DOTFILES_DIR=$PWD bash -c 'source lib/common.sh && install_zsh_plugins'
```

Run: `ls ~/.local/share/zsh/plugins`
Expected: `zsh-autosuggestions  zsh-defer  zsh-syntax-highlighting  zsh-z`

- [ ] **Step 2: Rewrite `.zshrc`**

Replace the whole content of `config/zsh/.zshrc`:

```zsh
source ~/.local/share/zsh/plugins/zsh-defer/zsh-defer.plugin.zsh

export PATH=$HOME/.local/bin:$PATH
if [[ -d /opt/homebrew/bin ]]; then
  export PATH=/opt/homebrew/bin:$PATH
fi

# replacement for oh-my-zsh
source ~/.config/zsh/zsh-core.zsh

export LANG=en_US.UTF-8
export EDITOR="nvim"

# Tools ------------------------------------------------------------------------
# Activated before the aliases so tools installed by mise are already on PATH.
if (( $+commands[mise] )); then
  eval "$(mise activate zsh)"
  eval "$(mise hook-env -s zsh)"
fi
if (( $+commands[direnv] )); then
  eval "$(direnv hook zsh)"
fi

# Key bindings -----------------------------------------------------------------
if [[ -t 0 ]]; then
  stty -ixon
fi

# vi mode
bindkey -v
bindkey "^A" beginning-of-line
bindkey "^e" end-of-line
bindkey "^b" backward-char
bindkey "^f" forward-char
bindkey "^u" kill-whole-line
bindkey "^w" backward-kill-word
bindkey "^s" history-incremental-search-backward
bindkey "^n" history-search-forward
bindkey "^p" history-search-backward
bindkey "^ " autosuggest-accept

# Aliases ----------------------------------------------------------------------
alias ws="cd ~/workspace"
alias co="cd ~/company"
alias cls="clear"
alias joke='curl -H "Accept: text/plain" https://icanhazdadjoke.com'
alias dot='git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'

# Git
alias gco='git checkout'
alias gst='git status'
alias recent-branch="git for-each-ref --sort=-committerdate --format='%(refname:short)' refs/heads/ |  fzf | sed 's/\* //g' | xargs -I '{}' git checkout {}"

# Awesome ls
if (( $+commands[lsd] )); then
  alias ls="lsd -F"
  alias la="lsd -Fah"
  alias l="lsd -Flah"
fi

# Deferred (run after the first prompt) ----------------------------------------
zsh-defer source ~/.config/zsh/zsh-fzf.zsh
zsh-defer source ~/.config/zsh/zsh-export-path.zsh
zsh-defer source ~/.local/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
zsh-defer source ~/.local/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

export GPG_TTY=$TTY
if (( $+commands[gpgconf] )); then
  zsh-defer gpgconf --launch gpg-agent
fi
if (( $+commands[thefuck] )); then
  zsh-defer -c 'eval "$(thefuck --alias)"'
fi

# Added by Antigravity
if [[ -d $HOME/.antigravity/antigravity/bin ]]; then
  export PATH="$HOME/.antigravity/antigravity/bin:$PATH"
fi
```

- [ ] **Step 3: Point zsh-core at the new zsh-z location**

In `config/zsh/.config/zsh/zsh-core.zsh` replace:

```zsh
# :A resolves the symlink to match the path the plugin adds itself, typeset -U drops duplicates
typeset -U fpath
fpath=(~/.config/zsh/zsh-z(:A) $fpath)
```

with:

```zsh
# :A normalizes the path to match the one the plugin adds itself; typeset -U drops duplicates
typeset -U fpath
fpath=(~/.local/share/zsh/plugins/zsh-z(:A) $fpath)
```

and replace:

```zsh
source ~/.config/zsh/zsh-z/zsh-z.plugin.zsh
```

with:

```zsh
source ~/.local/share/zsh/plugins/zsh-z/zsh-z.plugin.zsh
```

- [ ] **Step 4: Load fzf key bindings on machines without `~/.fzf.zsh`**

Replace the whole content of `config/zsh/.config/zsh/zsh-fzf.zsh`:

```zsh
export FZF_DEFAULT_COMMAND="fd --type file --follow --no-ignore --hidden --exclude .git --exclude node_modules"
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_DEFAULT_OPTS="--inline-info"

if [[ -f ~/.fzf.zsh ]]; then
  source ~/.fzf.zsh
elif (( $+commands[fzf] )); then
  source <(fzf --zsh)
fi
```

- [ ] **Step 5: Remove old plugin clones from the package and simplify `.gitignore`**

The clones must leave `config/zsh/` before any stow run, or stow would link them into `$HOME`.

```bash
rm -rf config/zsh/.config/zsh/z config/zsh/.config/zsh/zsh-defer \
  config/zsh/.config/zsh/zsh-autosuggestions config/zsh/.config/zsh/zsh-syntax-highlighting \
  config/zsh/.config/zsh/zsh-z
printf 'tags\n' >.gitignore
```

Run: `ls -A config/zsh/.config/zsh && git status --short --ignored config/zsh`
Expected: `zsh-core.zsh  zsh-export-path.zsh  zsh-fzf.zsh`, and git shows only ` M` lines for the three edited files (no `!!` or `??` entries).

- [ ] **Step 6: Verify zsh starts cleanly and quickly**

Run: `zsh -n config/zsh/.zshrc && zsh -n config/zsh/.config/zsh/zsh-core.zsh && echo syntax-ok`
Expected: `syntax-ok`

Run: `zsh -i -c exit 2>&1 | grep -v 'stdin isn.t a terminal' ; echo "exit=${pipestatus[1]}"`
Expected: no output lines, `exit=0`

Run: `(sleep 3; printf 'print -r -- "Z=${+functions[zshz]} AUTOSUG=${+functions[_zsh_autosuggest_start]} HL=${+ZSH_HIGHLIGHT_VERSION}"\nexit\n') | script -q /dev/null zsh -i 2>&1 | LC_ALL=C grep -aoE 'Z=[01] AUTOSUG=[01] HL=[01]|not found|no such file' | tail -3`
Expected: `Z=1 AUTOSUG=1 HL=1` and no `not found` / `no such file` lines.

Run: `for i in 1 2 3; do /usr/bin/time -p zsh -i -c exit 2>&1 | grep real; done`
Expected: each `real` under `0.30`.

- [ ] **Step 7: Commit**

```bash
git commit -m "zsh: install plugins outside the repo, guard optional tools" -- config/zsh .gitignore
```

---

### Task 6: macOS packages

**Files:**
- Create: `Brewfile`
- Create: `lib/macos.sh`

**Interfaces:**
- Consumes: `log`, `DOTFILES_DIR` from `lib/common.sh`
- Produces: `install_packages` (macOS) — installs Homebrew if missing, runs `brew bundle`

- [ ] **Step 1: Write the Brewfile**

Create `Brewfile`:

```ruby
# Installed by bootstrap.sh on macOS. Curated by actual use; add packages here, not ad hoc.

# Editor, shell and git
brew "neovim"
brew "mise"
brew "git"
brew "git-delta"
brew "gnupg"
brew "pinentry-mac"
brew "stow"

# CLI tools
brew "bat"
brew "btop"
brew "curl"
brew "direnv"
brew "fastfetch"
brew "fd"
brew "fzf"
brew "git-quick-stats"
brew "gitmoji"
brew "jq"
brew "kew"
brew "lazydocker"
brew "lazygit"
brew "lsd"
brew "ripgrep"
brew "sshs"
brew "thefuck"

# Containers
brew "colima"
brew "docker"
brew "docker-buildx"
brew "docker-compose"

# Databases and runtimes
brew "libpq"
brew "openjdk"

# Needed by mise to build Ruby
brew "libyaml"
brew "openssl@3"

# Apps and fonts
cask "appcleaner"
cask "betterdisplay"
cask "font-jetbrains-mono"
cask "font-symbols-only-nerd-font"
cask "gonhanh"
cask "localsend"
cask "numi"
cask "rectangle"
cask "stats"
cask "thaw"
cask "tolaria"
cask "wezterm"
```

- [ ] **Step 2: Verify the Brewfile parses and every entry exists**

Run: `brew bundle list --file Brewfile --formula | wc -l; brew bundle list --file Brewfile --cask | wc -l`
Expected: `32` and `12`

Run: `brew bundle list --file Brewfile --formula | xargs brew info --formula >/dev/null && brew bundle list --file Brewfile --cask | xargs brew info --cask >/dev/null && echo all-exist`
Expected: `all-exist`

- [ ] **Step 3: Write `lib/macos.sh`**

Create `lib/macos.sh`:

```bash
#!/usr/bin/env bash
# macOS package installation. Sourced by bootstrap.sh after lib/common.sh.

BREW_PREFIX=/opt/homebrew

install_packages() {
  if [[ ! -x $BREW_PREFIX/bin/brew ]]; then
    log "installing Homebrew"
    sudo -v
    NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  fi
  eval "$("$BREW_PREFIX/bin/brew" shellenv)"
  brew bundle --file "$DOTFILES_DIR/Brewfile" --no-upgrade
}
```

- [ ] **Step 4: shellcheck**

Run: `mise exec shellcheck@latest -- shellcheck -x lib/macos.sh`
Expected: no output.

- [ ] **Step 5: Commit**

```bash
git add Brewfile lib/macos.sh
git commit -m "bootstrap: add curated Brewfile and macOS installer" -- Brewfile lib/macos.sh
```

---

### Task 7: Ubuntu packages, mise tools, nvim plugins and login shell

**Files:**
- Create: `packages/apt.txt`, `packages/mise-linux.toml`, `lib/ubuntu.sh`
- Modify: `lib/common.sh` (append `install_mise_tools`, `sync_nvim`, `set_default_shell`)
- Modify: `tests/test_common.sh` (add tests above the `--run` block)

**Interfaces:**
- Consumes: `log`, `warn`, `DOTFILES_DIR`
- Produces:
  - `install_packages` (Ubuntu) — apt packages, WezTerm apt repo, fonts, mise binary, `conf.d/linux.toml` link
  - `install_mise_tools` — trusts repo mise configs, runs `mise install`, exports tool env into the current process
  - `sync_nvim` — `nvim --headless +qa` (vim.pack installs missing plugins)
  - `set_default_shell` — `chsh` to zsh on interactive runs only

- [ ] **Step 1: Write the failing tests**

Insert into `tests/test_common.sh`, directly above `if [[ ${1:-} == --run ]]; then`:

```bash
test_set_default_shell_skips_without_terminal() {
  local out
  out=$(SHELL=/bin/bash set_default_shell 2>&1 </dev/null)
  if [[ $out != *"chsh -s"* ]]; then
    fail "expected a hint to run chsh, got: $out"
  fi
}

test_install_mise_tools_skips_without_mise() {
  local out
  out=$(PATH=/usr/bin:/bin install_mise_tools 2>&1)
  if [[ $out != *"mise not found"* ]]; then
    fail "expected a warning, got: $out"
  fi
}

test_sync_nvim_skips_without_nvim() {
  local out
  out=$(PATH=/usr/bin:/bin sync_nvim 2>&1)
  if [[ $out != *"nvim not found"* ]]; then
    fail "expected a warning, got: $out"
  fi
}
```

- [ ] **Step 2: Run the tests to verify the new ones fail**

Run: `bash tests/test_common.sh`
Expected: the 3 new tests `FAIL`; last line `15 checks, 3 failed`.

- [ ] **Step 3: Append the implementation to `lib/common.sh`**

```bash
install_mise_tools() {
  local cfg
  if ! command -v mise >/dev/null 2>&1; then
    warn "mise not found; skipping tool install"
    return 0
  fi
  for cfg in "$DOTFILES_DIR/config/mise/.config/mise/config.toml" "$DOTFILES_DIR/packages/mise-linux.toml"; do
    if [[ -f $cfg ]]; then
      mise trust --quiet "$cfg"
    fi
  done
  # Use precompiled Ruby when this mise version supports it; otherwise Ruby is compiled.
  if mise settings get ruby.compile >/dev/null 2>&1; then
    export MISE_RUBY_COMPILE=false
  fi
  MISE_YES=1 mise install
  eval "$(mise env -s bash)"
}

# vim.pack installs missing plugins while init.lua runs, so a headless start is enough.
sync_nvim() {
  if ! command -v nvim >/dev/null 2>&1; then
    warn "nvim not found; skipping plugin install"
    return 0
  fi
  nvim --headless +qa
}

set_default_shell() {
  local zsh_path
  zsh_path=$(command -v zsh || true)
  if [[ -z $zsh_path ]]; then
    warn "zsh is not installed; login shell unchanged"
    return 0
  fi
  if [[ ${SHELL:-} == */zsh ]]; then
    return 0
  fi
  if [[ ! -t 0 ]]; then
    warn "no terminal; run 'chsh -s $zsh_path' to make zsh the login shell"
    return 0
  fi
  if ! grep -qx "$zsh_path" /etc/shells; then
    echo "$zsh_path" | sudo tee -a /etc/shells >/dev/null
  fi
  chsh -s "$zsh_path"
}
```

- [ ] **Step 4: Run the tests to verify they pass**

Run: `bash tests/test_common.sh`
Expected: `15 checks, 0 failed`.

- [ ] **Step 5: Write the Ubuntu package lists**

Create `packages/apt.txt`:

```
# Base packages for Ubuntu 24.04. CLI tools come from mise (packages/mise-linux.toml).
zsh
git
curl
ca-certificates
gnupg
unzip
build-essential
stow
xclip
fontconfig
# Ruby build dependencies for mise
libssl-dev
libyaml-dev
zlib1g-dev
libffi-dev
libreadline-dev
```

Create `packages/mise-linux.toml`:

```toml
# CLI tools that come from Homebrew on macOS (see Brewfile); mise installs them on Ubuntu.
# Linked to ~/.config/mise/conf.d/linux.toml by lib/ubuntu.sh.
[tools]
bat = "latest"
btop = "latest"
delta = "latest"
direnv = "latest"
fd = "latest"
fzf = "latest"
jq = "latest"
lazydocker = "latest"
lazygit = "latest"
lsd = "latest"
neovim = "latest"
ripgrep = "latest"
```

- [ ] **Step 6: Write `lib/ubuntu.sh`**

Create `lib/ubuntu.sh`:

```bash
#!/usr/bin/env bash
# Ubuntu 24.04 package installation. Sourced by bootstrap.sh after lib/common.sh.

FONT_DIR="$HOME/.local/share/fonts"
JETBRAINS_MONO_URL="https://github.com/JetBrains/JetBrainsMono/releases/download/v2.304/JetBrainsMono-2.304.zip"
NERD_SYMBOLS_URL="https://github.com/ryanoasis/nerd-fonts/releases/latest/download/NerdFontsSymbolsOnly.zip"

apt_install() {
  sudo DEBIAN_FRONTEND=noninteractive apt-get install -y -qq "$@"
}

install_wezterm() {
  if command -v wezterm >/dev/null 2>&1; then
    return 0
  fi
  curl -fsSL https://apt.fury.io/wez/gpg.key | sudo gpg --yes --dearmor -o /usr/share/keyrings/wezterm-fury.gpg
  sudo chmod 644 /usr/share/keyrings/wezterm-fury.gpg
  echo 'deb [signed-by=/usr/share/keyrings/wezterm-fury.gpg] https://apt.fury.io/wez/ * *' |
    sudo tee /etc/apt/sources.list.d/wezterm.list >/dev/null
  sudo apt-get update -qq
  apt_install wezterm
}

# install_font_zip URL PATTERN: extract font files matching PATTERN from the zip at URL.
install_font_zip() {
  local tmp
  tmp=$(mktemp -d)
  curl -fsSL -o "$tmp/font.zip" "$1"
  unzip -qjo "$tmp/font.zip" "$2" -d "$FONT_DIR"
  rm -rf "$tmp"
}

install_fonts() {
  mkdir -p "$FONT_DIR"
  if ! compgen -G "$FONT_DIR/JetBrainsMono-*.ttf" >/dev/null; then
    install_font_zip "$JETBRAINS_MONO_URL" 'fonts/ttf/*.ttf'
  fi
  if ! compgen -G "$FONT_DIR/SymbolsNerdFont*.ttf" >/dev/null; then
    install_font_zip "$NERD_SYMBOLS_URL" '*.ttf'
  fi
  fc-cache -f "$FONT_DIR" >/dev/null
}

install_mise() {
  if [[ ! -x $HOME/.local/bin/mise ]] && ! command -v mise >/dev/null 2>&1; then
    curl -fsSL https://mise.run | sh
  fi
  export PATH="$HOME/.local/bin:$PATH"
  mkdir -p "$HOME/.config/mise/conf.d"
  ln -sfn "$DOTFILES_DIR/packages/mise-linux.toml" "$HOME/.config/mise/conf.d/linux.toml"
}

install_packages() {
  sudo -v
  sudo apt-get update -qq
  grep -vE '^[[:space:]]*(#|$)' "$DOTFILES_DIR/packages/apt.txt" |
    xargs sudo DEBIAN_FRONTEND=noninteractive apt-get install -y -qq
  install_wezterm
  install_fonts
  install_mise
}
```

- [ ] **Step 7: shellcheck**

Run: `mise exec shellcheck@latest -- shellcheck -x lib/common.sh lib/ubuntu.sh tests/test_common.sh`
Expected: no output.

- [ ] **Step 8: Commit**

```bash
git add packages lib/ubuntu.sh
git commit -m "bootstrap: add Ubuntu installer, mise tools, nvim plugins, login shell" -- packages lib/ubuntu.sh lib/common.sh tests/test_common.sh
```

---

### Task 8: `bootstrap.sh` entry point and README

**Files:**
- Create: `bootstrap.sh`
- Rewrite: `README.md`

**Interfaces:**
- Consumes: everything in `lib/common.sh`; `install_packages` from `lib/macos.sh` / `lib/ubuntu.sh`

- [ ] **Step 1: Write the failing check**

Run: `bash bootstrap.sh --help; echo "exit=$?"`
Expected: `bash: bootstrap.sh: No such file or directory`, `exit=127`

- [ ] **Step 2: Write `bootstrap.sh`**

Create `bootstrap.sh` and `chmod +x bootstrap.sh`:

```bash
#!/usr/bin/env bash
# Set up this machine from the dotfiles repository (macOS or Ubuntu 24.04):
#
#   bash -c "$(curl -fsSL https://raw.githubusercontent.com/sangvo/dotfiles/mac/bootstrap.sh)"
#
# Safe to re-run.
set -Eeuo pipefail

REPO_URL="https://github.com/sangvo/dotfiles.git"
REPO_BRANCH="mac"
export DOTFILES_DIR="${DOTFILES_DIR:-$HOME/workspace/dotfiles}"

usage() {
  cat <<'EOF'
Usage: bootstrap.sh [--links-only]

  --links-only  only link configs and create local files; skip packages,
                mise tools and nvim plugins
EOF
}

detect_os() {
  local id=""
  case "$(uname -s)" in
    Darwin) echo macos ;;
    Linux)
      if [[ -r /etc/os-release ]]; then
        # shellcheck source=/dev/null
        id=$(. /etc/os-release && echo "${ID:-}")
      fi
      if [[ $id == ubuntu ]]; then
        echo ubuntu
      else
        echo unsupported
      fi
      ;;
    *) echo unsupported ;;
  esac
}

# git is needed to clone the repository before anything else can run.
ensure_git() {
  case $1 in
    macos)
      if ! xcode-select -p >/dev/null 2>&1; then
        echo "Installing Xcode Command Line Tools; finish the dialog to continue..."
        xcode-select --install >/dev/null 2>&1 || true
        until xcode-select -p >/dev/null 2>&1; do sleep 5; done
      fi
      ;;
    ubuntu)
      if ! command -v git >/dev/null 2>&1; then
        sudo apt-get update -qq
        sudo DEBIAN_FRONTEND=noninteractive apt-get install -y -qq git ca-certificates
      fi
      ;;
  esac
}

ensure_repo() {
  if [[ ! -d $DOTFILES_DIR/.git ]]; then
    mkdir -p "$(dirname "$DOTFILES_DIR")"
    git clone --branch "$REPO_BRANCH" "$REPO_URL" "$DOTFILES_DIR"
  fi
}

main() {
  local links_only=false os arg self
  for arg in "$@"; do
    case $arg in
      --links-only) links_only=true ;;
      -h | --help)
        usage
        return 0
        ;;
      *)
        usage >&2
        return 1
        ;;
    esac
  done

  os=$(detect_os)
  if [[ $os == unsupported ]]; then
    echo "error: only macOS and Ubuntu are supported" >&2
    return 1
  fi

  ensure_git "$os"
  ensure_repo

  # When piped from curl there is no script file; continue from the checkout.
  self=$(realpath "${BASH_SOURCE[0]:-/dev/null}" 2>/dev/null || true)
  if [[ $self != "$(realpath "$DOTFILES_DIR/bootstrap.sh")" ]]; then
    exec bash "$DOTFILES_DIR/bootstrap.sh" "$@"
  fi

  # shellcheck source=lib/common.sh
  source "$DOTFILES_DIR/lib/common.sh"
  # shellcheck source=/dev/null
  source "$DOTFILES_DIR/lib/$os.sh"
  trap 'die "step failed: $CURRENT_STEP"' ERR

  if [[ $links_only == false ]]; then
    run_step "Installing packages" install_packages
  fi
  run_step "Installing zsh plugins" install_zsh_plugins
  run_step "Migrating ~/.ssh/config" migrate_ssh_config
  run_step "Creating local config files" setup_local_files
  run_step "Removing stale links" clean_stale_links
  run_step "Linking configs" stow_packages
  if [[ $links_only == false ]]; then
    run_step "Installing mise tools" install_mise_tools
    run_step "Installing nvim plugins" sync_nvim
  fi
  run_step "Setting login shell" set_default_shell
  log "Done. Open a new terminal to load the shell config."
}

main "$@"
```

- [ ] **Step 3: Verify argument handling**

Run: `bash bootstrap.sh --help; echo "exit=$?"`
Expected: the usage text, `exit=0`

Run: `bash bootstrap.sh --bogus; echo "exit=$?"`
Expected: the usage text on stderr, `exit=1`

Run: `mise exec shellcheck@latest -- shellcheck -x bootstrap.sh lib/*.sh tests/*.sh`
Expected: no output.

- [ ] **Step 4: Rewrite the README**

Replace the whole content of `README.md`:

````markdown
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
````

- [ ] **Step 5: Commit**

```bash
git add bootstrap.sh README.md
git commit -m "bootstrap: add entry point and rewrite README" -- bootstrap.sh README.md
```

---

### Task 9: End-to-end test in an Ubuntu 24.04 container

**Files:**
- Create: `tests/ubuntu-container.sh`, `tests/ubuntu-checks.sh`

**Interfaces:**
- Consumes: `tests/lib.sh` (`check`, `assert_*`, `finish`), `bootstrap.sh`

- [ ] **Step 1: Write the container runner**

Create `tests/ubuntu-container.sh`:

```bash
#!/usr/bin/env bash
# Run bootstrap.sh twice in a fresh Ubuntu 24.04 container and check the result.
# Needs a Docker daemon. PLATFORM defaults to linux/amd64 to match x86 machines.
set -euo pipefail

REPO_ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
PLATFORM=${PLATFORM:-linux/amd64}

docker run --rm --platform "$PLATFORM" -v "$REPO_ROOT:/src:ro" ubuntu:24.04 bash -euo pipefail -c '
  apt-get update -qq
  DEBIAN_FRONTEND=noninteractive apt-get install -y -qq sudo git ca-certificates curl bsdutils >/dev/null
  useradd --create-home --shell /bin/bash dev
  echo "dev ALL=(ALL) NOPASSWD:ALL" >/etc/sudoers.d/dev
  install -d -o dev -g dev /home/dev/workspace
  cp -a /src /home/dev/workspace/dotfiles
  chown -R dev:dev /home/dev/workspace/dotfiles
  su - dev -c "bash /home/dev/workspace/dotfiles/tests/ubuntu-checks.sh"
'
```

- [ ] **Step 2: Write the checks**

Create `tests/ubuntu-checks.sh`:

```bash
#!/usr/bin/env bash
# Runs inside the container as a non-root user with passwordless sudo (see ubuntu-container.sh).
set -euo pipefail

export DOTFILES_DIR="$HOME/workspace/dotfiles"
# Ruby is compiled from source on Linux and takes many minutes; every other tool is checked.
export MISE_DISABLE_TOOLS=ruby
# shellcheck source=tests/lib.sh
source "$DOTFILES_DIR/tests/lib.sh"

link_snapshot() {
  find "$HOME" -maxdepth 4 -type l -not -path "$HOME/.local/share/*" -printf '%p -> %l\n' | sort
}

interactive_zsh_clean() {
  local out
  out=$( (sleep 5; echo exit) | script -qfec "zsh -i" /dev/null 2>&1 || true)
  if grep -qiE 'not found|no such file|error' <<<"$out"; then
    printf '%s\n' "$out" >&2
    return 1
  fi
}

bash "$DOTFILES_DIR/bootstrap.sh"
first=$(link_snapshot)
bash "$DOTFILES_DIR/bootstrap.sh"
second=$(link_snapshot)

check "second run changes no links" assert_eq "$second" "$first"
check "nothing backed up on a fresh machine" assert_missing "$HOME/.dotfiles-backup"
check "zshrc linked" assert_link_to "$HOME/.zshrc" "$DOTFILES_DIR/config/zsh/.zshrc"
check "~/.ssh is a real directory" assert_dir "$HOME/.ssh"
check "ssh config linked" assert_link_to "$HOME/.ssh/config" "$DOTFILES_DIR/config/ssh/.ssh/config"
check "~/.config/git is a real directory" assert_dir "$HOME/.config/git"
check "~/.config/mise is a real directory" assert_dir "$HOME/.config/mise"
check "nvim config linked" assert_link_to "$HOME/.config/nvim" "$DOTFILES_DIR/config/nvim/.config/nvim"
check "wezterm config linked" assert_link_to "$HOME/.config/wezterm" "$DOTFILES_DIR/config/wezterm/.config/wezterm"
check "local git config created" assert_file "$HOME/.gitconfig.local"
check "wezterm installed" command -v wezterm
check "fonts installed" test -f "$HOME/.local/share/fonts/SymbolsNerdFont-Regular.ttf"
check "push.default is simple" assert_eq "$(git config --global push.default)" simple
check "zsh -i starts without output" assert_eq "$(zsh -i -c exit 2>&1)" ""
# shellcheck disable=SC2016 # zsh code, expanded by zsh
check "tools on PATH in zsh" zsh -i -c 'for t in nvim lazygit fzf rg fd lsd delta direnv node go; do (( $+commands[$t] )) || { print "missing $t" >&2; exit 1; }; done'
check "nvim plugins installed" test -d "$HOME/.local/share/nvim/site/pack/core/opt/telescope.nvim"
check "nvim starts cleanly" zsh -i -c 'nvim --headless +qa'
check "interactive zsh shows no errors" interactive_zsh_clean
finish
```

- [ ] **Step 3: Start an isolated Docker VM**

Use a separate colima profile so the existing one is untouched:

```bash
brew link docker
colima start --profile dotfiles-test --vm-type vz --vz-rosetta --cpu 4 --memory 6
export DOCKER_CONTEXT=colima-dotfiles-test
docker info --format '{{.ServerVersion}}'
```
Expected: a server version string.

- [ ] **Step 4: Run the end-to-end test**

Run: `bash tests/ubuntu-container.sh 2>&1 | tee /tmp/dotfiles-ubuntu-test.log | grep -E '^(PASS|FAIL|[0-9]+ checks)'`
Expected: 18 `PASS` lines and `18 checks, 0 failed`. Takes several minutes.

If `--platform linux/amd64` fails with an exec format error, re-run with `PLATFORM=linux/arm64 bash tests/ubuntu-container.sh` and note it in the final report.

For any `FAIL`: read `/tmp/dotfiles-ubuntu-test.log`, fix the cause in `lib/`, `bootstrap.sh` or `config/zsh`, re-run `bash tests/test_common.sh` (must stay green), then re-run this step.

- [ ] **Step 5: Stop the test VM**

```bash
colima stop --profile dotfiles-test
unset DOCKER_CONTEXT
```

- [ ] **Step 6: shellcheck and commit**

Run: `mise exec shellcheck@latest -- shellcheck -x bootstrap.sh lib/*.sh tests/*.sh`
Expected: no output.

```bash
git add tests/ubuntu-container.sh tests/ubuntu-checks.sh
git commit -m "tests: run bootstrap end to end in an Ubuntu 24.04 container" -- tests lib bootstrap.sh config/zsh
```

---

### Task 10: Migrate this Mac and verify

**Files:** none tracked (changes `$HOME` links and local files)

- [ ] **Step 1: Record the current state**

```bash
ls -la ~/.gitconfig ~/.zshrc ~/.config/zsh ~/.config/wezterm ~/.config/nvim ~/.ssh/config 2>&1
grep -c '^Host ' ~/.ssh/config
```
Note the host count for Step 4.

- [ ] **Step 2: Remove links unrelated to any package**

`~/.zshrc.pre-oh-my-zsh` still resolves into the repo but is no longer used:

```bash
rm ~/.zshrc.pre-oh-my-zsh
```

- [ ] **Step 3: Run the bootstrap in links-only mode**

Run: `bash bootstrap.sh --links-only`
Expected: steps logged without `error:`; backups logged for `~/.config/nvim` and `~/.config/mise/config.toml`; `moved ~/.ssh/config to ~/.ssh/config.d/legacy`; stale links removed for `~/.gitconfig`, `~/.gitconfig_company`, `~/.gitconfig_personal`, `~/.gitattributes`, `~/.gitignore_global`, `~/.gitmessage`, `~/.ssh/config 2`.

- [ ] **Step 4: Verify links, backups and SSH**

Run:
```bash
source tests/lib.sh
check "zshrc linked" assert_link_to ~/.zshrc config/zsh/.zshrc
check "gitconfig linked" assert_link_to ~/.gitconfig config/git/.gitconfig
check "ssh config linked" assert_link_to ~/.ssh/config config/ssh/.ssh/config
check "nvim linked" assert_link_to ~/.config/nvim config/nvim/.config/nvim
check "wezterm linked" assert_link_to ~/.config/wezterm config/wezterm/.config/wezterm
check "~/.config/zsh unfolded" assert_dir ~/.config/zsh
check "old nvim backed up" test -f ~/.dotfiles-backup/*/.config/nvim/init.lua
check "legacy hosts kept" test "$(grep -c '^Host ' ~/.ssh/config.d/legacy)" -gt 0
check "company git file kept" test -f ~/.config/git/company
finish
```
Expected: `9 checks, 0 failed`. The legacy host count equals the count from Step 1.

Run: `host=$(awk '$1 == "Host" && $2 !~ /[*]/ { print $2; exit }' ~/.ssh/config.d/legacy); ssh -G "$host" | grep -cE '^(hostname|controlpath) '`
Expected: `2`

- [ ] **Step 5: Verify git identity comes from the shared config**

```bash
git config --local --unset user.name
git config --local --unset user.email
git config user.email
git config push.default
```
Expected: `sangvo111@gmail.com` then `simple`.

- [ ] **Step 6: Verify zsh, nvim and WezTerm**

Run: `zsh -i -c exit 2>&1 | grep -v 'stdin isn.t a terminal'; echo "exit=${pipestatus[1]}"`
Expected: no output, `exit=0`

Run: `nvim --headless +qa; echo "exit=$?"`
Expected: `exit=0`

Run: `wezterm --config-file ~/.config/wezterm/wezterm.lua show-keys --lua >/dev/null; echo "exit=$?"`
Expected: `exit=0`

- [ ] **Step 7: Re-run to confirm idempotency**

Run: `bash bootstrap.sh --links-only 2>&1 | grep -E 'backed up|moved|removed stale|error' || echo nothing-changed`
Expected: `nothing-changed`

- [ ] **Step 8: Final test pass and report**

Run: `bash tests/test_common.sh && mise exec shellcheck@latest -- shellcheck -x bootstrap.sh lib/*.sh tests/*.sh && git status --short`
Expected: `15 checks, 0 failed`, no shellcheck output, clean `git status`.

Report to the user: commits created (not pushed), backup directory path, the legacy SSH file to split later, and that `~/.config/git/company` and `~/.ssh/config.d/` hold the company data.
