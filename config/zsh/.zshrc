source ~/.config/zsh/zsh-defer/zsh-defer.plugin.zsh

export PATH=$HOME/.local/bin:$PATH
export PATH=/opt/homebrew/bin:$PATH

# replacement for oh-my-zsh
source ~/.config/zsh/zsh-core.zsh

export LANG=en_US.UTF-8
export EDITOR="vim"

# Key bindings -----------------------------------------------------------------
stty -ixon

# vi mode
bindkey -v
bindkey "^A" beginning-of-line
bindkey "^e" end-of-line
bindkey "^b" backward-char
bindkey "^f" forward-char
bindkey "^u" kill-whole-line
bindkey "^w" backward-kill-word
bindkey "^s" history-incremental-search-backward
bindkey "^n" history-search-forward
bindkey "^p" history-search-backward
bindkey "^ " autosuggest-accept

# Aliases ----------------------------------------------------------------------
alias ws="cd ~/workspace"
alias co="cd ~/company"
alias cls="clear"
alias joke='curl -H "Accept: text/plain" https://icanhazdadjoke.com'
alias dot='git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'

# Git
alias gco='git checkout'
alias gst='git status'
alias recent-branch="git for-each-ref --sort=-committerdate --format='%(refname:short)' refs/heads/ |  fzf | sed 's/\* //g' | xargs -I '{}' git checkout {}"

# Awesome ls
alias ls="lsd -F"
alias la="lsd -Fah"
alias l="lsd -Flah"

# Deferred (run after the first prompt) ----------------------------------------
zsh-defer source ~/.config/zsh/zsh-fzf.zsh
zsh-defer source ~/.config/zsh/zsh-export-path.zsh
zsh-defer source ~/.config/zsh/zsh-autosuggestions/zsh-autosuggestions.zsh
zsh-defer source ~/.config/zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

export GPG_TTY=$TTY
zsh-defer gpgconf --launch gpg-agent
zsh-defer -c 'eval "$(thefuck --alias)"'

# Tools ------------------------------------------------------------------------
eval "$(mise activate zsh)"
eval "$(direnv hook zsh)"

# Added by Antigravity
export PATH="/Users/sangvo/.antigravity/antigravity/bin:$PATH"
