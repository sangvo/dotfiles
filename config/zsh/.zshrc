source ~/.config/zsh/zsh-defer/zsh-defer.plugin.zsh

# If you come from bash you might have to change your $PATH.
export PATH=$HOME/.local/bin:$PATH

# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="robbyrussell"

# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in $ZSH/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment the following line to disable bi-weekly auto-update checks.
# DISABLE_AUTO_UPDATE="true"

# Uncomment the following line to automatically update without prompting.
# DISABLE_UPDATE_PROMPT="true"

# Uncomment the following line to change how often to auto-update (in days).
# export UPDATE_ZSH_DAYS=13

# Uncomment the following line if pasting URLs and other text is messed up.
DISABLE_MAGIC_FUNCTIONS=true

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(
  sudo docker-compose
)

source $ZSH/oh-my-zsh.sh

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='mvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.

#Key binding #################################################################
stty -ixon

# vi mode
bindkey -v
bindkey "^a" beginning-of-line
bindkey "^e" end-of-line
bindkey "^b" backward-char
bindkey "^f" forward-char
bindkey "^u" kill-whole-line
bindkey "^w" backward-kill-word
bindkey "^s" history-incremental-search-backward
bindkey "^n" history-search-forward
bindkey "^p" history-search-backward
bindkey "^ " autosuggest-accept

export EDITOR="vim"

# Example aliases
alias zshconfig="nvim ~/.zshrc"
alias ws="cd ~/workspace"
alias co="cd ~/company"
alias cls="clear"
alias kill3000="fuser -k 3000/tcp"
alias joke='curl -H "Accept: text/plain" https://icanhazdadjoke.com'

# Git
alias gco='git checkout'
alias gb='git branch'
alias gpf='git push --force-with-lease'
alias gst='git status'

# Awesome ls
alias ls="lsd -F"
alias la="lsd -Fah"
alias ll="lsd -Flh"
alias l="lsd -Flah"

# Git
alias recent-branch="git for-each-ref --sort=-committerdate --format='%(refname:short)' refs/heads/ |  fzf | sed 's/\* //g' | xargs -I '{}' git checkout {}"

# Jekyll
alias js="bundle exec jekyll serve --drafts"

# Auto add bundle exec rails command
# for cmd in rspec ruby rubocop rails; do
#   alias $cmd="bundle exec $cmd"
# done

# Zsh Defer

zsh-defer source ~/.config/zsh/zsh-fzf.zsh
zsh-defer source ~/.config/zsh/zsh-export-path.zsh
zsh-defer source ~/.config/zsh/zsh-autosuggestions/zsh-autosuggestions.zsh
zsh-defer source ~/.config/zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# Generated for envman. Do not edit.
[ -s "$HOME/.config/envman/load.sh" ] && source "$HOME/.config/envman/load.sh"


# pnpm
export PNPM_HOME="/home/sangvo/.local/share/pnpm"
export PATH="$PNPM_HOME:$PATH"
# pnpm end
export GTK_IM_MODULE=ibus
export XMODIFIERS=@im=ibus
export QT_IM_MODULE=ibus
