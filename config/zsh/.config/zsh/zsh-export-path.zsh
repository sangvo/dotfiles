# Add rbenv
export PATH="$HOME/.rbenv/bin:$PATH"
export PATH="$HOME/.rbenv/plugins/ruby-build/bin:$PATH"
if command -v rbenv 1>/dev/null 2>&1; then
  eval "$(~/.rbenv/bin/rbenv init - zsh)"
fi

# Yarn
if command -v yarn 1>/dev/null 2>&1; then
  export PATH="$PATH:$HOME/.yarn/bin"
fi

# Cargo
export PATH="$PATH:$HOME/.cargo/bin"

# Go
export PATH=$PATH:/usr/local/go/bin
export GOPATH=$HOME/go
export PATH=$GOPATH/bin:$GOROOT/bin:$PATH

# NVM
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

# exercism
export PATH=~/bin:$PATH

. ~/.zsh/z/z.sh