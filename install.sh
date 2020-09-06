ln -s -f ~/workspace/dotfiles/.zshrc ~/.zshrc
ln -s -f ~/workspace/dotfiles/tmux.conf ~/.tmux.conf

rm -r -f ~/.config/nvim
ln -s -f ~/workspace/dotfiles/nvim ~/.config/nvim

rm -r -f ~/.fonts
ln -s -f ~/workspace/dotfiles/fonts ~/.fonts

rm ~/.alacritty.yml
ln -s -f ~/workspace/dotfiles/config/alacritty/alacritty.yml ~/.alacritty.yml

nvim +PlugInstall +qall
