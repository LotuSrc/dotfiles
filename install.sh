#/bin/bash
#set -x

OS=centos
MIRROR=N
PROXY=N
PROXY_URL=https://ghproxy.com

OS=`uname -a`

COLOR_GRAY="\033[1;38;5;243m"
COLOR_BLUE="\033[1;34m"
COLOR_GREEN="\033[1;32m"
COLOR_RED="\033[1;31m"
COLOR_PURPLE="\033[1;35m"
COLOR_YELLOW="\033[1;33m"
COLOR_NONE="\033[0m"

function title() {
  echo -e "\n${COLOR_PURPLE}$1${COLOR_NONE}"
  echo -e "${COLOR_GRAY}==============================${COLOR_NONE}\n"
}

function error() {
  echo -e "${COLOR_RED}Error: ${COLOR_NONE}$1"
  exit 1
}

function warning() {
  echo -e "${COLOR_YELLOW}Warning: ${COLOR_NONE}$1"
}

function info() {
  echo -e "${COLOR_BLUE}Infor: ${COLOR_NONE}$1"
}

function success() {
  echo -e "${COLOR_GREEN}$1${COLOR_NONE}"
}

function setup_homebrew() {
  title "Setting up Homebrew"

  if test ! "$(command -v brew)"; then
    info "Homebrew not installed. Installing."
    export HOMEBREW_BREW_GIT_REMOTE="https://mirrors.tuna.tsinghua.edu.cn/git/homebrew/brew.git"
    export HOMEBREW_CORE_GIT_REMOTE="https://mirrors.tuna.tsinghua.edu.cn/git/homebrew/homebrew-core.git"
    export HOMEBREW_BOTTLE_DOMAIN="https://mirrors.tuna.tsinghua.edu.cn/homebrew-bottles"
    git clone --quiet --depth=1 https://mirrors.tuna.tsinghua.edu.cn/git/homebrew/install.git brew-install
    /bin/bash brew-install/install.sh
    rm -rf brew-install
  fi
}


if [[ $OS =~ 'Darwin' ]]
then
  echo "Installing homebrew"
  export HOMEBREW_BREW_GIT_REMOTE="https://mirrors.tuna.tsinghua.edu.cn/git/homebrew/brew.git"
  export HOMEBREW_CORE_GIT_REMOTE="https://mirrors.tuna.tsinghua.edu.cn/git/homebrew/homebrew-core.git"
  export HOMEBREW_BOTTLE_DOMAIN="https://mirrors.tuna.tsinghua.edu.cn/homebrew-bottles"
  git clone --depth=1 https://mirrors.tuna.tsinghua.edu.cn/git/homebrew/install.git brew-install
  /bin/bash brew-install/install.sh
  rm -rf brew-install
  test -r ~/.bash_profile && echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.bash_profile
  test -r ~/.zprofile && echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile

  test -r ~/.zprofile && echo 'export HOMEBREW_BOTTLE_DOMAIN="https://mirrors.tuna.tsinghua.edu.cn/homebrew-bottles"' >> ~/.zprofile

elif [[ $OS =~ 'Linux' ]]
then
  echo "Installing linuxbrew"
  export HOMEBREW_BREW_GIT_REMOTE="https://mirrors.tuna.tsinghua.edu.cn/git/homebrew/brew.git"
  export HOMEBREW_CORE_GIT_REMOTE="https://mirrors.tuna.tsinghua.edu.cn/git/homebrew/homebrew-core.git"
  export HOMEBREW_BOTTLE_DOMAIN="https://mirrors.tuna.tsinghua.edu.cn/homebrew-bottles"
  git clone --depth=1 https://mirrors.tuna.tsinghua.edu.cn/git/homebrew/install.git brew-install
  /bin/bash brew-install/install.sh
  rm -rf brew-install
  test -d ~/.linuxbrew && eval "$(~/.linuxbrew/bin/brew shellenv)"
  test -d /home/linuxbrew/.linuxbrew && eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
  test -r ~/.bash_profile && echo "eval \"\$($(brew --prefix)/bin/brew shellenv)\"" >> ~/.bash_profile
  test -r ~/.profile && echo "eval \"\$($(brew --prefix)/bin/brew shellenv)\"" >> ~/.profile
  test -r ~/.zprofile && echo "eval \"\$($(brew --prefix)/bin/brew shellenv)\"" >> ~/.zprofile

  test -r ~/.zprofile && echo 'export HOMEBREW_BOTTLE_DOMAIN="https://mirrors.tuna.tsinghua.edu.cn/homebrew-bottles"' >> ~/.zprofile

else
  echo "Unrecognized os: $OS"
  exit 1
fi


# 防止centos本身glibc版本过低
echo "Installing glibc"
brew install -q glibc
echo "Installing zsh"
brew install -q zsh
# 非root用户设置zsh为默认shell
test -r ~/.bash_profile && echo "export SHELL=\`which zsh\`\n[ -z "\$ZSH_VERSION" ] && exec "\$SHELL" -l" >> ~/.bash_profile
test -r ~/.profile && echo "export SHELL=\`which zsh\`\n[ -z "\$ZSH_VERSION" ] && exec "\$SHELL" -l" >> ~/.profile
test -r ~/.zprofile && echo "export SHELL=\`which zsh\`\n[ -z "\$ZSH_VERSION" ] && exec "\$SHELL" -l" >> ~/.zprofile


echo "Installing ohmyzsh"
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
echo "Installing plugin: zsh-autosuggestions"
git clone --quiet https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
echo "Installing plugin: zsh-syntax-highlighting"
git clone --quiet https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
echo "Installing plugin: autojump"
brew install -q autojump
echo "Installing theme: powerlevel10k"
git clone --quiet --depth=1 https://gitee.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k




echo "Installing neovim"
brew install -q neovim
echo "Installing nvm"
brew install -q nvm
mkdir $HOME/.nvm
export NVM_DIR="$HOME/.nvm"
eval "[ -s "$(brew --prefix)/opt/nvm/nvm.sh" ] && \. "$(brew --prefix)/opt/nvm/nvm.sh"" # This loads nvm
eval "[ -s "$(brew --prefix)/opt/nvm/etc/bash_completion.d/nvm" ] && \. "$(brew --prefix)/opt/nvm/etc/bash_completion.d/nvm"" # This loads nvm bash_completion
test -r ~/.bash_profile && echo 'export NVM_DIR="$HOME/.nvm"' >> ~/.bash_profile
test -r ~/.bash_profile && echo "eval \"[ -s "$(brew --prefix)/opt/nvm/nvm.sh" ] && \. "$(brew --prefix)/opt/nvm/nvm.sh"\"" >> ~/.bash_profile
test -r ~/.bash_profile && echo "eval \"[ -s "$(brew --prefix)/opt/nvm/etc/bash_completion.d/nvm" ] && \. "$(brew --prefix)/opt/nvm/etc/bash_completion.d/nvm"\"" >> ~/.bash_profile
test -r ~/.profile && echo 'export NVM_DIR="$HOME/.nvm"' >> ~/.profile
test -r ~/.profile && echo "eval \"[ -s "$(brew --prefix)/opt/nvm/nvm.sh" ] && \. "$(brew --prefix)/opt/nvm/nvm.sh"\"" >> ~/.profile
test -r ~/.profile && echo "eval \"[ -s "$(brew --prefix)/opt/nvm/etc/bash_completion.d/nvm" ] && \. "$(brew --prefix)/opt/nvm/etc/bash_completion.d/nvm"\"" >> ~/.profile
test -r ~/.zprofile && echo 'export NVM_DIR="$HOME/.nvm"' >> ~/.zprofile
test -r ~/.zprofile && echo "eval \"[ -s "$(brew --prefix)/opt/nvm/nvm.sh" ] && \. "$(brew --prefix)/opt/nvm/nvm.sh"\"" >> ~/.zprofile
test -r ~/.zprofile && echo "eval \"[ -s "$(brew --prefix)/opt/nvm/etc/bash_completion.d/nvm" ] && \. "$(brew --prefix)/opt/nvm/etc/bash_completion.d/nvm"\"" >> ~/.zprofile
echo "Installing dependencies for lunarvim: npm, node and cargo"
nvm install stable
brew install -q rust
echo "Installing lunarvim"
/bin/bash -c "$(curl -s https://raw.githubusercontent.com/lunarvim/lunarvim/master/utils/installer/install.sh)"




echo "[06] cp conf [.zshrc|.p10k.zsh|config.lua]"
cp -n ~/dotfiles/.zshrc ~
cp -n ~/dotfiles/.p10k.zsh ~
cp -n ~/dotfiles/config.lua ~/.config/lvim/
echo "[07] done"
