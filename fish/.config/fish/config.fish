if status is-interactive
    fzf --fish |source
    rbenv init - fish | source
    zoxide init fish | source
    # Commands to run in interactive sessions can go here
end
