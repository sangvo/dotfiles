source ~/.local/share/zsh/plugins/zsh-defer/zsh-defer.plugin.zsh

export PATH=$HOME/.local/bin:$PATH
if [[ -d /opt/homebrew/bin ]]; then
  export PATH=/opt/homebrew/bin:$PATH
fi

# replacement for oh-my-zsh
source ~/.config/zsh/zsh-core.zsh

export LANG=en_US.UTF-8
export EDITOR="nvim"

# Tools ------------------------------------------------------------------------
# Activated before the aliases so tools installed by mise are already on PATH.
if (( $+commands[mise] )); then
  eval "$(mise activate zsh)"
  eval "$(mise hook-env -s zsh)"
fi
if (( $+commands[direnv] )); then
  eval "$(direnv hook zsh)"
fi

# Key bindings -----------------------------------------------------------------
if [[ -t 0 ]]; then
  stty -ixon
fi

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
if (( $+commands[lsd] )); then
  alias ls="lsd -F"
  alias la="lsd -Fah"
  alias l="lsd -Flah"
fi

# Deferred (run after the first prompt) ----------------------------------------
zsh-defer source ~/.config/zsh/zsh-fzf.zsh
zsh-defer source ~/.config/zsh/zsh-export-path.zsh
zsh-defer source ~/.local/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
zsh-defer source ~/.local/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

export GPG_TTY=$TTY
if (( $+commands[gpgconf] )); then
  zsh-defer gpgconf --launch gpg-agent
fi
if (( $+commands[thefuck] )); then
  zsh-defer -c 'eval "$(thefuck --alias)"'
fi

# Added by Antigravity
if [[ -d $HOME/.antigravity/antigravity/bin ]]; then
  export PATH="$HOME/.antigravity/antigravity/bin:$PATH"
fi
