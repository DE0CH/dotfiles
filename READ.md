## Link files
Install zsh and chsh 
```bash 
$ sudo chsh -s $(which zsh) $USER
```

After running `setup.sh`

```bash
$ ln -s dotfiles/.zshrc .zshrc 
$ ln -s dotfiles/.vimrc .vimrc
$ ln -s dotfiles/.p10k.zsh .p10k.zsh
```

Install zsh and 
```bash 
$ chsh -s $(which zsh)
```