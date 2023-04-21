#!/bin/sh
success () {
  printf "\r\033[2K [\033[00;32mOK\033[0m] $1\n"
}

info() {
    printf "\e[0;34m$1\e[0m\n"
}


# Bail on any errors
set -e

DESIRED_GO_MAJOR_VERISON=1
DESIRED_GO_MINOR_VERISON=19
DESIRED_GO_VERSION="$DESIRED_GO_MAJOR_VERISON.$DESIRED_GO_MINOR_VERISON"

# Evaluates to truthy if go is installed and
# >=$DESIRED_GO_VERSION.  Evaluates to falsey else.
has_recent_go() {
    which go >/dev/null || return 1
    go_version=`go version`
    go_major_version=`expr "$go_version" : '.*go\([0-9]*\)'`
    go_minor_version=`expr "$go_version" : '.*go[0-9]*\.\([0-9]*\)'`
    [ "$go_major_version" -gt "$DESIRED_GO_MAJOR_VERISON" \
        -o "$go_minor_version" -ge "$DESIRED_GO_MINOR_VERISON" ]
}

install_go() {
    if ! has_recent_go; then   # has_recent_go is from shared-functions.sh
        # This PPA is needed for ubuntus <20 but not >=20
        # (and it doesn't install for them anyway)
        sudo add-apt-repository -y ppa:longsleep/golang-backports && sudo apt-get update -qq -y || sudo add-apt-repository -y -r ppa:longsleep/golang-backports
        sudo apt-get install -y "golang-$DESIRED_GO_VERSION"
        # The ppa installs go into /usr/lib/go-<version>/bin/go
        # Let's link that to somewhere likely to be on $PATH
        sudo cp -sf /usr/lib/"go-$DESIRED_GO_VERSION"/bin/* /usr/local/bin/
    else
        info "golang already installed"
    fi
}

# NOTE: This depends on `go` being installed.
install_mkcert() {
    if ! which mkcert >/dev/null; then
        info "Installing mkcert..."
        builddir=$(mktemp -d -t mkcert.XXXXX)
        git clone https://github.com/FiloSottile/mkcert "$builddir"

        (
            cd "$builddir"
            go mod download
            go build -ldflags "-X main.Version=$(git describe --tags)"
            sudo install -m 755 mkcert /usr/local/bin
        )

        # cleanup temporary build directory
        rm -rf "$builddir"

        mkcert -install

        echo "A CA has been added to your system and browser certificate "
        echo "trust stores."
        echo ""
        echo "You must RESTART your browser in order for it to recognize "
        echo "the new CA and in some situations you may need REBOOT your "
        echo "machine."
    else
        info "mkcert already installed"
    fi
}

install_packages() {
    updated_apt_repo=""

    # This is needed to get the add-apt-repository command.
    # apt-transport-https may not be strictly necessary, but can help
    # for future updates.
    sudo apt-get install build-essential zsh vim tmux curl mpd software-properties-common apt-transport-https -y

    # To get the most recent git, later.
    if ! ls /etc/apt/sources.list.d/ 2>&1 | grep -q git-core-ppa; then
        sudo add-apt-repository -y ppa:git-core/ppa
        updated_apt_repo=yes
    fi

    # Register all that stuff we just did.
    if [ -n "$updated_apt_repo" ]; then
        sudo apt-get update -qq -y || true
    fi

    sudo apt-get install -y git \
        libfreetype6 libfreetype6-dev libpng-dev libjpeg-dev \
        imagemagick \
        libxslt1-dev \
        libyaml-dev \
        libncurses-dev libreadline-dev \
        nodejs \
        nginx \
        redis-server \
        unzip \
        jq \
        libnss3-tools \
        python3-pip

    # We use go for our code, going forward
    install_go

    # Used to create and install security certificates, see the docstring
    # for this function for more details.
    install_mkcert
}

install_zsh() {
  read -r -p "Do you want to install Zsh? [y|N] " response
  if [[ $response =~ y|yes|Y ]];then
    info "Installing Zsh"
    sudo apt install zsh -y
    sudo chsh -s $(which zsh)
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
    git clone https://github.com/romkatv/zsh-defer.git ~/.config/zsh/zsh-defer
    git clone https://github.com/zsh-users/zsh-autosuggestions ~/.config/zsh/zsh-autosuggestions
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ~/.config/zsh/zsh-syntax-highlighting
    git clone https://github.com/rupa/z.git ~/.config/zsh/z
    success "Installed Zsh"
  fi
}

install_postgresql() {
    curl https://www.postgresql.org/media/keys/ACCC4CF8.asc \
        | gpg --dearmor | sudo tee /etc/apt/trusted.gpg.d/apt.postgresql.org.gpg >/dev/null

    sudo add-apt-repository -y "deb http://apt.postgresql.org/pub/repos/apt/ `lsb_release -c -s`-pgdg main"
    sudo apt-get update
    sudo apt-get install -y postgresql-11

    # Set up authentication to allow connections from the postgres user with no
    # password. This matches the authentication setup that homebrew installs on
    # a mac. Unlike a mac, we do not need to create a postgres user manually.
    sudo cp -av postgresql/pg_hba.conf "/etc/postgresql/11/main/pg_hba.conf"
    sudo chown postgres.postgres "/etc/postgresql/11/main/pg_hba.conf"
    sudo service postgresql restart
    success "postgresql 11 installed"
}

install_rust() {
    read -r -p "Do you want to install Rust? [y|N] " response
    if [[ $response =~ y|yes|Y ]];then
      builddir=$(mktemp -d -t rustup.XXXXX)

      (
          cd "$builddir"
          curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs --output rustup-init.sh
          bash rustup-init.sh -y --profile default --no-modify-path
      )

      # cleanup temporary build directory
      sudo rm -rf "$builddir"
    fi
}

install_ruby() {
  read -r -p "Do you want to install Ruby? [y|N] " response
  if [[ $response =~ y|yes|Y ]];then
    info "Installing ruby"
    sudo apt-get install -y libssl-dev zlib1g-dev
    git clone https://github.com/rbenv/rbenv.git ~/.rbenv
    cd ~/.rbenv && src/configure && make -C src
    ~/.rbenv/bin/rbenv init
    mkdir -p "$(rbenv root)"/plugins
    git clone https://github.com/rbenv/ruby-build.git "$(rbenv root)"/plugins/ruby-build
    success "Installed Ruby"
  fi
}

install_nvim() {
  read -r -p "Do you want to install/update Nvim? [y|N] " response
  if [[ $response =~ y|yes|Y ]];then
    builddir=$(mktemp -d -t nvim.XXXXX)
    (
      info "Installing nvim"
      cd "$builddir"
      sudo apt update
      sudo apt-get install ninja-build gettext libtool libtool-bin autoconf automake cmake g++ pkg-config unzip -y
      sudo apt install xclip -y
      git clone https://github.com/neovim/neovim.git
      cd neovim
      git checkout stable

      sudo rm /usr/local/bin/nvim
      sudo rm -r /usr/local/share/nvim/

      make CMAKE_BUILD_TYPE=RelWithDebInfo
      sudo make install
      success "Installed nvim"
    )

    # cleanup temporary build directory
    sudo rm -rf "$builddir"
  fi
}

install_docker() {
  read -r -p "Do you want to install Docker? [y|N] " response
  if [[ $response =~ y|yes|Y ]];then
    info "Installing Docker..."
    sudo apt-get remove docker docker-engine docker.io containerd runc
    sudo apt-get update -y
    sudo apt-get install \
        apt-transport-https \
        ca-certificates \
        curl \
        gnupg-agent \
        software-properties-common
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
    sudo add-apt-repository \
       "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
       $(lsb_release -cs) \
       stable"
    sudo apt-get update -y
    sudo apt-get install docker-ce docker-ce-cli containerd.io -y
    info "Setting docker without sudo"
    sudo groupadd docker
    sudo usermod -aG docker $USER
    newgrp docker
    success "Installed Docker"
  fi
}

install_docker_compose() {
  read -r -p "Do you want to install docker-compose? [y|N] " response
  if [[ $response =~ y|yes|Y ]];then
    sudo curl -L "https://github.com/docker/compose/releases/download/1.28.6/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose
    success "Docker Compose Installed"
  fi
}

install_latest_chrome() {
    info "Installing Google Chrome"
    echo "deb http://dl.google.com/linux/chrome/deb/ stable main" \
        | sudo tee /etc/apt/sources.list.d/google-chrome.list
    wget -O- https://dl-ssl.google.com/linux/linux_signing_key.pub \
        | sudo apt-key add -
    sudo apt update -y
    sudo apt install google-chrome-stable
    success "Installed Google Chrome"
}

echo
info "🚀 Running bootstrap Ubuntu 🚀"

echo

# Run sudo once at the beginning to get the necessary permissions.
info "--> This setup script needs your password to install things as root."
echo
sudo sh -c 'echo OK'
echo

# install_packages
# install_rust
# install_ruby
# install_nvim
# install_docker
# install_docker_compose
# install_postgresql
# install_latest_chrome

trap - EXIT
