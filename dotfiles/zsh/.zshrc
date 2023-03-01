# Lines configured by zsh-newuser-install
HISTFILE=~/.histfile
HISTSIZE=1000
SAVEHIST=1000
setopt extendedglob nomatch notify
unsetopt autocd beep
bindkey -v
# End of lines configured by zsh-newuser-install
# The following lines were added by compinstall
zstyle :compinstall filename '/home/nicolas/.zshrc'

autoload -Uz compinit
compinit
# End of lines added by compinstall


alias ls='ls --color=auto'
alias grep='grep --color=auto'
alias vi='nvim'
alias sudo='sudo '
alias fetch='neofetch --kitty'
alias la='ls -la'
alias ll='ls -l'
alias lls='ls | lolcat'
alias lla='la | lolcat'
alias lll='ll | lolcat'
alias lfetch='fetch | lolcat'
alias ltree='tree | lolcat'
alias latree='tree | lolcat -ad 1'
fortune | cowsay -f stegosaurus | lolcat
eval "$(starship init zsh)"
