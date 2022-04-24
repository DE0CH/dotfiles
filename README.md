# IMPORTANT
If you have stumbled across this and you are not me (the author), please DO NOT run the script. Among many other dangerous things, it will add my ssh public keys to your `authorized_keys`. 

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