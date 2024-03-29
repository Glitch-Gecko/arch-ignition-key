#!/bin/bash
# Arch install script by GlitchGecko
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
while getopts ":AadyY-:" opt; do
  case $opt in
    A )
      APPLY_ALL="yes"
      APPLY_DOTFILES_PROMPT="yes"
      ;;
    a )
      APPLY_PACKAGES="yes"
      APPLY_DOTFILES_PROMPT="yes"
      APPLY_DRIVER_PACKAGES="no"
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

# Check if paru not installed, install paru
if ! type "paru" > /dev/null; then
    BLUE "[*] Installing paru..."
    pacman -S --needed git base-devel --noconfirm
    su - $user -c "git clone https://aur.archlinux.org/paru.git"
    su - $user -c "cd paru; makepkg -si && cd .."
    rm -rf paru
fi

# Function to handle package installation
function install_packages() {
    for package in "${@}"; do
        if ! pacman -Qq "$package" &> /dev/null; then
            BLUE "[*] Installing $package..."
            su - $user -c "paru -S --noconfirm --needed $package"
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

display_packages=("hyprland" "swww" "sddm-git" "kitty" "alacritty" "waybar-hyprland" "plymouth-git" "light" "cava" "pcmanfm" "polkit-kde-agent")
display_dependencies=("qt5-graphicaleffects" "qt5-svg" "qt5-quickcontrols2" "plymouth-theme-flame-git")

shell_packages=("zsh" "neovim" "starship" "tree" "ttf-hack-nerd" "noto-fonts" "noto-fonts-emoji" "man-db" "bat")
shell_dependencies=("nvim-packer-git" "man-pages" "ripgrep-all")

misc_packages=("neofetch" "fortune-mod" "cowsay" "lolcat" "tty-clock-git" "thefuck" "btop")
misc_dependencies=("imagemagick")

application_packages=("firefox" "discord" "spotify-tui" "obsidian-appimage" "p7zip" "zathura" "wofi" "dunst")
application_dependencies=("spotifyd" "zathura-pdf-mupdf" "playerctl" "jq" "gnome-keyring")

firmware_packages=("bluez" "pulseaudio-alsa" "wl-clipboard" "network-manager-applet" "grim" "pavucontrol" "slurp" "xbindkeys" "blueman" "pipewire" "wireplumber" "xdg-desktop-portal-hyprland-git" "xdg-desktop-portal-gtk" "xwaylandvideobridge-git")
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
systemctl --user -M $user@ enable spotifyd

BLUE "[*] Setting up Light..."
echo 'ACTION=="add", SUBSYSTEM=="backlight", RUN+="/bin/chgrp video $sys$devpath/brightness", RUN+="/bin/chmod g+w $sys$devpath/brightness"' > /etc/udev/rules.d/backlight.rules

BLUE "[*] Setting up Plymouth..."
plymouth_search="HOOKS=(base udev"
line_num=$(grep -n "HOOKS=(base udev" /etc/mkinitcpio.conf | awk 'END {print $1}' | cut -d: -f1)
sed -i "$line_num"'s/$plymouth_search/$plymouth_search plymouth/' /etc/mkinitcpio.conf
plymouth-set-default-theme -R flame

BLUE "[*] Enabling Pulse Audio..."
systemctl --user -M $user@ enable pulseaudio

BLUE "[*] Setting up man pages..."
mandb

BLUE "[*] Setting up Zathura..."
xdg-mime default org.pwmt.zathura.desktop application/pdf

BLUE "[*] Changing Headers..."
sed -i 's/GRUB_CMDLINE_LINUX_DEFAULT=\(.*\)/GRUB_CMDLINE_LINUX_DEFAULT="loglevel=3 quiet splash ibt=off"/' /etc/default/grub

# Comment out any of the following dotfiles to keep current files
function dotfiles(){
    git clone https://github.com/Glitch-Gecko/configs.git
    cd configs/dotfiles

    # Hypr dotfiles
    BLUE "[*] Installing Hypr dotfiles..."
	su - $user -c "mkdir /home/$user/.config; mkdir /home/$user/.config/hypr"
	cp -r hypr /home/$user/.config/
    cp hypr/config.ini /home/$user/

	# Sddm dotfiles
    BLUE "[*] Installing Sddm dotfiles..."
	cp -r sddm/themes /usr/share/sddm
	cp sddm/sddm.conf /etc/sddm.conf

	# Kitty dotfiles
    BLUE "[*] Installing Kitty dotfiles..."
	cp -r kitty /home/$user/.config/
	
	# Grub dotfiles
    BLUE "[*] Installing Grub dotfiles..."
	cp -r grub/themes/sleek /usr/share/grub/themes
	cp grub/grub /etc/default/
    grub-mkconfig -o /boot/grub/grub.cfg

	# Firefox dotfiles
    BLUE "[*] Installing Firefox dotfiles..."
	git clone https://github.com/PROxZIMA/prism
	chown -R $user prism
	cp -r prism /home/$user/.mozilla/firefox/
	rm -rf prism
	cp firefox/mozilla.cfg /usr/lib/firefox/
	cp firefox/local-settings.js /usr/lib/firefox/defaults/pref/
    echo -e 'user_pref("browser.startup.homepage", "file:///home/'"$user"'/.mozilla/firefox/prism/index.html");' >> /home/$user/.mozilla/firefox/*.default*/prefs.js

	# Alacritty dotfiles
    BLUE "[*] Installing Alacritty dotfiles..."
	mkdir /home/$user/.config/alacritty
	cp alacritty/alacritty.yml /home/$user/.config/alacritty
	su - $user -c "git clone https://github.com/catppuccin/alacrity.git ~/.config/alacritty/catppuccin"

	# Nvim dotfiles
    BLUE "[*] Installing Nvim dotfiles..."
	cp -r nvim/ /home/$user/.config/

	# Zsh dotfiles
    BLUE "[*] Installing Zsh dotfiles..."
    su -c 'sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended --keep-zshrc' $user
    git clone https://github.com/zsh-users/zsh-autosuggestions /home/$user/.oh-my-zsh//plugins/zsh-autosuggestions
	cp zsh/.zshrc /home/$user/

    # Neofetch dotfiles
    BLUE "[*] Installing Neofetch dotfiles..."
    cp -r neofetch /home/$user/.config/

    # Starship dotfiles
    BLUE "[*] Installing Starship dotfiles..."
    cp starship.toml /home/$user/.config/starship.toml

    # Spotifyd dotfiles
    BLUE "[*] Installing Spotifyd dotfiles..."
    cp -r systemd /home/$user/.config/

    # Waybar dotfiles
    BLUE "[*] Installing Waybar dotfiles..."
    cp -r waybar /home/$user/.config

    # Btop dotfiles
    BLUE "[*] Installing Btop dotfiles..."
    cp -r btop /home/$user/.config
    
    # Bat dotfiles
    BLUE "[*] Installing Bat dotfiles..."
    cp -r bat /home/$user/.config
    su -c 'sh -c "bat cache --build"' $user

    # Zathura dotfiles
    BLUE "[*] Installing Zathura dotfiles..."
    cp -r zathura /home/$user/.config

    # Dunst dotfiles
    BLUE "[*] Installing Dunst dotfiles..."
    cp -r dunst /home/$user/.config

    # Wofi dotfiles
    BLUE "[*] Installing Wofi dotfiles..."
    cp -r wofi /home/$user/.config
    
    # Spotifyd dotfiles
    BLUE "[*] Installing spotifyd dotfiles..."
    cp -r spotifyd /home/$user/.config

    # Polkit dotfiles
    BLUE "[*] Installing polkit dotfiles..."
    cp -r polkit/50-default.rules /etc/polkit-1/rules.d

	# Ownership
    BLUE "[*] Granting ownership..."
	chown -R $user /usr/share/sddm/themes /etc/sddm.conf /usr/share/grub/themes/sleek /home/$user

    cd ../..
    rm -rf configs
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
