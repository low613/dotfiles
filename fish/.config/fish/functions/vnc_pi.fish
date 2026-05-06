function vnc_pi --wraps='ssh -fL 9901:localhost:5901 pi@192.168.1.10 sleep 10; xtigervncviewer localhost:9901' --description 'alias vnc_pi=ssh -fL 9901:localhost:5901 pi@192.168.1.10 sleep 10; xtigervncviewer localhost:9901'
  ssh -fL 9901:localhost:5901 pi@192.168.1.10 sleep 10; xtigervncviewer localhost:9901 $argv
        
end
