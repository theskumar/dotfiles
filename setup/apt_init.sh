#! /bin/bash

install="apt-get install -y"
declare -a packages=(fortune cowsay git git-extras grc xclip autojump)

# http://github.com/ilikenwf/apt-fast
if hash apt-fast 2>/dev/null; then
	install="apt-fast install -y"
fi

# hub
# http://hub.github.com/
curl http://hub.github.com/standalone -sLo ~/bin/hub
chmod +x ~/bin/hub


for package in ${packages[@]}
do
	 $install $package
done

# sudo git clone git@github.com:ilikenwf/apt-fast.git /usr/bin/apt-fast
# chmod a+x /usr/bin/apt-fast/
# sudo apt-get install -y apt-fast
