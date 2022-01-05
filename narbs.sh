#!/bin/sh

[ -z "$dotfilesrepo" ] && dotfilesrepo="https://github.com/nmqd/dotfiles.git"
[ -z "$progsfile" ] && progsfile="https://raw.githubusercontent.com/nmqd/voidsetup/master/progs.csv"
[ -z "$repobranch" ] && repobranch="master"
repodir="/home/$USER/.local/src"
dotfilesdir="/home/$USER/.local/share/dotfiles"
ssid="TP-Link_5C17"
wifi_pass="30048805"

### FUNCTIONS ###

installpkg(){ doas xbps-install -Sy "$1" >/dev/null 2>&1 ;}
enable_service(){ doas ln -sf "$1" "$2" >/dev/null 2>&1 ;}

maininstall() { # Installs all needed programs from main repo.
	installpkg "$1"
	}

gitmakeinstall() {
	progname="$(basename "$1" .git)"
	dir="$repodir/$progname"
	git clone "$1" "$dir" >/dev/null 2>&1 || { cd "$dir" || return 1 ; git pull --force origin master;}
	cd "$dir" || exit 1
  	doas make >/dev/null 2>&1
  	doas make clean install >/dev/null 2>&1
	cd /tmp || return 1 ;}

pipinstall() { \
	[ -x "$(command -v "pip")" ] || installpkg python3-pip >/dev/null 2>&1
	pip install "$1"
	}

putgitrepo() { 
	[ -z "$3" ] && branch="master" || branch="$repobranch"
	git clone "$1" "$dotfilesdir" >/dev/null 2>&1
	}

installationloop() { \
	([ -f "$progsfile" ] && cp "$progsfile" /tmp/progs.csv) || curl -Ls "$progsfile" | sed '/^#/d' > /tmp/progs.csv
	total=$(wc -l < /tmp/progs.csv)
	while IFS=, read -r tag program comment; do
		n=$((n+1))
    	printf "%s\n" "Installing $program ($n/$total)"
		case "$tag" in
			"D") putgitrepo "$dotfilesrepo" ;;
			"G") gitmakeinstall "$program" ;;
			"P") pipinstall "$program" ;;
			*) maininstall "$program" ;;
		esac
	done < /tmp/progs.csv ;}

# doas is better :)
sudo xbps-install -Sy opendoas ;
echo "permit nopass :wheel" | sudo tee /etc/doas.conf ;
doas chown -c root:root /etc/doas.conf ;
doas chmod -c 0400 /etc/doas.conf ;

# Install packages
installationloop ;
xdg-user-dirs-update ;

# setup Wifi
wpa_passphrase $ssid $wifi_pass | doas tee -a /etc/wpa_supplicant/wpa_supplicant.conf ;

# create and remove runtime directories
echo "session 	optional 	pam_rundir.so" | doas tee -a /etc/pam.d/login

# Battery Care -- Charge thresholds
doas sed -i "s/^#START_CHARGE_THRESH_BAT0=75/START_CHARGE_THRESH_BAT0=40/ ; s/^#STOP_CHARGE_THRESH_BAT0=80/STOP_CHARGE_THRESH_BAT0=80/" /etc/tlp.conf

# Enable services
enable_service /etc/sv/dbus /var/service ;
enable_service /etc/sv/cronie /var/service
enable_service /etc/sv/tlp /var/service ;
enable_service /etc/sv/wpa_supplicant /var/service ;

# dotfiles
# git clone $dotfilesrepo $dotfilesdir >/dev/null 2>&1
rm -f ~/.bash* ~/.inputrc ~/.wget* ;
cd $dotfilesdir && stow * ;

cp -r /home/najib/voidsetup/wallpapers /home/najib/Pictures ;
cp -r /home/najib/voidsetup/fonts /home/najib/.local/share ;
# sh /home/najib/.local/bin/setbg ~/Pictures >/dev/null 2>$1 ;
fc-cache ;

# add user to adbusers group
doas usermod -aG adbusers $USER

# Make some dirs
mkdir -p ~/.local/share/mpd ~/.local/state/zsh ;

# Install theme.sh from lemnos
# https://github.com/lemnos/theme.sh
curl -Lo ~/.local/bin/theme.sh 'https://git.io/JM70M' && chmod +x ~/.local/bin/theme.sh ;

# changing the default shell to zsh
doas chsh -s /usr/bin/zsh $USER ;

# clean up
rm -f /tmp/progs.csv ;

# Install nnn plugins
# if command -v nnn >/dev/null 2>&1 ; then
#   curl -Ls https://raw.githubusercontent.com/jarun/nnn/master/plugins/getplugs | sh
# else
#   return 1
# fi

#clear

printf "\nFinished\nPlease reboot your computer\n"
