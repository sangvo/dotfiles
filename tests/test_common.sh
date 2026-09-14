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
