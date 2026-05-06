function vpnstatus --wraps='sudo wg show' --description 'alias vpnstatus=sudo wg show'
  sudo wg show $argv
        
end
