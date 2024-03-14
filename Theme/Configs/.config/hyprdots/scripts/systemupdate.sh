#!/bin/bash

# Check release
if [ ! -f /etc/arch-release ] ; then
    exit 0
fi

# source variables
ScrDir=`dirname "$(realpath "$0")"`
source $ScrDir/globalcontrol.sh

# Check for updates
get_aurhlpr
aur=`${aurhlpr} -Qua | wc -l`
ofc=`checkupdates | wc -l`

# Check for flatpak updates
if pkg_installed flatpak ; then
    fpk=`flatpak remote-ls --updates | wc -l`
    fpk_disp="\n󰏓 Flatpak $fpk"
    fpk_exup="; flatpak update"
else
    fpk=0
    fpk_disp=""
fi

