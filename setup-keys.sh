#!/usr/bin/env bash

SOURCE=${BASH_SOURCE[0]}
while [ -h "$SOURCE" ]; do # resolve $SOURCE until the file is no longer a symlink
  DIR=$( cd -P "$( dirname "$SOURCE" )" >/dev/null 2>&1 && pwd )
  SOURCE=$(readlink "$SOURCE")
  [[ $SOURCE != /* ]] && SOURCE=$DIR/$SOURCE # if $SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located
done
DIR=$( cd -P "$( dirname "$SOURCE" )" >/dev/null 2>&1 && pwd )

backup () {
  FILE=$1
  if [ -f "${FILE}" ]; then
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

backup ${HOME}/.ssh/authorized_keys
backup ${HOME}/.ssh/id_rsa

curl https://github.com/DE0CH.keys > ${HOME}/.ssh/authorized_keys
chmod 700 ${HOME}/.ssh/authorized_keys

gpg --batch --gen-key ${DIR}/gen-key-script
ssh-keygen -b 2048 -t rsa -f ${HOME}/.ssh/id_rsa -q -N ""
gpg --armor --export "Deyao Chen"
cat ${HOME}/.ssh/id_ras.pub