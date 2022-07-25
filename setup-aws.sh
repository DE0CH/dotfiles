#!/usr/bin/env bash 

# sudo /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/DE0CH/dotfiles/master/setup-aws.sh)"
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
apt-get update && apt-get install -y zsh git rsync htop
chsh -s /bin/zsh deyaochen
echo "deyaochen ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers
test -d /home/deyaochen/.ssh || su - deyaochen -c "mkdir -p /home/deyaochen/.ssh"
su - deyaochen -c "curl https://github.com/DE0CH.keys > /home/deyaochen/.ssh/authorized_keys"
su - deyaochen -c "git clone https://github.com/DE0CH/dotfiles.git /home/deyaochen/dotfiles"
usermod -aG sudo deyaochen

curl -fsSL https://test.docker.com -o test-docker.sh
sh test-docker.sh
usermod -aG docker deyaochen

curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | tee /etc/apt/sources.list.d/github-cli.list > /dev/null
apt update
apt install gh

su deyaochen -s /home/deyaochen/dotfiles/setup-zsh.sh
