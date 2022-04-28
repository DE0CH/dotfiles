#!/usr/bin/env bash

SOURCE=${BASH_SOURCE[0]}
while [ -h "$SOURCE" ]; do # resolve $SOURCE until the file is no longer a symlink
  DIR=$( cd -P "$( dirname "$SOURCE" )" >/dev/null 2>&1 && pwd )
  SOURCE=$(readlink "$SOURCE")
  [[ $SOURCE != /* ]] && SOURCE=$DIR/$SOURCE # if $SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located
done
DIR=$( cd -P "$( dirname "$SOURCE" )" >/dev/null 2>&1 && pwd )

/usr/bin/env bash -c "$(curl -fsSL https://raw.githubusercontent.com/STAOJ/sta-setup/master/setup.sh)"

cd ${HOME}
rm -f ${HOME}/.zshrc
rm -f ${HOME}/.p10k.zsh
ln -s ${DIR}/.zshrc ${HOME}/.zshrc
ln -s ${DIR}/.p10k.zsh ${HOME}/.p10k.zsh

brew install R python3
