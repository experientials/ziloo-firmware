#!/bin/sh
# dockerfile-install-dotfiles.sh
# PURPOSE : Use when starting a Docker container for the first time
#           Installs my dotfiles and configures git
#           Run this script from within a running Docker container with the command:
# curl https://gitlab.com/fweller/flint-configuration/-/raw/master/tools/dockerfiles/dotfiles/install | bash && source .bashrc

echo "Starting to install files to Docker container"

# Make sure we are running in the proper location
cd ${HOME}

# Configure git
git config --global user.name "Henrik Vendelbo"
git config --global user.email "henrik@thepia.net"
git config --global color.ui true
git config --list

# Display my gitconfig
cat ${HOME}/.gitconfig


# Download the dotfiles
wget https://gitlab.com/fweller/flint-configuration/-/raw/master/tools/dockerfiles/dotfiles/aliases
wget https://gitlab.com/fweller/flint-configuration/-/raw/master/tools/dockerfiles/dotfiles/bashrc
wget https://gitlab.com/fweller/flint-configuration/-/raw/master/tools/dockerfiles/dotfiles/bash_profile
wget https://gitlab.com/fweller/flint-configuration/-/raw/master/tools/dockerfiles/dotfiles/inputrc
wget https://gitlab.com/fweller/flint-configuration/-/raw/master/tools/dockerfiles/dotfiles/profile
wget https://gitlab.com/fweller/flint-configuration/-/raw/master/tools/dockerfiles/dotfiles/vimrc

# Rename the dotfiles
mv aliases .aliases
mv bashrc .bashrc
mv bash_profile .bash_profile
mv inputrc .inputrc
mv profile .profile
mv vimrc .vimrc

echo "Done with installation"
# END
