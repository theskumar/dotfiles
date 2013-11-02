# Load ~/.extra, ~/.exports, ~/.aliases and ~/.functions
# ~/.extra can be used for settings you don’t want to commit
for file in ~/.{extra,exports,aliases,functions}; do
	[ -r "$file" ] && source "$file"
done
unset file

# Check for startup SPLASH script
if test $(which SPLASH)
then
    SPLASH
fi

