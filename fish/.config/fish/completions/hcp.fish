
function __complete_hcp
    set -lx COMP_LINE (commandline -cp)
    test -z (commandline -ct)
    and set COMP_LINE "$COMP_LINE "
    /home/eli/.local/bin/hcp
end
complete -f -c hcp -a "(__complete_hcp)"

