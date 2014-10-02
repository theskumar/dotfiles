# Load ~/.extra, ~/.exports, ~/.aliases and ~/.functions
# ~/.extra can be used for settings you don’t want to commit
for file in ~/.{exports,aliases,functions,extra}; do
	[ -r "$file" ] && source "$file"
done
unset file

# Detect and load OS specific settigs
platform='unknown'
unamestr=`uname`
if [[ "$unamestr" == 'Linux' ]]; then
   source ~/.linux
elif [[ "$unamestr" == 'FreeBSD' ]]; then
   source ~/.freebsd
elif [[ "$unamestr" == 'Darwin' ]]; then
   source ~/.osx
fi

# Check for startup SPLASH script
if hash splash 2>/dev/null; then
    splash
fi

alias starwars="telnet towel.blinkenlights.nl"
