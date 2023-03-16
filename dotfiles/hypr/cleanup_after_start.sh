#!/bin/bash
sleep $1
swww img $(find ~/.config/hypr/wallpapers/ -type f | shuf -n 1) &
hyprctl keyword windowrule "workspace unset,firefox"
sleep 1
hyprctl keyword windowrule "workspace unset,kitty"
