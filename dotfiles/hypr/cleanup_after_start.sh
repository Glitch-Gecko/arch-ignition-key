#!/bin/bash
sleep $1
hyprctl keyword windowrule "workspace unset,firefox"
sleep 1
hyprctl keyword windowrule "workspace unset,kitty"
~/.config/hypr/easyrp
