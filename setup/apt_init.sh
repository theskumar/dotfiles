#! /bin/bash
install="apt-get install -y"
declare -a packages=(fortune cowsay git)

# http://github.com/ilikenwf/apt-fast
# sudo git clone git@github.com:ilikenwf/apt-fast.git /usr/bin/apt-fast
# chmod a+x /usr/bin/apt-fast/
# sudo apt-get install -y apt-fast


for package in ${packages[@]}
do
	 $install $package
done
