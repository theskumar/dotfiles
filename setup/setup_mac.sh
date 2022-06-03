#!/bin/bash

#
# Homebrew
#
# This installs some of the common dependencies needed (or at least desired)
# using Homebrew.

# Check for Homebrew
if test ! $(which brew)
then
  echo "  Installing Homebrew for you."
  bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

# Make sure we’re using the latest Homebrew
brew update

# Upgrade any already-installed formulae
brew upgrade

# Install GNU core utilities (those that come with OS X are outdated)
brew install coreutils
# Install GNU `find`, `locate`, `updatedb`, and `xargs`, g-prefixed
brew install findutils

# Install Bash 4
brew install bash
brew install zsh

# Install wget with IRI support
brew install wget
brew install curl
# Install GNU `sed`, overwriting the built-in `sed`.
brew install gnu-sed
brew install grep
# Install more recent versions of some OS X tools


# Install everything else
# brew install openssl
# brew install ack
# brew install git git-extras hub git-ftp git-crypt
# brew install rename htop-osx tree ngrep mtr nmap
brew install autojump
# brew install legit      # http://www.git-legit.org/
# brew install Zopfli     # https://code.google.com/p/zopfli/
brew install fortune cowsay
# brew tap heroku/brew && brew install heroku
# brew install node
# brew install ngrok      # https://ngrok.com/
brew install sshrc      # https://github.com/Russell91/sshrc
brew install storm      # https://github.com/emre/storm
brew install pup        # https://github.com/EricChiang/pup
brew install httpie     # https://github.com/jakubroztocil/httpie
brew install jq         # https://stedolan.github.io/jq/
# brew install python3
brew install editorconfig
# brew install ssh-copy-id  # http://linux.die.net/man/1/ssh-copy-id

# Native apps
brew tap phinze/homebrew-cask
brew install brew-cask
function installcask() {
    if brew cask info "${@}" | grep "Not installed" > /dev/null; then
        brew cask install "${@}"
    else
        echo "${@} is already installed."
    fi
}

installcask utorrent
installcask iterm2
installcask qlcolorcode qlstephen qlmarkdown quicklook-json qlprettypatch quicklook-csv betterzipql webp-quicklook suspicious-package && qlmanage -r

# Postgres Database
brew install postgres postgis

# Fonts
brew tap caskroom/fonts

brew cask install font-source-code-pro

sudo easy_install pip
sudo pip install -r requirements.pip

# Remove outdated versions from the cellar
brew cleanup && brew cask cleanup

exit 0
