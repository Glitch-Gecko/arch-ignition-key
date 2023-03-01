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

# Allow nopassword sudo usage for this script
echo "$user ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

chown -R $user:$user /home/$user/arch-ignition-key

BLUE "   Would you like to install intel graphics drivers?"
read -n1 -p "   Please type Y or N : " userinput
case $userinput in
        y|Y) BLUE "[*] Installing mesa..."; pacman -S --noconfirm mesa;;
        n|N) BLUE "[*] Not installing..." ;;
        *) RED "[!] Invalid response, not installing...";;
esac

BLUE "[*] Installing yay..."
pacman -S --needed git base-devel --noconfirm --needed
su - $user -c "git clone https://aur.archlinux.org/yay.git"
su - $user -c "cd yay; makepkg -si"

BLUE "[*] Installing kitty..."
pacman -S --noconfirm --needed kitty

BLUE "[*] Installing Hyprland..."
su - $user -c "yay -S --answerdiff=None --noconfirm --needed hyprland"

BLUE "[*] Installing Hyprpaper..."
su - $user -c "yay -S --answerdiff=None --noconfirm --needed hyprpaper-git"

BLUE "[*] Installing SDDM..."
su - $user -c "yay -S --answerdiff=None --noconfirm --needed sddm-git"
pacman -Syu --noconfirm --needed qt5-graphicaleffects qt5-svg qt5-quickcontrols2

BLUE "[*] Installing Discord..."
su - $user -c "yay -S --answerdiff=None --noconfirm --needed discord"

BLUE "[*] Installing Zsh..."
su - $user -c "yay -S --answerdiff=None --noconfirm --needed zsh"
sudo sed -i "s/\/home\/$user:\/usr\/bin\/bash/\/home\/$user:\/usr\/bin\/zsh/" /etc/passwd

BLUE "[*] Installing Neovim..."
su - $user -c "yay -S --answerdiff=None --noconfirm --needed neovim"

BLUE "[*] Installing Neofetch..."
su - $user -c "yay -S --answerdiff=None --noconfirm --needed neofetch"
su - $user -c "yay -S --answerdiff=None --noconfirm --needed imagemagick"

BLUE "[*] Installing Cowsay..."
su - $user -c "yay -S --answerdiff=None --noconfirm --needed cowsay"

BLUE "[*] Installing Lolcat..."
su - $user -c "yay -S --answerdiff=None --noconfirm --needed lolcat"

BLUE "[*] Installing Spotify..."
su - $user -c "yay -S --answerdiff=None --noconfirm --needed spotifyd" 
su - $user -c "yay -S --answerdiff=None --noconfirm --needed spotify-tui"

BLUE "[*] Installing Alacritty..."
su - $user -c "yay -S --answerdiff=None --noconfirm --needed alacritty"

BLUE "[*] Installing Waybar..."
su - $user -c "yay -S --answerdiff=None --noconfirm --needed waybar-hyprland"

BLUE "[*] Installing Starship..."
su - $user -c "yay -S --answerdiff=None --noconfirm --needed starship"

BLUE "[*] Installing Light..."
su - $user -c "yay -S --answerdiff=None --noconfirm --needed light"
echo 'ACTION=="add", SUBSYSTEM=="backlight", RUN+="/bin/chgrp video $sys$devpath/brightness", RUN+="/bin/chmod g+w $sys$devpath/brightness"' > /etc/udev/rules.d/backlight.rules

BLUE "[*] Installing Alacritty..."
su - $user -c "yay -S --answerdiff=None --noconfirm --needed alacritty"

BLUE "[*] Installing Plymouth..."
su - $user -c "yay -S --answerdiff=None --noconfirm --needed plymouth-git"
plymouth_search="HOOKS=(base udev"
line_num=$(grep -n "HOOKS=(base udev" /etc/mkinitcpio.conf | awk 'END {print $1}' | cut -d: -f1)
sed -i "$line_num"'s/$plymouth_search/$plymouth_search plymouth/' /etc/mkinitcpio.conf
sed -i 's/GRUB_CMDLINE_LINUX_DEFAULT=\(.*\)/GRUB_CMDLINE_LINUX_DEFAULT="loglevel=3 quiet splash"/'
su - $user -c "yay -S --answerdiff=None --noconfirm --needed plymouth-theme-flame-git"
plymouth-set-default-theme -R flame

sed -i "s/\/home\/$user/"

BLUE "[*] Installing Nerd Hack Font..."
su - $user -c "yay -S --answerdiff=None --noconfirm --needed ttf-hack-nerd"

BLUE "[*] Installing clipboard..."
su - $user -c "yay -S --answerdiff=None --noconfirm --needed wl-clipboard"

# Comment out any of the following dotfiles to keep current files
function dotfiles(){
        # Hypr dotfiles
	su - $user -c "mkdir /home/$user/.config; mkdir /home/$user/.config/hypr"
	cp -r ./arch-ignition-key/dotfiles/hypr /home/$user/.config/
	echo -e "preload = /home/$user/Pictures/wallpapers/nezuko.jpg\nwallpaper = eDP-1,/home/$user/Pictures/wallpapers/nezuko.jpg"

	# Sddm dotfiles
	cp -r ./arch-ignition-key/dotfiles/sddm/themes /usr/share/sddm
	cp ./arch-ignition-key/dotfiles/sddm/sddm.conf /etc/sddm.conf
	su - $user -c "mkdir /home/$user/Pictures"
	cp -r ./arch-ignition-key/wallpapers /home/$user/Pictures

	# Kitty dotfiles
	cp -r ./arch-ignition-key/dotfiles/kitty /home/$user/.config/
	
	# Grub dotfiles
	cp -r /home/$user/arch-ignition-key/dotfiles/grub/themes/sleek /usr/share/grub/themes
	cp /home/$user/arch-ignition-key/dotfiles/grub/grub /etc/default/

	# Discord/discocss dotfiles
	git clone https://github.com/mlvzk/discocss
	cp discocss/discocss /usr/bin
	rm -rf discocss
	su - $user -c "mkdir /home/$user/.config/discocss"
	curl -L https://catppuccin.github.io/discord/dist/catppuccin-mocha.theme.css > /home/$user/.config/discocss/custom.css

	# Firefox dotfiles
	git clone https://github.com/PROxZIMA/prism
	chown -R $user:$user prism
	cp -r prism /home/$user/.mozilla/firefox/
	rm -rf prism
	cp /home/$user/arch-ignition-key/dotfiles/firefox/mozilla.cfg /usr/lib/firefox/
	cp /home/$user/arch-ignition-key/dotfiles/firefox/local-settings.js /usr/lib/firefox/defaults/pref/

	# Alacritty dotfiles
	mkdir /home/$user/.config/alacritty
	cp /home/$user/arch-ignition-key/dotfiles/alacritty/alacritty.yml /home/$user/.config/alacritty
	git clone https://github.com/catppuccin/alacrity.git /home/$user/.config/alacritty/catppuccin

	# Nvim dotfiles
	cp -r /home/$user/arch-ignition-key/dotfiles/nvim/ /home/$user/.config/

	# Tmux dotfiles
	cp -r /home/$user/arch-ignition-key/dotfiles/tmux/ /home/$user/.config/

	# Zsh dotfiles
	cp /home/$user/arch-ignition-key/dotfiles/zsh/.zshrc /home/$user/

    # Neofetch dotfiles
    cp -r /home/$user/arch-ignition-key/dotfiles/neofetch /home/$user/.config/

    # Starship dotfiles
    cp /home/$user/arch-ignition-key/dotfiles/starship.toml /home/$user/.config/starship.toml

	# Ownership
	chown -R $user:$user /home/$user/.config /usr/share/sddm/themes /etc/sddm.conf /home/$user/Pictures /usr/share/grub/themes/sleek /home/$user/.zshrc
}

BLUE "   Would you like to copy modified dotfiles?"
read -n1 -p "   Please type Y or N : " userinput
case $userinput in
        y|Y) BLUE "[*] Copying dotfiles..."; dotfiles;;
        n|N) BLUE "[*] Keeping defaults..." ;;
        *) RED "[!] Invalid response, keeping defaults...";;
esac

# Remove changes to /etc/sudoers
sed -i '$ d' /etc/sudoers

GREEN "[++] All done! Remember to reboot and login again to see the full changes!"
