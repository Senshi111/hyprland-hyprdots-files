#!/bin/bash
#|---/ /+--------------------------------------+---/ /|#
#|--/ /-| Script to apply post install configs |--/ /-|#
#|-/ /--| Prasanth Rangan                      |-/ /--|#
#|/ /---+--------------------------------------+/ /---|#

source global_fn.sh
if [ $? -ne 0 ] ; then
    echo "Error: unable to source global_fn.sh, please execute from $(dirname "$(realpath "$0")")..."
    exit 1
fi


# sddm
if pkg_installed sddm
    then

    echo -e "\033[0;32m[DISPLAYMANAGER]\033[0m detected // sddm"
    if [ ! -d /etc/sddm.conf.d ] ; then
        sudo mkdir -p /etc/sddm.conf.d
    fi

    if [ ! -f /etc/sddm.conf.d/kde_settings.t2.bkp ] ; then
        echo -e "\033[0;32m[DISPLAYMANAGER]\033[0m configuring sddm..."
        echo -e "Select sddm theme:\n1) Candy\n2) Corners"
        read -p "Enter option number : " sddmopt

        case $sddmopt in
        1) sddmtheme="Candy";;
        *) sddmtheme="Corners";;
        esac

        sudo tar -xzf ${CloneDir}/Source/arcs/Sddm_${sddmtheme}.tar.gz -C /usr/share/sddm/themes/
        sudo touch /etc/sddm.conf.d/kde_settings.conf
        sudo cp /etc/sddm.conf.d/kde_settings.conf /etc/sddm.conf.d/kde_settings.t2.bkp
        sudo cp /usr/share/sddm/themes/${sddmtheme}/kde_settings.conf /etc/sddm.conf.d/
    else
        echo -e "\033[0;33m[SKIP]\033[0m sddm is already configured..."
    fi

    if [ ! -f /usr/share/sddm/faces/${USER}.face.icon ] && [ -f ${CloneDir}/Source/misc/${USER}.face.icon ] ; then
        sudo cp ${CloneDir}/Source/misc/${USER}.face.icon /usr/share/sddm/faces/
        echo -e "\033[0;32m[DISPLAYMANAGER]\033[0m avatar set for ${USER}..."
    fi

else
    echo -e "\033[0;33m[WARNING]\033[0m sddm is not installed..."
fi


# dolphin
if pkg_installed dolphin && pkg_installed xdg-utils
    then

    echo -e "\033[0;32m[FILEMANAGER]\033[0m detected // dolphin"
    xdg-mime default org.kde.dolphin.desktop inode/directory
    echo -e "\033[0;32m[FILEMANAGER]\033[0m setting" `xdg-mime query default "inode/directory"` "as default file explorer..."

else
    echo -e "\033[0;33m[WARNING]\033[0m dolphin is not installed..."
fi


# shell
./restore_shl.sh ${getShell}


# themepatcher
echo -e "\033[0;32m[THEMEPATCHER]\033[0m additional themes available..."
awk -F '"' '{print $2}' themepatcher.lst
read -p "Patch these additional themes? [Y/n]: " thmopt
thmopt=${thmopt,,}

if [ "${thmopt}" = "y" ] ; then
    echo -e "\033[0;32m[THEMEPATCHER]\033[0m Patching themes..."
    while read -r themeName themeRepo themeCode
    do
        themeName="${themeName//\"/}"
        themeRepo="${themeRepo//\"/}"
        themeCode="${themeCode//\"/}"
        ./themepatcher.sh "${themeName}" "${themeRepo}" "${themeCode}"
    done < themepatcher.lst
else
    echo -e "\033[0;33m[SKIP]\033[0m additional themes not patched..."
fi
