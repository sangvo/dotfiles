# Add rbenv
# export PATH="$HOME/.rbenv/bin:$PATH"
# export PATH="$HOME/.rbenv/plugins/ruby-build/bin:$PATH"
# if command -v rbenv 1>/dev/null 2>&1; then
#   eval "$(~/.rbenv/bin/rbenv init - zsh)"
# fi

# https://github.com/rbenv/ruby-build/wiki#suggested-build-environment
export RUBY_CONFIGURE_OPTS="--with-openssl-dir=$(brew --prefix openssl@1.1)"

# Pyenv
# export PYENV_ROOT="$HOME/.pyenv"
# export PATH="$PYENV_ROOT/bin:$PATH"
# if command -v pyenv 1>/dev/null 2>&1; then
#   eval "$(pyenv init -)"
# fi


# Yarn
if command -v yarn 1>/dev/null 2>&1; then
  export PATH="$PATH:$HOME/.yarn/bin"
  export PATH="$PATH:$(yarn global bin)"
fi

# asdf
case `uname` in
  Darwin)
    . /opt/homebrew/opt/asdf/libexec/asdf.sh
  ;;
  Linux)
    . /opt/asdf-vm/asdf.sh
  ;;
esac

# Cargo
export PATH="$PATH:$HOME/.cargo/bin"

# Go
export GOPATH=$HOME/go
export PATH=$PATH:/usr/local/go/bin:$GOPATH/bin

# NVM
# export NVM_DIR="$HOME/.nvm"
# [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

# exercism
export PATH=~/bin:$PATH

# Fly
export FLYCTL_INSTALL="/home/sangvo/.fly"
export PATH="$FLYCTL_INSTALL/bin:$PATH"

GPG_TTY=$(tty)
export GPG_TTY

. ~/.zsh/z/z.sh
