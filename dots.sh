#!/bin/bash
# Dotfiles script to avoid rerunning the install script

# Define colors...
RED=`tput bold && tput setaf 1`
GREEN=`tput bold && tput setaf 2`
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
BLUE "[*] Installing Hypr dotfiles..."
su - $user -c "mkdir /home/$user/.config; mkdir /home/$user/.config/hypr"
cp -r $SCRIPT_DIR/dotfiles/hypr /home/$user/.config/

# Sddm dotfiles
BLUE "[*] Installing Sddm dotfiles..."
cp -r $SCRIPT_DIR/dotfiles/sddm/themes /usr/share/sddm
cp $SCRIPT_DIR/dotfiles/sddm/sddm.conf /etc/sddm.conf
su - $user -c "mkdir /home/$user/Pictures"

# Kitty dotfiles
BLUE "[*] Installing Kitty dotfiles..."
cp -r $SCRIPT_DIR/dotfiles/kitty /home/$user/.config/

# Grub dotfiles
BLUE "[*] Installing Grub dotfiles..."
cp -r $SCRIPT_DIR/dotfiles/grub/themes/sleek /usr/share/grub/themes
cp $SCRIPT_DIR/dotfiles/grub/grub /etc/default/
grub-mkconfig -o /boot/grub/grub.cfg

# Discord/discocss dotfiles
BLUE "[*] Installing Discord dotfiles..."
git clone https://github.com/mlvzk/discocss
cp discocss/discocss /usr/bin
rm -rf discocss
su - $user -c "mkdir /home/$user/.config/discocss"
curl -L https://catppuccin.github.io/discord/dist/catppuccin-mocha.theme.css > /home/$user/.config/discocss/custom.css

# Firefox dotfiles
BLUE "[*] Installing Firefox dotfiles..."
git clone https://github.com/PROxZIMA/prism
chown -R $user prism
cp -r prism /home/$user/.mozilla/firefox/
rm -rf prism
cp $SCRIPT_DIR/dotfiles/firefox/mozilla.cfg /usr/lib/firefox/
cp $SCRIPT_DIR/dotfiles/firefox/local-settings.js /usr/lib/firefox/defaults/pref/
#echo -e 'user_pref("browser.startup.homepage", "file:///home/$user/.mozilla/firefox/prism/index.html");' >> /home/$user/.mozilla/firefox/*.default*/prefs.js

# Alacritty dotfiles
BLUE "[*] Installing Alacritty dotfiles..."
mkdir /home/$user/.config/alacritty
cp $SCRIPT_DIR/dotfiles/alacritty/alacritty.yml /home/$user/.config/alacritty
su - $user -c "git clone https://github.com/catppuccin/alacrity.git ~/.config/alacritty/catppuccin"

# Nvim dotfiles
BLUE "[*] Installing Nvim dotfiles..."
cp -r $SCRIPT_DIR/dotfiles/nvim/ /home/$user/.config/

# Zsh dotfiles
BLUE "[*] Installing Zsh dotfiles..."
cp $SCRIPT_DIR/dotfiles/zsh/.zshrc /home/$user/

# Neofetch dotfiles
BLUE "[*] Installing Neofetch dotfiles..."
cp -r $SCRIPT_DIR/dotfiles/neofetch /home/$user/.config/

# Starship dotfiles
BLUE "[*] Installing Starship dotfiles..."
cp $SCRIPT_DIR/dotfiles/starship.toml /home/$user/.config/starship.toml

# Spotifyd dotfiles
BLUE "[*] Installing Spotifyd dotfiles..."
cp -r $SCRIPT_DIR/dotfiles/systemd /home/$user/.config/

# Waybar dotfiles
BLUE "[*] Installing Waybar dotfiles..."
cp -r $SCRIPT_DIR/dotfiles/waybar /home/$user/.config

# Btop dotfiles
BLUE "[*] Installing Btop dotfiles..."
cp -r $SCRIPT_DIR/dotfiles/btop /home/$user/.config

# Ownership
BLUE "[*] Granting ownership..."
chown -R $user /home/$user/.config /usr/share/sddm/themes /etc/sddm.conf /home/$user/Pictures /usr/share/grub/themes/sleek /home/$user/.zshrc

GREEN "[++] All done! Remember to reboot and login again to see the full changes!"
