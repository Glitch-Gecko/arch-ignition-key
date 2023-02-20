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

BLUE "   Would you like to install intel graphics drivers?"
read -n1 -p "   Please type Y or N : " userinput
case $userinput in
        y|Y) BLUE "[*] Installing mesa..."; pacman -S --noconfirm mesa;;
        n|N) BLUE "[*] Not installing..." ;;
        *) RED "[!] Invalid response, not installing...";;
esac

BLUE "[*] Installing yay..."
pacman -S --needed git base-devel --noconfirm
su - nicolas -c "git clone https://aur.archlinux.org/yay.git"
su - nicolas -c "cd yay; makepkg -si"

BLUE "[*] Installing kitty..."
pacman -S --noconfirm kitty

BLUE "[*] Installing Hyprland..."
yay -S --answerdiff=None --noconfirm hyprland

BLUE "[*] Installing Hyprpaper..."
yay -S --answerdiff=None --noconfirm hyprpaper-git

BLUE "[*] Installing SDDM..."
pacman -S --noconfirm sddm

# Comment out any of the following dotfiles to keep current files
function dotfiles(){
        # Bash dotfiles
	mkdir /home/$user/.config && mkdir /home/$user/.config/hypr
	cp -r ./dotfiles/arch/hypr /home/$user/.config/hypr
	cp -r ./dotfiles/arch/sddm/themes /usr/share/sddm
	cp ./dotfiles/arch/sddm/sddm.conf /etc/sddm.conf
	mkdir /home/$user/Pictures
	cp ./wallpapers /home/$user/Pictures
	echo -e "preload = /home/$user/Pictures/wallpaperflare.com_wallpaper.jpg\nwallpaper = eDP-1,/home/$user/Pictures/wallpaperflare.com_wallpaper.jpg"
}

BLUE "   Would you like to copy modified dotfiles?"
read -n1 -p "   Please type Y or N : " userinput
case $userinput in
        y|Y) BLUE "[*] Copying dotfiles..."; dotfiles;;
        n|N) BLUE "[*] Keeping defaults..." ;;
        *) RED "[!] Invalid response, keeping defaults...";;
esac

GREEN "[++] All done! Remember to reboot and login again to see the full changes!"
