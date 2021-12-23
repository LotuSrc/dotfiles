#/bin/bash
#set -x

OS=centos
MIRROR=N
PROXY=N
PROXY_URL=https://ghproxy.com

# 安装zsh和neovim
if [[ $OS = 'macos' ]]
then
  echo "[00] install homebrew"
  if [[ $MIRROR = 'Y' ]]
  then
    export HOMEBREW_BREW_GIT_REMOTE="https://mirrors.tuna.tsinghua.edu.cn/git/homebrew/brew.git"
    export HOMEBREW_CORE_GIT_REMOTE="https://mirrors.tunz.tsinghua.edu.cn/git/homebrew/homebrew-core.git"
    export HOMEBREW_BOTTLE_DOMAIN="https://mirrors.tuna.tsinghua.edu.cn/homebrew-bottles"
    sh -c "$(curl -fsSL https://github.com/Homebrew/install/raw/master/install.sh)"
    if [[ $(uname -m) = 'arm64' ]]
    then
      test -r ~/.bash_profile && echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.bash_profile
      test -r ~/.zprofile && echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
    fi
  echo "[01] install [zsh|neovim]"
  brew install zsh
  brew install neovim
  fi
else
  sudo echo -e "\c"
  if [[ $? = 1 ]]
  then
    echo "[00] plz use root privilege to install zsh!"
    exit 1
  fi
  echo "[01] install [zsh|neovim]"
  if [[ $OS = 'centos' ]]
  then
    sudo dnf install -y zsh
    sudo dnf install -y ninja-build libtool autoconf automake cmake gcc gcc-c++ make pkgconfig unzip patch gettext curl
    if [[ $PROXY = 'Y' ]]
    then
      git clone --quiet $PROXY_URL/https://github.com/neovim/neovim
    else
      git clone --quiet https://github.com/neovim/neovim
    fi
    cd neovim && git checkout stable && make
    sudo make install
    cd .. && rm -rf neovim
  else
    sudo apt-get install -y -qq zsh
    sudo apt-get install -y -qq ninja-build gettext libtool libtool-bin autoconf automake cmake g++ pkg-config unzip curl doxygen
    if [[ $PROXY = 'Y' ]]
    then
      git clone -b stable --quiet $PROXY_URL/https://github.com/neovim/neovim 
    else
      git clone -b stable --quiet https://github.com/neovim/neovim
    fi
    make CMAKE_BUILD_TYPE=Release -C neovim 2>&1 >/dev/null
#     cd neovim && git checkout stable && make
    sudo make install -C neovim 2>&1 >/dev/null
    rm -rf neovim
  fi
fi

if [[ $PROXY = 'Y' ]]
then
  echo "[02] proxy switch on: $PROXY_URL"
  echo "[03] plugin install [ohmyzsh|zsh-autosuggestions|zsh-syntax-highlighting]"
  sh -c "$(curl -fsSL $PROXY_URL/https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
  git clone --quiet $PROXY_URL/https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
  git clone --quiet $PROXY_URL/https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
  echo "[04] install lunarvim"
  sh -c "$(curl -s $PROXY_URL/https://raw.githubusercontent.com/lunarvim/lunarvim/master/utils/installer/install.sh)"
  echo "[05] install powerlevel10k theme"
  git clone --depth=1 $PROXY_URL/https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
  
else
  echo "[02] proxy switch off"
  echo "[03] plugin install [ohmyzsh|zsh-autosuggestions|zsh-syntax-highlighting]"
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
  git clone --quiet https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
  git clone --quiet https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
  echo "[04] install lunarvim"
  sh -c "$(curl -s https://raw.githubusercontent.com/lunarvim/lunarvim/master/utils/installer/install.sh)"
  echo "[05] install powerlevel10k theme"
  git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
fi

echo "[06] cp conf [.zshrc|.p10k.zsh|config.lua]"
cp -n ~/dotfiles/conf/.zshrc ~
cp -n ~/dotfiles/conf/.p10k.zsh ~
cp -n ~/dotfiles/conf/config.lua ~/.config/lvim/
echo "[07] done"
