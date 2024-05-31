#!/bin/bash

# Use different directory on NixOS
if [ -d /run/current-system/sw/libexec ]; then
    libDir=/run/current-system/sw/libexec
else
    libDir=/usr/libexec/kf6
fi

$libDir/polkit-kde-authentication-agent-1 &
