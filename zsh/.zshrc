# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi
setopt COMBINING_CHARS

export ZSH="/home/eli/.oh-my-zsh"
#ZSH_THEME="agnoster"
ZSH_THEME="powerlevel10k/powerlevel10k"
plugins=(
    git
    zsh-autosuggestions
    zsh-syntax-highlighting
    vagrant
    ubuntu
    minikube
    kubectl
    helm
    aws
    zsh-vi-mode
)

source $ZSH/oh-my-zsh.sh
DEFAULT_USER="$USER"
export PATH=$PATH:/usr/local:$HOME/scripts:/opt/puppetlabs/pdk:$HOME/.gem/ruby/3.0.0/bin

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

# export TERM="xterm-256color"
export FZF_DEFAULT_OPTS="
--layout=reverse
--info=inline
--height=80%
--multi
--preview-window=:hidden
--preview 'pygmentize -g -O style=colorful,linenos=1 {}'
--bind '?:toggle-preview'
--bind 'ctrl-a:select-all'
--bind 'ctrl-y:execute-silent(echo {+} | pbcopy)'
--bind 'ctrl-e:execute(echo {+} | xargs -o vim)'
--bind 'ctrl-v:execute(code {+})'
"

autoload -U +X bashcompinit && bashcompinit
complete -o nospace -C /usr/bin/terraform terraform

complete -o nospace -C /usr/bin/vault vault

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
# pip zsh completion start
function _pip_completion {
  local words cword
  read -Ac words
  read -cn cword
  reply=( $( COMP_WORDS="$words[*]" \
             COMP_CWORD=$(( cword-1 )) \
             PIP_AUTO_COMPLETE=1 $words[1] 2>/dev/null ))
}
compctl -K _pip_completion pip
# pip zsh completion end

export PATH="$HOME/.rbenv/bin:$PATH"
export PATH="$PATH:$HOME/.cargo/bin"
eval "$(rbenv init -)"
# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
export PATH=$PATH:$HOME/.local/scripts/
export FZF_DEFAULT_OPTS=" \
--color=bg+:#313244,bg:#1e1e2e,spinner:#f5e0dc,hl:#f38ba8 \
--color=fg:#cdd6f4,header:#f38ba8,info:#cba6f7,pointer:#f5e0dc \
--color=marker:#f5e0dc,fg+:#cdd6f4,prompt:#cba6f7,hl+:#f38ba8"
export PATH=$PATH:$HOME/go/bin

# add Pulumi to the PATH
export PATH=$PATH:/home/eli/.pulumi/bin
export PATH=$(composer global config bin-dir --absolute --quiet):$PATH
