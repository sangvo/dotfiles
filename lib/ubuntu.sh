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
