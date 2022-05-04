#!/usr/bin/env bash

cd ${HOME}
git clone https://github.com/Homebrew/brew ${HOME}/.linuxbrew
.linuxbrew/bin/brew update --force --quiet
eval "$(${HOME}/.linuxbrew/bin/brew shellenv)"
brew install --force-bottle binutils
brew install --force-bottle gcc
brew install zsh

cd ${HOMEBREW_PREFIX}/bin
ln -s gcc-11 gcc 
ln -s g++-11 g++ 
ln -s cpp-11 cpp 
ln -s c++-11 c++
