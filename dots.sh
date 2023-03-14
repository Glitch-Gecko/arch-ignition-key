#!/bin/bash
# Arch install script by Ainchentmew2
# Credit to John Hammond for base script and colors

# Define colors...
RED=`tput bold && tput setaf 1`
GREEN=`tput bold && tput setaf 2`
YELLOW=`tput bold && tput setaf 3`
BLUE=`tput bold && tput setaf 4`
NC=`tput sgr0`
user=$(who | awk 'NR==1{print $1}')
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
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

# Comment out any of the following dotfiles to keep current files
# Hypr dotfiles
su - $user -c "mkdir /home/$user/.config; mkdir /home/$user/.config/hypr"
cp -r $SCRIPT_DIR/dotfiles/hypr /home/$user/.config/
echo -e "preload = /home/$user/Pictures/wallpapers/nezuko.jpg\nwallpaper = eDP-1,/home/$user/Pictures/wallpapers/nezuko.jpg"

# Sddm dotfiles
cp -r $SCRIPT_DIR/dotfiles/sddm/themes /usr/share/sddm
cp $SCRIPT_DIR/dotfiles/sddm/sddm.conf /etc/sddm.conf
su - $user -c "mkdir /home/$user/Pictures"
cp -r $SCRIPT_DIR/wallpapers /home/$user/Pictures

# Kitty dotfiles
cp -r $SCRIPT_DIR/dotfiles/kitty /home/$user/.config/

# Grub dotfiles
cp -r $SCRIPT_DIR/dotfiles/grub/themes/sleek /usr/share/grub/themes
cp $SCRIPT_DIR/dotfiles/grub/grub /etc/default/

# Discord/discocss dotfiles
git clone https://github.com/mlvzk/discocss
cp discocss/discocss /usr/bin
rm -rf discocss
su - $user -c "mkdir /home/$user/.config/discocss"
curl -L https://catppuccin.github.io/discord/dist/catppuccin-mocha.theme.css > /home/$user/.config/discocss/custom.css

# Firefox dotfiles
git clone https://github.com/PROxZIMA/prism
chown -R $user prism
cp -r prism /home/$user/.mozilla/firefox/
rm -rf prism
cp $SCRIPT_DIR/dotfiles/firefox/mozilla.cfg /usr/lib/firefox/
cp $SCRIPT_DIR/dotfiles/firefox/local-settings.js /usr/lib/firefox/defaults/pref/

# Alacritty dotfiles
mkdir /home/$user/.config/alacritty
cp $SCRIPT_DIR/dotfiles/alacritty/alacritty.yml /home/$user/.config/alacritty
git clone https://github.com/catppuccin/alacrity.git /home/$user/.config/alacritty/catppuccin

# Nvim dotfiles
cp -r $SCRIPT_DIR/dotfiles/nvim/ /home/$user/.config/

# Zsh dotfiles
cp $SCRIPT_DIR/dotfiles/zsh/.zshrc /home/$user/

# Neofetch dotfiles
cp -r $SCRIPT_DIR/dotfiles/neofetch /home/$user/.config/

# Starship dotfiles
cp $SCRIPT_DIR/dotfiles/starship.toml /home/$user/.config/starship.toml

# Spotifyd dotfiles
cp -r $SCRIPT_DIR/dotfiles/systemd /home/$user/.config/

# Ownership
chown -R $user /home/$user/.config /usr/share/sddm/themes /etc/sddm.conf /home/$user/Pictures /usr/share/grub/themes/sleek /home/$user/.zshrc

GREEN "[++] All done! Remember to reboot and login again to see the full changes!"
