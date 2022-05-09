#!/usr/bin/env bash

SOURCE=${BASH_SOURCE[0]}
while [ -h "$SOURCE" ]; do # resolve $SOURCE until the file is no longer a symlink
  DIR=$( cd -P "$( dirname "$SOURCE" )" >/dev/null 2>&1 && pwd )
  SOURCE=$(readlink "$SOURCE")
  [[ $SOURCE != /* ]] && SOURCE=$DIR/$SOURCE # if $SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located
done
DIR=$( cd -P "$( dirname "$SOURCE" )" >/dev/null 2>&1 && pwd )


git clone https://github.com/ohmyzsh/ohmyzsh.git ~/.oh-my-zsh
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim


cd ${HOME}

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
    mv ${FILE} ${BACKUP}
  fi 
}

backup ${HOME}/.zshrc
backup ${HOME}/.p10k.zsh
backup ${HOME}/.ssh/config
backup ${HOME}/.gitconfig


ln -s ${DIR}/.zshrc .zshrc
ln -s ${DIR}/.p10k.zsh .p10k.zsh
ln -s ${DIR}/.gitconfig .gitconfig

cd ${HOME}/.ssh
REL=$(realpath --relative-to="${HOME}/.ssh" "${DIR}/.ssh")
ln -s ${REL}/config config 
