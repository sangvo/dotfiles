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
  run_step "Installing Neovim config" install_nvim_config
  if [[ $links_only == false ]]; then
    run_step "Installing mise tools" install_mise_tools
    run_step "Installing nvim plugins" sync_nvim
  fi
  run_step "Setting login shell" set_default_shell
  log "Done. Open a new terminal to load the shell config."
}

main "$@"
