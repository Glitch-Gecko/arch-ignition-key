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
APPLY_ALL='yes'

usage() {
  echo "Usage: $0 [-A] [-d] [--no-dots] [-y] [-Y] [--no-packages]" 1>&2;
  exit 1;
}

# Get options from command line
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
shell_packages=("zsh" "neovim" "starship" "tree" "ttf-hack-nerd" "man-db" "bat")
shell_dependencies=("nvim-packer-git" "man-pages" "ripgrep-all")

misc_packages=("neofetch" "fortune-mod" "cowsay" "lolcat" "tty-clock-git" "thefuck" "htop")

application_packages=("p7zip")

firmware_packages=("pipewire" "wireplumber")
firmware_dependencies=("sof-firmware")

packages=()
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

BLUE "[*] Enabling Pulse Audio..."
systemctl --user -M $user@ enable pulseaudio

BLUE "[*] Setting up man pages..."
mandb

# Comment out any of the following dotfiles to keep current files
function dotfiles(){
    git clone https://github.com/Glitch-Gecko/configs.git
    cd configs/dotfiles

	# Grub dotfiles
    BLUE "[*] Installing Grub dotfiles..."
	cp -r grub/themes/sleek /usr/share/grub/themes
	cp grub/grub /etc/default/
    grub-mkconfig -o /boot/grub/grub.cfg

	# Nvim dotfiles
    BLUE "[*] Installing Nvim dotfiles..."
	cp -r nvim/ /home/$user/.config/

	# Zsh dotfiles
    BLUE "[*] Installing Zsh dotfiles..."
    su -c 'sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended --keep-zshrc' $user
    git clone https://github.com/zsh-users/zsh-autosuggestions /home/$user/.oh-my-zsh//plugins/zsh-autosuggestions
	cp zsh/.zshrc /home/$user/

    # Tmux dotfiles
    BLUE "[*] Installing Tmux dotfiles..."
    cp -r tmux /home/$user/.config/

    # Neofetch dotfiles
    BLUE "[*] Installing Neofetch dotfiles..."
    cp -r neofetch /home/$user/.config/

    # Starship dotfiles
    BLUE "[*] Installing Starship dotfiles..."
    cp starship.toml /home/$user/.config/starship.toml

    # Bat dotfiles
    BLUE "[*] Installing Bat dotfiles..."
    cp -r bat /home/$user/.config
    su -c 'sh -c "bat cache --build"' $user

    # Polkit dotfiles
    BLUE "[*] Installing polkit dotfiles..."
    cp -r polkit/50-default.rules /etc/polkit-1/rules.d

	# Ownership
    BLUE "[*] Granting ownership..."
	chown -R $user /usr/share/grub/themes/sleek /home/$user

    cd ../..
    rm -rf configs
}
dotfiles;

# Remove changes to /etc/sudoers
sed -i '$ d' /etc/sudoers

GREEN "[++] All done! Remember to reboot and login again to see the full changes!"
