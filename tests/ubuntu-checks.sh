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

# Run every line of tmux.conf on a throwaway server; tmux exits 1 on the first bad line.
tmux_config_loads() {
  local rc=0
  tmux -L check -f /dev/null new-session -d
  tmux -L check source-file "$HOME/.config/tmux/tmux.conf" || rc=$?
  tmux -L check kill-server
  return "$rc"
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
check "home .ssh is a real directory" assert_dir "$HOME/.ssh"
check "ssh config linked" assert_link_to "$HOME/.ssh/config" "$DOTFILES_DIR/config/ssh/.ssh/config"
check "home .config/git is a real directory" assert_dir "$HOME/.config/git"
check "home .config/mise is a real directory" assert_dir "$HOME/.config/mise"
check "nvim config cloned" assert_eq "$(git -C "$HOME/.config/nvim" remote get-url origin)" https://github.com/sangvo/nvim.git
check "wezterm config linked" assert_link_to "$HOME/.config/wezterm" "$DOTFILES_DIR/config/wezterm/.config/wezterm"
check "alacritty config linked" assert_link_to "$HOME/.config/alacritty" "$DOTFILES_DIR/config/alacritty/.config/alacritty"
check "tmux config linked" assert_link_to "$HOME/.config/tmux/tmux.conf" "$DOTFILES_DIR/config/tmux/.config/tmux/tmux.conf"
check "vscode settings linked" assert_link_to "$HOME/.config/Code/User/settings.json" "$DOTFILES_DIR/vscode/settings.json"
check "fontconfig rule linked" assert_link_to "$HOME/.config/fontconfig/conf.d/50-cascadia-code-nf.conf" "$DOTFILES_DIR/config/fontconfig/.config/fontconfig/conf.d/50-cascadia-code-nf.conf"
check "local git config created" assert_file "$HOME/.gitconfig.local"
check "wezterm installed" command -v wezterm
check "alacritty installed" command -v alacritty
check "tmux plugins installed" test -f "$HOME/.tmux/plugins/tmux-resurrect/resurrect.tmux"
check "tmux config loads" tmux_config_loads
check "fonts installed" test -f "$HOME/.local/share/fonts/SymbolsNerdFont-Regular.ttf"
check "Cascadia Code NF installed" test -f "$HOME/.local/share/fonts/CascadiaCodeNF.ttf"
check "Cascadia Code NF uses grayscale AA" assert_eq "$(fc-match -f '%{rgba}' 'Cascadia Code NF')" 5
check "push.default is simple" assert_eq "$(git config --global push.default)" simple
check "zsh -i starts without output" assert_eq "$(zsh -i -c exit 2>&1)" ""
# shellcheck disable=SC2016 # zsh code, expanded by zsh
check "tools on PATH in zsh" zsh -i -c 'for t in nvim lazygit fzf rg fd lsd delta direnv node go; do (( $+commands[$t] )) || { print "missing $t" >&2; exit 1; }; done'
check "nvim plugins installed" test -d "$HOME/.local/share/nvim/site/pack/core/opt/telescope.nvim"
check "nvim starts cleanly" zsh -i -c 'nvim --headless +qa'
check "interactive zsh shows no errors" interactive_zsh_clean
finish
