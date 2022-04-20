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
cd ${HOMEBREW_PREFIX}/bin
ln -s gcc gcc-11
ln -s g++ g++-1
ln -s cpp cpp-11
ln -s c++ c++-11
./setup.sh
brew install R python3
