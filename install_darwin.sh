#/bin/bash

COLOR_GRAY="\033[1;38;5;243m"
COLOR_BLUE="\033[0;34m"
COLOR_GREEN="\033[0;32m"
COLOR_RED="\033[0;31m"
COLOR_PURPLE="\033[1;35m"
COLOR_YELLOW="\033[0;33m"
COLOR_NONE="\033[0m"

function title() {
  echo "\n${COLOR_PURPLE}$1${COLOR_NONE}"
  echo "${COLOR_GRAY}==============================${COLOR_NONE}\n"
}

function error() {
  echo "${COLOR_RED}Error: ${COLOR_NONE}$1"
  exit 1
}

function warning() {
  echo "${COLOR_YELLOW}Warning: ${COLOR_NONE}$1"
}

function info() {
  echo "${COLOR_BLUE}Info: ${COLOR_NONE}$1"
}

function success() {
  echo "${COLOR_GREEN}$1${COLOR_NONE}"
}

function version_gt() { 
  test "$(printf '%s\n' "$@" | sort -V | head -n 1)" != "$1"
}

function setup_homebrew() {
  title "Setting up Homebrew"

  if test ! "$(command -v brew)"; then
    info "Homebrew not installed. Installing."
    xcode-select --install
    export HOMEBREW_BREW_GIT_REMOTE="https://mirrors.tuna.tsinghua.edu.cn/git/homebrew/brew.git"
    export HOMEBREW_CORE_GIT_REMOTE="https://mirrors.tuna.tsinghua.edu.cn/git/homebrew/homebrew-core.git"
    export HOMEBREW_BOTTLE_DOMAIN="https://mirrors.tuna.tsinghua.edu.cn/homebrew-bottles"
    git clone --quiet --depth=1 https://mirrors.tuna.tsinghua.edu.cn/git/homebrew/install.git brew-install
    /bin/bash brew-install/install.sh
    rm -rf brew-install

    # m1需要这一步
    if [[ `uname -a` =~ "arm64" ]]; then
      test -r ~/.bash_profile && echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.bash_profile
      test -r ~/.zprofile && echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
    fi
  fi

  brew install -q autojump
  brew install -q miniconda

  success "Done."
}

function setup_zsh() {
  title "Setting up Zsh"

  if test ! "$(command -v zsh)"; then
    info "Zsh not installed. Installing."
    brew install -q zsh
  fi
  
  # mac下是-E
  if version_gt "5.0.8" `zsh --version | grep -E '\d+.\d+.\d+' -o`; then
    # 低于5.0.8则更新zsh
    info "Zsh version is older than 5.0.8. Installing latest version."
    brew install -q zsh
    # 需要用户sudo权限
    chsh -s /usr/local/bin/zsh
  fi

  success "Done."
}

setup_homebrew
setup_zsh
