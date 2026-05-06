function vpnup --wraps='wg-quick up wgnet0' --description 'alias vpnup=wg-quick up wgnet0'
  wg-quick up wgnet0 $argv
        
end
