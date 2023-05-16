#!/bin/sh
success () {
  printf "\r\033[2K [\033[00;32mOK\033[0m] $1\n"
}

info() {
    printf "\e[0;34m$1\e[0m\n"
}

ask() {
  prompt="$1"
  default="$2"
  answer=""

  if [ -z "$default" ]; then
    prompt="$prompt (y/n)"
  elif [ "$default" = "y" ] || [ "$default" = "Y" ]; then
    prompt="$prompt (Y/n)"
  elif [ "$default" = "n" ] || [ "$default" = "N" ]; then
    prompt="$prompt (y/N)"
  else
    echo "Invalid default value: $default" >&2
    return 1
  fi

  while true; do
    printf "%s " "$prompt"
    read answer

    if [ -z "$answer" ]; then
      answer="$default"
    fi

    if [ "$answer" = "y" ] || [ "$answer" = "Y" ] || [ "$answer" = "yes" ] || [ "$answer" = "YES" ]; then
      return 0
    elif [ "$answer" = "n" ] || [ "$answer" = "N" ] || [ "$answer" = "no" ] || [ "$answer" = "NO" ]; then
      return 1
    else
      echo "Invalid input: $answer" >&2
    fi
  done
}

# Bail on any errors
set -e

install_packages() {
  if ask "Do you want to install/update package? [y|N]"; then
    updated_apt_repo=""
    sudo apt-get install build-essential zsh vim tmux curl mpd flameshot software-properties-common apt-transport-https -y

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
        nginx \
        redis-server \
        unzip \
        jq \
        libnss3-tools \
        python3-pip
  else
    info "Skipped install package"
  fi
}

install_command_line_tools() {
  if ask "Do you want to install/update command line tools? [y|N]"; then
    sudo apt install bat -y
    builddir=$(mktemp -d -t commandtool.XXXXX)
    wget -c https://github.com/BurntSushi/ripgrep/releases/download/12.1.1/ripgrep_12.1.1_amd64.deb -P "$builddir"
    sudo dpkg -i "${builddir}/ripgrep_12.1.1_amd64.deb"
    info "Installed ripgrep"

    wget -c https://github.com/sharkdp/fd/releases/download/v8.2.1/fd_8.2.1_amd64.deb -P "$builddir"

    sudo dpkg -i "${builddir}/fd_8.2.1_amd64.deb"
    info "Installed fd"
    rm -rf "$builddir"
  else
    info "Skipped command line tools"
  fi
}

install_interface_app() {
  if ask "Do you want to install/update tiling window? [y|N]"; then
    info "Installing Bspwm, polybar, rofi,..."
    sudo apt install bspwm rofi feh -y
    sudo apt install build-essential git cmake cmake-data pkg-config python3-sphinx python3-packaging libuv1-dev libcairo2-dev libxcb1-dev libxcb-util0-dev libxcb-randr0-dev libxcb-composite0-dev python3-xcbgen xcb-proto libxcb-image0-dev libxcb-ewmh-dev libxcb-icccm4-dev
    builddir=$(mktemp -d -t wm.XXXXX)
    git clone --recursive https://github.com/polybar/polybar "$builddir"
    cd "$builddir"
    mkdir build
    cd build
    cmake ..
    make -j$(nproc)
    sudo make install
    success "Installed"
  else
    info "Skipped tiling window"
  fi
}

install_node() {
  if ask "Do you want to install/update Node? [y|N]"; then
    info "Installing Node"
    curl -sL https://deb.nodesource.com/setup_16.x | sudo -E bash -
    sudo apt-get install -y nodejs
    curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
    echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list
    sudo apt update && sudo apt install -y yarn
    success "Installed Node"
  else
    info "Skipped Node"
  fi
}

install_zsh() {
  if ask "Do you want to install/update Zsh? [y|N]"; then
    info "Installing Zsh"
    sudo apt install zsh -y
    sudo chsh -s $(which zsh)
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
    git clone https://github.com/romkatv/zsh-defer.git ~/.config/zsh/zsh-defer
    git clone https://github.com/zsh-users/zsh-autosuggestions ~/.config/zsh/zsh-autosuggestions
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ~/.config/zsh/zsh-syntax-highlighting
    git clone https://github.com/rupa/z.git ~/.config/zsh/z
    success "Installed Zsh"
  else
    info "Skipped Zsh"
  fi
}

install_postgresql() {
  if ask "Do you want to install/update Rust? [y|N]"; then
   # Add PostgreSQL 14 repository
    sudo sh -c 'echo "deb [arch=amd64] http://apt.postgresql.org/pub/repos/apt/ $(lsb_release -cs)-pgdg main 14" > /etc/apt/sources.list.d/pgdg.list'
    wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -

    # Update package list and install PostgreSQL 14
    sudo apt update
    sudo apt install -y postgresql-14

    # Start PostgreSQL service
    sudo systemctl start postgresql

    # Enable PostgreSQL service to start on boot
    sudo systemctl enable postgresql

    # Configure PostgreSQL to listen on all network interfaces
    sudo sed -i "s/#listen_addresses = 'localhost'/listen_addresses = '*'/" /etc/postgresql/14/main/postgresql.conf

    # Allow remote connections to PostgreSQL from any IP address
    echo "host    all             all             0.0.0.0/0            md5" | sudo tee -a /etc/postgresql/14/main/pg_hba.conf

    # Restart PostgreSQL service for changes to take effect
    sudo systemctl restart postgresql
  else
    info "Skipped PostgreSQL"
  fi
}

install_mysql() {
  if ask "Do you want to install/update Mysql server? [y|N]"; then
    # Download and add the MySQL 8 repository key
    wget -c https://dev.mysql.com/get/mysql-apt-config_0.8.17-1_all.deb -P /tmp
    sudo dpkg -i /tmp/mysql-apt-config_0.8.17-1_all.deb

    # Install MySQL 8
    sudo apt update
    sudo apt install -y mysql-server

    # Start MySQL service
    sudo systemctl start mysql

    # Enable MySQL service to start on boot
    sudo systemctl enable mysql

    # Secure MySQL installation
    sudo mysql_secure_installation
    info "Installed Mysql"
  else
    info "Skipped Mysql"
  fi
}

install_go() {
  if ask "Do you want to install/update Go? [y|N]"; then
     # Download and extract Go 1.19
    builddir=$(mktemp -d -t mkcert.XXXXX)
    wget -c https://dl.google.com/go/go1.19.linux-amd64.tar.gz -P "$builddir"
    sudo tar -C /usr/local -xzf "${builddir}/go1.19.linux-amd64.tar.gz"
    rm -rf "$builddir"
  else
    info "Skipped Go"
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

install_rust() {
  if ask "Do you want to install/update Rust? [y|N]"; then
    builddir=$(mktemp -d -t rustup.XXXXX)

    (
        cd "$builddir"
        curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs --output rustup-init.sh
        bash rustup-init.sh -y --profile default --no-modify-path
    )
    info "Installed Rust"
    # cleanup temporary build directory
    sudo rm -rf "$builddir"
  else
    info "Skipped Rust"
  fi
}

install_ruby() {
  if ask "Do you want to install/update Ruby? [y|N]"; then
    info "Installing ruby"
    sudo apt-get install -y libssl-dev zlib1g-dev
    git clone https://github.com/rbenv/rbenv.git ~/.rbenv
    cd ~/.rbenv && src/configure && make -C src
    ~/.rbenv/bin/rbenv init
    mkdir -p "$(rbenv root)"/plugins
    git clone https://github.com/rbenv/ruby-build.git "$(rbenv root)"/plugins/ruby-build
    success "Installed Ruby"
  else
    info "Skipped Ruby"
  fi
}

install_pyenv() {
  if ask "Do you want to install/update Pyenv? [y|N]"; then
    info "Installing pyenv"
    sudo apt install build-essential libsqlite3-dev sqlite3 bzip2 libbz2-dev libffi-dev
    git clone https://github.com/pyenv/pyenv.git ~/.pyenv
    success "Installed Pyenv"
  else
    info "Skipped Pyenv"
  fi
}

install_nvim() {
  if ask "Do you want to install/update Nvim? [y|N]"; then
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
  else
    info "Skipped Nvim"
  fi
}

install_docker() {
    if ask "Do you want to install/update Docker? [y|N]"; then
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
  else
    info "Skipped Docker"
  fi
}

install_docker_compose() {
  if ask "Do you want to install/update Docker Compose? [y|N]"; then
    sudo curl -L "https://github.com/docker/compose/releases/download/1.28.6/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose
    success "Docker Compose Installed"
  else
    info "Skipped Docker Compose"
  fi
}

install_latest_chrome() {
    if ask "Do you want to install/update Chrome? [y|N]"; then
      info "Installing Google Chrome"
      echo "deb http://dl.google.com/linux/chrome/deb/ stable main" \
          | sudo tee /etc/apt/sources.list.d/google-chrome.list
      wget -O- https://dl-ssl.google.com/linux/linux_signing_key.pub \
          | sudo apt-key add -
      sudo apt update -y
      sudo apt install google-chrome-stable
      success "Installed Google Chrome"
    else
      info "Skipped Google Chrome"
    fi
}

echo
info "🚀 Running bootstrap Ubuntu 🚀"

echo

# Run sudo once at the beginning to get the necessary permissions.
info "--> This setup script needs your password to install things as root."
echo
sudo sh -c 'echo OK'
echo

install_packages
install_interface_app
install_command_line_tools
install_mysql
install_postgresql
install_node
install_rust
install_ruby
install_pyenv
install_go
install_mkcert
install_nvim
install_docker
install_docker_compose
install_postgresql
install_latest_chrome

trap - EXIT
