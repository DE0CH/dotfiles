#!/usr/bin/env bash

set -e

git clone https://github.com/ohmyzsh/ohmyzsh.git ~/.oh-my-zsh
git clone https://github.com/romkatv/powerlevel10k.git "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k"
git clone https://github.com/zsh-users/zsh-autosuggestions "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions"
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting"
git clone https://github.com/TamCore/autoupdate-oh-my-zsh-plugins.git "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/autoupdate"
${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k/gitstatus/install
curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim


cd "${HOME}"

backup () {
  FILE=$1
  if [ -e "${FILE}" ]; then
    BACKUP="${FILE}.backup"
    while [ -f "${BACKUP}" ]; do
      BACKUP="${BACKUP}.backup"
    done
    FILE_REL=$(realpath --relative-to="${HOME}" "${FILE}")
    BACKUP_REL=$(realpath --relative-to="${HOME}" "${BACKUP}")
    echo "~/${FILE_REL} exists, moving it to ~/${BACKUP_REL}"
    mv "${FILE}" "${BACKUP}"
  fi 
}

backup "${HOME}/.zshrc"
backup "${HOME}/.p10k.zsh"

curl -fsSL https://raw.githubusercontent.com/DE0CH/dotfiles/master/.zshrc -o .zshrc
curl -fsSL https://raw.githubusercontent.com/DE0CH/dotfiles/master/.p10k.zsh -o .p10k.zsh
