#!/bin/bash
#|---/ /+--------------------------+---/ /|#
#|--/ /-| Main installation script |--/ /-|#
#|-/ /--| Prasanth Rangan          |-/ /--|#
#|/ /---+--------------------------+/ /---|#

# Function to display a banner
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

# Function to restore custom configurations
restore_configs() {
    cat << "EOF"

             _           _
 ___ ___ ___| |_ ___ ___|_|___ ___
|  _| -_|_ -|  iclecc.md |  | . |
|_| |___|___|_| |___|_| |_|_|_|_  |
                              |___|

EOF

    # You need to provide the appropriate script names for restoring configs.
     ./restore_fnt.sh
     ./restore_cfg.sh
}

# Function to update SDDM, GRUB, and Zsh
update_system() {
    # You should adjust this line to fit the Fedora equivalent of restore_sgz.sh.
     echo "Updating SDDM, GRUB, and Zsh on Fedora..."
}

# Function to enable system services
enable_services() {
    cat << "EOF"

                 _
 ___ ___ ___ _ _|_|___ ___ ___
|_ -| -_|  _| | | | iclecc.md
|___|___|_|  \_/|_|___|___|___|

EOF

    # Adjust service names for Fedora.
    service_ctl NetworkManager
    service_ctl bluetooth
    service_ctl sddm
}

# Display the banner
show_banner

# Import variables and functions
source global_fn.sh
if [ $? -ne 0 ]; then
    echo "Error: Unable to source global_fn.sh, please execute from "$(dirname "$(realpath "$0")")"..."
    exit 1
fi

# Function to configure authentication agent for GUI apps
configure_authentication_agent() {
    local distro=$(get_distro)
    local conf_file="$HOME/.config/hypr/hyprland.conf"
    local auth_exec_line=""

    if [ "$distro" == "debian" ]; then
        auth_exec_line="exec-once = /usr/lib/x86_64-linux-gnu/libexec/polkit-kde-authentication-agent-1 # authentication dialogue for GUI apps"
    elif [ "$distro" == "fedora" ]; then
        auth_exec_line="exec-once = /usr/libexec/kf5/polkit-kde-authentication-agent-1 # authentication dialogue for GUI apps"
    else
        echo "Unsupported distribution: $distro"
        return 1
    fi

    # Check if the line already exists in the file
    if grep -q "$auth_exec_line" "$conf_file"; then
        echo "Authentication agent configuration already exists in $conf_file"
    else
        # Insert the line at line 42 in the file
        sed -i "43i$auth_exec_line" "$conf_file"
        echo "Authentication agent configuration added to line 43 in $conf_file"
    fi
}


# Evaluate options
flg_Restore=1
flg_Service=0

while getopts "idrs" RunStep; do
    case $RunStep in
    r) flg_Restore=1 ;;
    s) flg_Service=1 ;;
    *) echo "...valid options are..."
       echo "i : [i]nstall hyprland without configs"
       echo "r : [r]estore config files"
       echo "s : start system [s]ervices"
       exit 1 ;;
    esac
done

if [ $OPTIND -eq 1 ]; then
    flg_Install=1
    flg_Restore=1
    flg_Service=1
fi


if [ $flg_Restore -eq 1 ]; then
    restore_configs
fi

if [ $flg_Install -eq 1 ] && [ $flg_Restore -eq 1 ]; then
    update_system
fi

# Configure authentication agent for GUI apps
configure_authentication_agent

if [ $flg_Service -eq 1 ]; then
    enable_services
fi

