export ZSH="/home/elil/.oh-my-zsh"
ZSH_THEME="agnoster"
plugins=(
    git
    zsh-autosuggestions
    zsh-syntax-highlighting
    vagrant
    ubuntu
)

source $ZSH/oh-my-zsh.sh
DEFAULT_USER="$USER"
export PATH=$PATH:/usr/local:$HOME/scripts:/opt/puppetlabs/pdk

alias sd='ssh eli.lowinger@sitedev.alaress.com.au'

function ssha { ssh alaress@"$@";}

export PATH=$PATH:$HOME/.local/bin￼
export VAULT_ADDR='http://active.vault.service.consul:8200'
alias vpnup='wg-quick up wgnet0'
alias vpndown='wg-quick down wgnet0'
alias vpnstatus='sudo wg show'
alias vnc_pi='ssh -fL 9901:localhost:5901 pi@192.168.1.10 sleep 10; xtigervncviewer localhost:9901'
eval "$(gh completion -s zsh)"
alias vim="nvim"

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

export PATH="$HOME/.yarn/bin:$HOME/.config/yarn/global/node_modules/.bin:$HOME/.local/bin:$PATH"
export VISUAL=nvim
export EDITOR=$VISUAL

export TERM="xterm-256color"
