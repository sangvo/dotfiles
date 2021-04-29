# Tiling window manager
ln -s -f ~/workspace/dotfiles/config/vm/* ~/.config

mkdir -p ~/.zsh
ln -s -f ~/workspace/dotfiles/config/zsh/* ~/.zsh
ln -s -f ~/workspace/dotfiles/.zshrc ~/.zshrc

ln -s -f ~/workspace/dotfiles/.tmux.conf ~/.tmux.conf

rm -r -f ~/.config/nvim
ln -s -f ~/workspace/dotfiles/config/nvim ~/.config/nvim

rm -r -f ~/.fonts
ln -s -f ~/workspace/dotfiles/fonts ~/.fonts

ln -s -f ~/workspace/dotfiles/config/alacritty/.alacritty.yml $HOME/.alacritty.yml

nvim +PlugInstall +qall
