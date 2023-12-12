#!/bin/bash

set -e

CloneDir=$(dirname "$(dirname "$(realpath "$0")")")

service_ctl()
{
    local ServChk=$1

    if systemctl is-active --quiet "${ServChk}.service"
    then
        echo "$ServChk service is already enabled, enjoy..."
    else
        echo "$ServChk service is not running, enabling..."
        sudo systemctl enable "${ServChk}.service"
        sudo systemctl start "${ServChk}.service"
        echo "$ServChk service enabled, and running..."
    fi
}

get_distro()
{
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

    if [ "$distro" == "debian" ]; then
        if dpkg -s "$PkgIn" &>/dev/null; then
            return 0
        else
            return 1
        fi
    elif [ "$distro" == "fedora" ]; then
        if rpm -q "$PkgIn" &>/dev/null; then
            return 0
        else
            return 1
        fi
    else
        echo "Unsupported distribution: $distro"
        return 1
    fi
}

pkg_available()
{
    local PkgIn=$1
    local distro=$(get_distro)

    if [ "$distro" == "debian" ]; then
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
    if lspci -k | grep -A 2 -E "(VGA|3D)" | grep -iq nvidia
    then
        return 0
    else
        return 1
    fi
}


