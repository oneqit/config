#!/data/data/com.termux/files/usr/bin/bash

# Colors
NC="\e[0m"              # No Color
BLACK='\e[1;30m'        # Black
RED='\e[1;31m'          # Red
GREEN='\e[1;32m'        # Green
YELLOW='\e[1;33m'       # Yellow
BLUE='\e[0;34m'         # Blue
PURPLE='\e[1;35m'       # Purple
CYAN='\e[1;36m'         # Cyan
WHITE='\e[1;37m'        # White

# Functions
error   () { echo -e "${RED}${*}${NC}";exit 1;:; }
warning () { echo -e "${YELLOW}${*}${NC}";:; }
info    () { echo -e "${GREEN}-----";echo -e "# ${*}";echo -e "-----${NC}";:; }
log     () { echo -e "${BLUE}${*}${NC}";:; }

# Termux package update
info "Termux package update"
log "pkg up -y"
pkg up -y

# termux-setup-storage
info "termux-setup-storage"
termux-setup-storage

# Install packages
info "Install packages"
log "apt install -y git zsh vim neofetch openssh wget"
apt update
apt install -y git zsh vim neofetch openssh wget

# Install oh-my-zsh
info "Install oh-my-zsh"
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# Change shell to zsh
info "Change shell to zsh"
log "chsh -s zsh"
chsh -s zsh

# Done
warning "Please Restart Termux!"

exit