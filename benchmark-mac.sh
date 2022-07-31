#/usr/bin/env bash
# Bootstrap on an Mac. 

xcode-select --install

git clone https://github.com/Homebrew/brew homebrew
eval "$(homebrew/bin/brew shellenv)"
brew update --force --quiet
chmod -R go-w "$(brew --prefix)/share/zsh"

brew install python3 make cmake ninja curl git openssl pkg-config & 
git clone https://github.com/rust-lang/rust.git && git -C rust submodule update --init --recursive &
wait 

cd rust 
echo 'e' | ./x.py setup
time ./x.py build
