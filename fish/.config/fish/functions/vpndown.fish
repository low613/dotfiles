function vpndown --wraps='wg-quick down wgnet0' --description 'alias vpndown=wg-quick down wgnet0'
  wg-quick down wgnet0 $argv
        
end
