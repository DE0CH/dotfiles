#!/usr/bin/env bash 

SOURCE=${BASH_SOURCE[0]}
while [ -h "$SOURCE" ]; do # resolve $SOURCE until the file is no longer a symlink
  DIR=$( cd -P "$( dirname "$SOURCE" )" >/dev/null 2>&1 && pwd )
  SOURCE=$(readlink "$SOURCE")
  [[ $SOURCE != /* ]] && SOURCE=$DIR/$SOURCE # if $SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located
done
DIR=$( cd -P "$( dirname "$SOURCE" )" >/dev/null 2>&1 && pwd )


if [ "$EUID" -ne 0 ]
  then echo "Please run this script as root"
  exit
fi

useradd -m deyaochen
apt-get update && apt-get install -y zsh
sudo chsh -s /bin/zsh deyaochen
su - deyaochen -c "curl https://github.com/DE0CH.keys > /home/deyaochen/.ssh/authorized_keys"


${DIR}/setup-zsh.sh