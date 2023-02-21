#!/bin/bash

# Credit to John Hammond for base script and colors
# Define colors...
RED=`tput bold && tput setaf 1`
GREEN=`tput bold && tput setaf 2`
YELLOW=`tput bold && tput setaf 3`
BLUE=`tput bold && tput setaf 4`
NC=`tput sgr0`
user=$(who | awk 'NR==1{print $1}')
cd "${0%/*}"

function RED(){
	echo -e "\n${RED}${1}${NC}"
}
function GREEN(){
	echo -e "\n${GREEN}${1}${NC}"
}
function YELLOW(){
	echo -e "\n${YELLOW}${1}${NC}"
}
function BLUE(){
	echo -e "\n${BLUE}${1}${NC}"
}

# Testing if root...
if [ $EUID -ne 0 ]
then
	RED "[!] You must run this script as root!" && echo
	exit
fi

chown -R $user:$user /home/$user/arch-ignition-key

BLUE "   Would you like to install intel graphics drivers?"
read -n1 -p "   Please type Y or N : " userinput
case $userinput in
        y|Y) BLUE "[*] Installing mesa..."; pacman -S --noconfirm mesa;;
        n|N) BLUE "[*] Not installing..." ;;
        *) RED "[!] Invalid response, not installing...";;
esac

BLUE "[*] Installing yay..."
pacman -S --needed git base-devel --noconfirm
su - $user -c "git clone https://aur.archlinux.org/yay.git"
su - $user -c "cd yay; makepkg -si"

BLUE "[*] Installing kitty..."
pacman -S --noconfirm kitty

BLUE "[*] Installing Hyprland..."
su - $user -c "yay -S --answerdiff=None --noconfirm hyprland"

BLUE "[*] Installing Hyprpaper..."
su - $user -c "yay -S --answerdiff=None --noconfirm hyprpaper-git"

BLUE "[*] Installing SDDM..."
su - $user -c "yay -S --answerdiff=None --noconfirm sddm-git"

BLUE "[*] Installing Discord..."
su - $user -c "yay -S --answerdiff=None --noconfirm discord"

BLUE "[*] Installing Fish..."
su - $user -c "yay -S --answerdiff=None --noconfirm fish"

BLUE "[*] Installing Neovim..."
su - $user -c "yay -S --answerdiff=None --noconfirm neovim"

BLUE "[*] Installing Spotify..."
su - $user -c "yay -S --answerdiff=None --noconfirm spotifyd 
su - $user -c "yay -S --answerdiff=None --noconfirm spotify-tui


# Comment out any of the following dotfiles to keep current files
function dotfiles(){
        # Bash dotfiles
	su - $user -c "mkdir /home/$user/.config; mkdir /home/$user/.config/hypr"
	su - $user -c "cp -r ./arch-ignition-key/dotfiles/hypr /home/$user/.config/hypr"
	su - $user -c "cp -r ./arch-ignition-key/dotfiles/sddm/themes /usr/share/sddm"
	su - $user -c "cp ./arch-ignition-key/dotfiles/sddm/sddm.conf /etc/sddm.conf"
	su - $user -c "mkdir /home/$user/Pictures"
	su - $user -c "cp -r ./arch-ignition-key/wallpapers /home/$user/Pictures"
	su - $user -c "cp -r ./arch-ignition-key/dotfiles/kitty /home/$user/.config/kitty"
	cp -r /home/$user/arch-ignition-key/dotfiles/grub/themes/sleek /usr/share/grub/themes/sleek
	echo -e "preload = /home/$user/Pictures/nezuko.jpg\nwallpaper = eDP-1,/home/$user/Pictures/nezuko.jpg"
	git clone https://github.com/mlvzk/discocss
	cp discocss/discocss /usr/bin
	su - $user -c "mkdir /home/$user/.config/discocss"
	curl -L https://catppuccin.github.io/discord/dist/catppuccin-mocha.theme.css > ~/.config/discocss/custom.css
	discocss
}

BLUE "   Would you like to copy modified dotfiles?"
read -n1 -p "   Please type Y or N : " userinput
case $userinput in
        y|Y) BLUE "[*] Copying dotfiles..."; dotfiles;;
        n|N) BLUE "[*] Keeping defaults..." ;;
        *) RED "[!] Invalid response, keeping defaults...";;
esac

GREEN "[++] All done! Remember to reboot and login again to see the full changes!"
