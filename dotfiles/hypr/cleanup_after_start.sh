#!/bin/bash
sleep 3
hyprctl keyword windowrule "workspace 1,kitty"
hyprctl dispatch exec "kitty"
sleep 10
hyprctl keyword windowrule "workspace unset,firefox"
hyprctl keyword windowrule "workspace unset,kitty"
hyprctl keyword windowrule "workspace unset,discord"
