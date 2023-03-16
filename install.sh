# Tiling window manager
ln -s -f ~/workspace/dotfiles/config/vm/* ~/.config

# ZSH
stow zsh -t ~

# Git & SSH
ln -s -f ~/workspace/dotfiles/multi_ssh_git_config ~/.ssh/config
stow gitconfig sshconfig -t ~

rm -r -f ~/.config/nvim
ln -s -f ~/workspace/dotfiles/config/nvim ~/.config/nvim

rm -r -f ~/.fonts
ln -s -f ~/workspace/dotfiles/fonts ~/.fonts
