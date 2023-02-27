#!/bin/zsh

session="base_session"
tmux has-session -t $session &> /dev/null

if [ $? != 0 ] 
 then
    window=1
    tmux new-session -s $session -d -c ~/Documents/
    tmux rename-window -t $session:$window 'base_window'
    tmux split-window -h -t $session:$window -c ~/Documents/
    tmux split-window -v -t $session:$window -c ~/Documents/
    tmux new-window -t $session -n window2 -c ~/Documents/
fi

tmux attach -t $session:$window.0
