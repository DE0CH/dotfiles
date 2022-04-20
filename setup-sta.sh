cd ${HOME}
git clone https://github.com/Homebrew/brew .linuxbrew
.linuxbrew/bin/brew update --force --quiet
echo 'eval "$(.linuxbrew/bin/brew shellenv)"' >> .profile
cat <<EOT >> .bashrc
/bin/zsh
exit
EOT
eval "$(.linuxbrew/bin/brew shellenv)"
brew install --force-bottle binutils
brew install --force-bottle gcc

git clone https://github.com/ohmyzsh/ohmyzsh.git ~/.oh-my-zsh
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

cd ${HOMEBREW_PREFIX}/bin
ln -s gcc gcc-11
ln -s g++ g++-1
ln -s cpp cpp-11
ln -s c++ c++-11



cd ${HOME}
rm -rf .ssh
ssh-keygen -t rsa -q -f "$HOME/.ssh/id_rsa" -N ""
rm -rf .gnupg
mkdir .gnupg 
chmod 700 .gnupg
mkdir -p .gnupg/private-keys-v1.d

cat <<EOT >> .gnupg/gen-key-script
Key-Type: 1
Key-Length: 2048
Subkey-Type: 1
Subkey-Length: 2048
Name-Real: Deyao Chen
Name-Email: chendeyao000@gmail.com
Expire-Date: 0
EOT
gpg --batch --gen-key .gnupg/gen-key-script


DIR=${PWD}
cd ${HOME}
REL=$(realpath --relative-to="${HOME}" "${DIR}")
ln -s ${DIR}/.zshrc .zshrc
ln -s ${DIR}/.p10k.zsh .p10k.zsh

brew install R python3
