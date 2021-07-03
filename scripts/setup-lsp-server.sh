#!/usr/bin/env bash

get_platform() {
  case "$(uname -s)" in
  Linux*) platform=Linux ;;
  Darwin*) platform=Mac ;;
  CYGWIN*) platform=Cygwin ;;
  MINGW*) platform=MinGw ;;
  *) platform="UNKNOWN:${unameOut}" ;;
  esac
  echo $platform
}

default_lsp_langs="css html ts bash json"
lsp_langs=""

pfx="~~~~~ "
heading() {
  echo
  echo $pfx $1
}

choose_langs() {
  read -p "Would you like to install $1 lsp?(y/n)" lang
  if [ "$lang" = "y" ]; then
    lsp_langs+="$1 "
  fi
}

for lang in $default_lsp_langs; do
  choose_langs $lang
done


fn_exists() { declare -F "$1" >/dev/null; }

install_node_deps() {
  if [[ -z $(which npm) ]]; then
    echo "npm not installed"
    return
  fi
  npm install -g $@
}

# install languages

install_ts() {
  install_node_deps typescript typescript-language-server prettier
}

install_html() {
  install_node_deps vscode-html-languageserver-bin
}

install_css() {
  install_node_deps vscode-css-languageserver-bin
}

install_json() {
  install_node_deps vscode-json-languageserver
}

install_bash() {
  install_node_deps bash-language-server
}

for lang in ${lsp_langs}; do
  if fn_exists install_$lang; then
    heading "Installing $lang language server"
    install_$lang
  else
    echo $lang setup not implemented
    echo
  fi
done
