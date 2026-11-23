#!/usr/bin/env bash
# macOS package installation. Sourced by bootstrap.sh after lib/common.sh.

BREW_PREFIX=/opt/homebrew
VSCODE_USER_DIR="$HOME/Library/Application Support/Code/User"

install_packages() {
  if [[ ! -x $BREW_PREFIX/bin/brew ]]; then
    log "installing Homebrew"
    sudo -v
    NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  fi
  eval "$("$BREW_PREFIX/bin/brew" shellenv)"
  brew bundle --file "$DOTFILES_DIR/Brewfile" --no-upgrade
}
