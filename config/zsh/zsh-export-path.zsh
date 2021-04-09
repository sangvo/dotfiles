# Add rbenv
export PATH="$HOME/.rbenv/bin:$PATH"
if command -v rbenv 1>/dev/null 2>&1; then
  eval "$(rbenv init -)"
fi
export PATH="$HOME/.rbenv/plugins/ruby-build/bin:$PATH"

# Yarn
if command -v yarn 1>/dev/null 2>&1; then
  export PATH="$PATH:$HOME/.yarn/bin"
fi

# Cargo
export PATH="$PATH:$HOME/.cargo/bin"

# Go
export PATH=$PATH:/usr/local/go/bin

# direnv
eval "$(direnv hook zsh)"

# NVM
export NVM_DIR="$HOME/.nvm"

# Go
export PATH=$PATH:/usr/local/go/bin
