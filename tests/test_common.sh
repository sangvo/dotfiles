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
