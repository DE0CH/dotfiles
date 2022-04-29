#!/usr/bin/env bash

SOURCE=${BASH_SOURCE[0]}
while [ -h "$SOURCE" ]; do # resolve $SOURCE until the file is no longer a symlink
  DIR=$( cd -P "$( dirname "$SOURCE" )" >/dev/null 2>&1 && pwd )
  SOURCE=$(readlink "$SOURCE")
  [[ $SOURCE != /* ]] && SOURCE=$DIR/$SOURCE # if $SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located
done
DIR=$( cd -P "$( dirname "$SOURCE" )" >/dev/null 2>&1 && pwd )


curl https://github.com/DE0CH.keys > ${HOME}/.ssh/authorized_keys

gpg --batch --gen-key ${DIR}/gen-key-script
ssh-keygen -b 2048 -t rsa -f ${HOME}/.ssh/id_ras -q -N ""
gpg --armor --export "Deyao Chen"
cat ${HOME}/.ssh/id_ras.pub