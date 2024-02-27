#!/bin/bash

# wallpaper var
EnableWallDcol=0
ConfDir="${XDG_CONFIG_HOME:-$HOME/.config}"
CloneDir="$HOME/Hyprdots"
ThemeCtl="$ConfDir/hypr/theme.ctl"
cacheDir="$HOME/.cache/hyprdots"

# theme var
gtkTheme=`gsettings get org.gnome.desktop.interface gtk-theme | sed "s/'//g"`
gtkMode=`gsettings get org.gnome.desktop.interface color-scheme | sed "s/'//g" | awk -F '-' '{print $2}'`

# hypr var
hypr_border=`hyprctl -j getoption decoration:rounding | jq '.int'`
hypr_width=`hyprctl -j getoption general:border_size | jq '.int'`

# notification var
#ncolor="-h string:bgcolor:#191724 -h string:fgcolor:#faf4ed -h string:frcolor:#56526e"
#
#if [ "${gtkMode}" == "light" ] ; then
#    ncolor="-h string:bgcolor:#f4ede8 -h string:fgcolor:#9893a5 -h string:frcolor:#908caa"
#fi

# Function to check if a package is installed
pkg_installed() {
    local PkgIn=$1

    if command -v dpkg &> /dev/null; then
        dpkg -l $PkgIn &> /dev/null
    elif command -v rpm &> /dev/null; then
        rpm -q $PkgIn &> /dev/null
    else
        echo "Unsupported package manager. Exiting..."
        exit 1
    fi
}

# Function to check dependencies
# Function to check dependencies
check() {
    local Pkg_Dep=$(for PkgIn in "$@"; do ! pkg_installed $PkgIn && echo "$PkgIn"; done)

if [ -n "$Pkg_Dep" ]; then
        echo -e "$0 Dependencies:\n$Pkg_Dep"
    read -p "ENTER to install (Other key: Cancel): " ans
    if [ -z "$ans" ]; then
            case $DISTRO in
                "fedora")
                    sudo dnf install $Pkg_Dep
                    ;;
                "debian")
                    sudo apt-get install $Pkg_Dep
                    ;;
                *)
                    echo "Unsupported distribution: $DISTRO. Exiting..."
                    exit 1
                    ;;
            esac
        else
            echo "Skipping installation of packages"
            exit 1
    fi
fi
}

# Check distribution type
if [ -e "/etc/os-release" ]; then
    DISTRO=$(awk -F= '/^ID=/{print $2}' /etc/os-release | tr -d '"')
else
    echo "Unable to determine the distribution. Exiting..."
    exit 1
fi

case $DISTRO in
    "fedora")
        # Fedora-specific code can be added here if needed
        echo "Fedora detected"
        ;;
    "debian")
        # Debian-specific code can be added here if needed
        echo "Debian detected"
        ;;
    *)
        echo "Unsupported distribution: $DISTRO. Exiting..."
        exit 1
        ;;
esac
