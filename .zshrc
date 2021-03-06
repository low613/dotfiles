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

complete -o nospace -C /usr/local/bin/vault vault

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

