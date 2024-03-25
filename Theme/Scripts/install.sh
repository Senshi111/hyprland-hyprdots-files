#!/bin/bash
#|---/ /+--------------------------+---/ /|#
#|--/ /-| Main installation script |--/ /-|#
#|-/ /--| Prasanth Rangan          |-/ /--|#
#|/ /---+--------------------------+/ /---|#

# Function to display a banner
scrDir=$(dirname "$(realpath "$0")")
source "${scrDir}/global_fn.sh"
if [ $? -ne 0 ] ; then
    echo "Error: unable to source global_fn.sh..."
    exit 1
fi

show_banner() {
    cat << "EOF"

-----------------------------------------------------------------
        _  _                  _     _
      | || |_  _ _ __ _ _ __| |___| |_ ___
     | __ | || | '_ \ '_/ _` / _ \  _(_-<
    |_||_|\_, | .__/_| \__,_\___/\__/__/
   |__/|_|

-----------------------------------------------------------------

EOF
}


#--------------------------------#
# import variables and functions #
#--------------------------------#



#------------------#
# evaluate options #
#------------------#
flg_Install=0
flg_Restore=0
flg_Service=0

while getopts idrs RunStep ; do
    case $RunStep in
    i)  flg_Install=1 ;;
    d)  flg_Install=1 ; export use_default="--noconfirm" ;;
    r)  flg_Restore=1 ;;
    s)  flg_Service=1 ;;
    *)  echo "...valid options are..."
        echo "i : [i]nstall hyprland without configs"
        echo "d : install hyprland [d]efaults without configs --noconfirm"
        echo "r : [r]estore config files"
        echo "s : enable system [s]ervices"
        exit 1 ;;
    esac
done

if [ $OPTIND -eq 1 ]; then
    flg_Install=1
    flg_Restore=1
    flg_Service=1
fi


#--------------------#
# pre-install script #
#--------------------#
if [ ${flg_Install} -eq 1 ] && [ ${flg_Restore} -eq 1 ] ; then
    cat <<"EOF"
                _         _       _ _
 ___ ___ ___   |_|___ ___| |_ ___| | |
| . |  _| -_|  | |   |_ -|  _| .'| | |
|  _|_| |___|  |_|_|_|___|_| |__,|_|_|
|_|

EOF

    "${scrDir}/install_pre.sh"
fi


#------------#
# installing #
#------------#
# if [ $flg_Install -eq 1 ]; then
    #     cat <<"EOF"
#
#  _         _       _ _ _
# |_|___ ___| |_ ___| | |_|___ ___
# | |   |_ -|  _| .'| | | |   | . |
# |_|_|_|___|_| |__,|_|_|_|_|_|_  |
                            #                             |___|
#
# EOF
#
#     #----------------------#
    #     # prepare package list #
    #     #----------------------#
    #     # shift $((OPTIND - 1))
    #     # cust_pkg=$1
    #     # cp custom_hypr.lst install_pkg.lst
#
#     # if [ -f "$cust_pkg" ] && [ ! -z "$cust_pkg" ]; then
        #     #     cat $cust_pkg >>install_pkg.lst
#     # fi
#
#     #-----------------------#
    #     # add shell to the list #
    #     #-----------------------#
#
#
#     #--------------------------------#
#     # add nvidia drivers to the list #
#     #--------------------------------#
#
#
#     #--------------------------------#
    #     # install packages from the list #
    #     #--------------------------------#
    #     # ./install_pkg.sh install_pkg.lst
#     # rm install_pkg.lst
#
# fi


#---------------------------#
# restore my custom configs #
#---------------------------#
if [ ${flg_Restore} -eq 1 ] ; then
    cat <<"EOF"

             _           _
 ___ ___ ___| |_ ___ ___|_|___ ___
|  _| -_|_ -|  _| . |  _| |   | . |
|_| |___|___|_| |___|_| |_|_|_|_  |
                              |___|

EOF

    "${scrDir}/restore_fnt.sh"
    "${scrDir}/restore_cfg.sh"
fi


#---------------------#
# post-install script #
#---------------------#
if [ ${flg_Install} -eq 1 ] && [ ${flg_Restore} -eq 1 ] ; then
    cat <<"EOF"

             _      _         _       _ _
 ___ ___ ___| |_   |_|___ ___| |_ ___| | |
| . | . |_ -|  _|  | |   |_ -|  _| .'| | |
|  _|___|___|_|    |_|_|_|___|_| |__,|_|_|
|_|

EOF

    "${scrDir}/install_pst.sh"
fi


#------------------------#
# enable system services #
#------------------------#
if [ ${flg_Service} -eq 1 ] ; then
    cat <<"EOF"

                 _
 ___ ___ ___ _ _|_|___ ___ ___
|_ -| -_|  _| | | |  _| -_|_ -|
|___|___|_|  \_/|_|___|___|___|

EOF

    while read servChk ; do

        if [[ $(systemctl list-units --all -t service --full --no-legend "${servChk}.service" | sed 's/^\s*//g' | cut -f1 -d' ') == "${servChk}.service" ]] ; then
            echo -e "\033[0;33m[SKIP]\033[0m ${servChk} service is active..."
        else
            echo -e "\033[0;32m[systemctl]\033[0m starting ${servChk} system service..."
            sudo systemctl enable "${servChk}.service"
            sudo systemctl start "${servChk}.service"
        fi

    done < "${scrDir}/system_ctl.lst"
fi

