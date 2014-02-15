dotfiles
========

My dotfiles. see: http://dotfiles.github.io/

OS related setup scripts can be found in `setup` folder.

## Features

* Zsh
* For Mac and debian/ubuntu
* `<hr />` for your terminal.

## Setup

### Basic tools depending on platform

On depending on the platform you should install basic dependencies.

For Mac: `curl -L http://git.io/3hD1Kw | sh`

Also, checkout `setup` folder

### Installing dotfiles

Clone into `~/dotfiles` and symlink the files to `~`

```shell
cd ~ && git clone --recursive git@github.com:theskumar/dotfiles.git
# To create symbolic links in your home
cd ~/dotfiles
sh bootstrap.sh
```

## Not Exactly What You Want?

This is what I want. It might not be what you want. Don't worry, you have options:

### Fork This

If you have differences in your preferred setup, I encourage you to fork this to create your own version. Once you have your fork working, let me know and I'll add it to a 'Similar dotfiles' list here. It's up to you whether or not to rename your fork.

### Or Submit a Pull Request

I also accept pull requests on this, if they're small, atomic, and if they make my own project development experience better.
