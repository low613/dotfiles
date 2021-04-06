#!/bin/bash

# Install vim-plug 
sh -c 'curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs \
       https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
# Install ohmyzsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# Install nvim config
cp nvim/init.vim  ~/.config/nvim/init.vim

# Install ZSH config
cp .zshrc ~/.zshrc
