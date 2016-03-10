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
  ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)" > /tmp/homebrew-install.log
fi

# Make sure we’re using the latest Homebrew
brew update

# Upgrade any already-installed formulae
brew upgrade

# Install GNU core utilities (those that come with OS X are outdated)
brew install grc coreutils
echo "Don’t forget to add $(brew --prefix coreutils)/libexec/gnubin to \$PATH."
# Install GNU `find`, `locate`, `updatedb`, and `xargs`, g-prefixed
brew install findutils

# Install Bash 4
brew install bash
brew install zsh

# Install wget with IRI support
brew install wget --with-iri
brew install curl --with-ssl --with-ssh
# Install GNU `sed`, overwriting the built-in `sed`.
brew install gnu-sed --with-default-names

# Install more recent versions of some OS X tools
brew tap homebrew/dupes
brew install homebrew/dupes/grep
brew tap josegonzalez/homebrew-php

# Install everything else
brew install ack
brew install git git-extras hub git-ftp git-crypt
brew install rename htop-osx tree ngrep mtr nmap
brew install autojump
brew install legit # http://www.git-legit.org/
brew install Zopfli # https://code.google.com/p/zopfli/
brew install fortune cowsay
brew install heroku-toolbelt
brew install node
brew install ngrok # https://ngrok.com/
brew install sshrc # https://github.com/Russell91/sshrc
brew install pup  # https://github.com/EricChiang/pup
brew install httpie  # https://github.com/jakubroztocil/httpie
brew install jq  # https://stedolan.github.io/jq/
brew install python3
brew install editorconfig
brew install ssh-copy-id  # http://linux.die.net/man/1/ssh-copy-id

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

installcask android-file-transfer
installcask google-chrome
installcask utorrent
installcask limechat
installcask tunnelbear
installcask dropbox
installcask iterm2
installcask skitch  # https://evernote.com/skitch/
installcask vlc
installcask nvalt  # for notes
installcask qlcolorcode qlstephen qlmarkdown quicklook-json qlprettypatch quicklook-csv betterzipql webp-quicklook suspicious-package && qlmanage -r

# Postgres 9 Database
brew install postgres
installcask pgadmin3
ln -sfv /usr/local/opt/postgresql/*.plist ~/Library/LaunchAgents
launchctl load ~/Library/LaunchAgents/homebrew.mxcl.postgresql.plist
psql postgres -c 'CREATE EXTENSION "adminpack";'
sudo gem install pg

# memcache dev
brew install libmemcached

# Fonts
brew tap caskroom/fonts

brew cask install font-source-code-pro

# SpotifyControl
# git clone git://github.com/dronir/SpotifyControl.git ~/bin/SpotifyControl

sudo easy_install pip

# Remove outdated versions from the cellar
brew cleanup && brew cask cleanup

exit 0
