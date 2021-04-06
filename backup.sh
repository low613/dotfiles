#!/bin/bash

cd "$(dirname "$0")"
cp ~/.config/nvim . -r

cp ~/.zshrc .

git commit -am "backup $(date)"
git push
