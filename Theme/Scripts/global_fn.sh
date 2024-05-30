#!/bin/bash
#|---/ /+------------------+---/ /|#
#|--/ /-| Global functions |--/ /-|#
#|-/ /--| Prasanth Rangan  |-/ /--|#
#|/ /---+------------------+/ /---|#

set -e

scrDir="$(dirname "$(realpath "$0")")"
cloneDir="$(dirname "${scrDir}")"
confDir="${XDG_CONFIG_HOME:-$HOME/.config}"
cacheDir="$HOME/.cache/hyde"
aurList=(yay paru)
shlList=(zsh fish)


get_distro() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        echo $ID
    else
        echo "Unknown"
    fi
}


pkg_installed()
{
    local PkgIn=$1
local distro=$(get_distro)

    if [ "$distro" == "debian" ] || [ "$distro" == "ubuntu" ]; then
        if dpkg -s "$PkgIn" &>/dev/null; then
        return 0
        else
            return 1
        fi
    elif [ "$distro" == "fedora" ]; then
        if rpm -qa | grep "$PkgIn" &>/dev/null; then
        return 0
    else
        return 1
    fi
    else
        echo "Unsupported distribution: $distro"
        return 1
    fi
}

chk_list()
{
    vrType="$1"
    local inList=("${@:2}")
    for pkg in "${inList[@]}" ; do
        if pkg_installed "${pkg}" ; then
            printf -v "${vrType}" "%s" "${pkg}"
            export "${vrType}"
            return 0
        fi
    done
    return 1
}

pkg_available()
{
    local PkgIn=$1
local distro=$(get_distro)

    if [ "$distro" == "debian" ] || [ "$distro" == "ubuntu" ]; then
        if apt show "$PkgIn" &>/dev/null; then
        return 0
        else
            return 1
        fi
    elif [ "$distro" == "fedora" ]; then
        if dnf info "$PkgIn" &>/dev/null; then
        return 0
    else
        return 1
    fi
    else
        echo "Unsupported distribution: $distro"
        return 1
    fi
}

aur_available()
{
    local PkgIn=$1
local distro=$(get_distro)

    if [ "$distro" == "debian" ] || [ "$distro" == "ubuntu" ]; then
        if apt show "$PkgIn" &>/dev/null; then
        return 0
        else
            return 1
        fi
    elif [ "$distro" == "fedora" ]; then
        if dnf info "$PkgIn" &>/dev/null; then
        return 0
    else
        return 1
        fi
    else
        echo "Unsupported distribution: $distro"
        return 1
    fi
}

nvidia_detect()
{
    dGPU=$(lspci -k | grep -A 0 -E "(VGA|3D)" | awk -F 'controller: ' '{print $2}')
    if [ $(lspci -k | grep -A 2 -E "(VGA|3D)" | grep -i nvidia | wc -l) -gt 0 ]
    then
        #echo "nvidia card detected..."
        return 0
    else
        #echo "nvidia card not detected..."
        return 1
    fi
}

prompt_timer() {
    set +e
    unset promptIn
    local timsec=$1
    local msg=$2
    while [[ ${timsec} -ge 0 ]]; do
        echo -ne "\r :: ${msg} (${timsec}s) : "
        read -t 1 -n 1 promptIn
        [ $? -eq 0 ] && break
        ((timsec--))
    done
    export promptIn
    echo ""
    set -e
}
