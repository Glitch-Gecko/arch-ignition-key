#!/bin/bash
# Arch install script by Ainchentmew2
# Credit to John Hammond for colors
# Credit to An00bRektn for script idea

# Define colors...
RED=`tput bold && tput setaf 1`
GREEN=`tput bold && tput setaf 2`
YELLOW=`tput bold && tput setaf 3`
BLUE=`tput bold && tput setaf 4`
NC=`tput sgr0`

usage() {
  echo "Usage: $0 [-A] [-d] [--no-dots] [-y] [-Y] [--no-packages]" 1>&2;
  exit 1;
}

# Get options from command line
while getopts ":AdyY-:" opt; do
  case $opt in
    A )
      APPLY_ALL="yes"
      ;;
    d )
      APPLY_DOTFILES_PROMPT="yes"
      ;;
    y )
      APPLY_PACKAGES="yes"
      APPLY_DRIVER_PACKAGES="no"
      ;;
    Y )
      APPLY_PACKAGES="yes"
      APPLY_DRIVER_PACKAGES="yes"
      ;;
    - )
      case "${OPTARG}" in
        no-dots )
          APPLY_DOTFILES_PROMPT="no"
          ;;
        no-packages )
          APPLY_PACKAGES="no"
          ;;
        *)
          usage
          ;;
      esac
      ;;
    \? )
      usage
      ;;
    : )
      usage
      ;;
  esac
done

# Determining user who ran script`
user=$(who | awk 'NR==1{print $1}')

# Checking and changing script directory
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
cd "${0%/*}"

# Function for colors
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

# Grant ownership to user
chown -R $user /home/$user/arch-ignition-key

# Check if yay installed, install yay
if ! type "yay" > /dev/null; then
    BLUE "[*] Installing yay..."
    pacman -S --needed git base-devel --noconfirm
    su - $user -c "git clone https://aur.archlinux.org/yay.git"
    su - $user -c "cd yay; makepkg -si"
    rm -rf yay
fi

# Function to handle package installation
function install_packages() {
    for package in "${@}"; do
        if ! pacman -Qq "$package" &> /dev/null; then
            BLUE "[*] Installing $package..."
            su - $user -c "yay -S --answerdiff=None --noconfirm --needed $package"
        else
            GREEN "[*] ${package} is already installed."
        fi
    done
}

# Function to handle user prompts
function ask_for_packages() {
    local package_group_name=$1
    local package_group=("${!2}")
    local dependencies=("${!3}")
    
    if [[ $APPLY_ALL == "yes" ]]; then
        packages+=("${package_group[@]}")
        packages+=("${dependencies[@]}")
    elif [[ $APPLY_PACKAGES == "yes" ]]; then
        if [[ $package_group_name == "drivers" && $APPLY_DRIVER_PACKAGES == "no" ]]; then
            user_choice="n"
        else
            user_choice="y"
        fi
    elif [[ $APPLY_PACKAGES == "no" ]]; then
            user_choice="n"
    else
        YELLOW "[*] Would you like to install ${package_group_name} packages?"
        echo "${package_group[*]}"
        read -n1 -p "Please type Y or N: " user_choice
    fi
    case $user_choice in
        y|Y)
            packages+=("${package_group[@]}")
            packages+=("${dependencies[@]}")
            ;;
        n|N)
            BLUE "[*] Not installing ${package_group_name} packages."
            ;;
        *)
            RED "[!] Invalid response, not installing...";;
    esac
}

# Package groups
drivers=("mesa")

display_packages=("hyprland" "swww" "sddm-git" "kitty" "alacritty" "waybar-hyprland" "plymouth-git" "light")
display_dependencies=("qt5-graphicaleffects" "qt5-svg" "qt5-quickcontrols2" "plymouth-theme-flame-git")

shell_packages=("zsh" "neovim" "starship" "tree" "ttf-hack-nerd" "noto-fonts" "noto-fonts-emoji" "man-db")
shell_dependencies=("nvim-packer-git" "man-pages")

misc_packages=("neofetch" "fortune-mod" "cowsay" "lolcat" "tty-clock-git" "thefuck" "btop")
misc_dependencies=("imagemagick")

application_packages=("firefox" "discord" "spotify-tui" "obsidian-appimage" "p7zip")
application_dependencies=("spotify-tui")

firmware_packages=("bluez" "pulseaudio-alsa" "wl-clipboard" "network-manager-applet" "grim" "pavucontrol" "slurp" "xbindkeys" "blueman")
firmware_dependencies=("sof-firmware" "bluez-utils" "pulseaudio-bluetooth")

packages=()
ask_for_packages "intel drivers" drivers[@]
echo
ask_for_packages "display" display_packages[@] display_dependencies[@]
echo
ask_for_packages "shell" shell_packages[@] shell_dependencies[@]
echo
ask_for_packages "misc" misc_packages[@] misc_dependencies[@]
echo
ask_for_packages "application" application_packages[@] application_dependencies[@]
echo
ask_for_packages "firmware_packages" firmware_packages[@] firmware_dependencies[@]
echo

if [[ ${#packages[@]} -gt 0 ]]; then
    install_packages "${packages[@]}"
fi

systemctl enable sddm

BLUE "[*] Changing shell to Zsh..."
sudo sed -i "s/\/home\/$user:\/usr\/bin\/bash/\/home\/$user:\/usr\/bin\/zsh/" /etc/passwd
chsh -s /bin/zsh $user

BLUE "[*] Setting up Spotify..."
su - $user -c "systemctl --user enable spotifyd.service"

BLUE "[*] Setting up Light..."
echo 'ACTION=="add", SUBSYSTEM=="backlight", RUN+="/bin/chgrp video $sys$devpath/brightness", RUN+="/bin/chmod g+w $sys$devpath/brightness"' > /etc/udev/rules.d/backlight.rules

BLUE "[*] Setting up Plymouth..."
plymouth_search="HOOKS=(base udev"
line_num=$(grep -n "HOOKS=(base udev" /etc/mkinitcpio.conf | awk 'END {print $1}' | cut -d: -f1)
sed -i "$line_num"'s/$plymouth_search/$plymouth_search plymouth/' /etc/mkinitcpio.conf
sed -i 's/GRUB_CMDLINE_LINUX_DEFAULT=\(.*\)/GRUB_CMDLINE_LINUX_DEFAULT="loglevel=3 quiet splash"/'
plymouth-set-default-theme -R flame

BLUE "[*] Enabling Pulse Audio..."
su - $user -c "systemctl --user enable pulseaudio"

BLUE "[*] Setting up man pages..."
mandb

# Comment out any of the following dotfiles to keep current files
function dotfiles(){
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
    
    # Bat dotfiles
    BLUE "[*] Installing Bat dotfiles..."
    cp -r $SCRIPT_DIR/dotfiles/bat /home/$user/.config

	# Ownership
    BLUE "[*] Granting ownership..."
	chown -R $user /home/$user/.config /usr/share/sddm/themes /etc/sddm.conf /home/$user/Pictures /usr/share/grub/themes/sleek /home/$user/.zshrc
}

if [[ $APPLY_DOTFILES_PROMPT == "yes" ]]; then
    dotfiles;
elif [[ $APPLY_DOTFILES_PROMPT != "no" ]]; then
    BLUE "   Would you like to copy modified dotfiles?"
    read -n1 -p "   Please type Y or N : " userinput
    case $userinput in
            y|Y) BLUE "[*] Copying dotfiles..."; dotfiles;;
            n|N) BLUE "[*] Keeping defaults..." ;;
            *) RED "[!] Invalid response, keeping defaults...";;
    esac
fi

# Remove changes to /etc/sudoers
sed -i '$ d' /etc/sudoers

GREEN "[++] All done! Remember to reboot and login again to see the full changes!"
