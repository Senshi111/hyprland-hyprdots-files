#!/bin/bash


#// set variables

scrDir="$(dirname "$(realpath "$0")")"
source "${scrDir}/globalcontrol.sh"
rofiConf="${confDir}/rofi/selector.rasi"
rofiStyleDir="${confDir}/rofi/styles"
rofiAssetDir="${confDir}/rofi/assets"


#// set rofi scaling

[[ "${rofiScale}" =~ ^[0-9]+$ ]] || rofiScale=10
r_scale="configuration {font: \"JetBrainsMono Nerd Font ${rofiScale}\";}"


#// scale for monitor

x_monres=$(hyprctl -j monitors | jq '.[] | select(.focused==true) | .width')
y_monres=$(hyprctl -j monitors | jq '.[] | select(.focused==true) | .height')
aspect_r=$((x_monres * 10 / y_monres ))


#// generate config

elem_border=$(( hypr_border * 5 ))
icon_border=$(( elem_border - 5 ))
i_size=$(( aspect_r - 4 ))
r_override="listview{columns:5;} element{orientation:vertical;border-radius:${elem_border}px;} element-icon{border-radius:${icon_border}px;size:${i_size}em;} element-text{enabled:false;}"


#// launch rofi menu

RofiSel=$(ls ${rofiStyleDir}/style_*.rasi | awk -F '[_.]' '{print $((NF - 1))}' | while read styleNum
do
    echo -en "${styleNum}\x00icon\x1f${rofiAssetDir}/style_${styleNum}.png\n"
done | sort -n | rofi -dmenu -theme-str "${r_override}" -config "${rofiConf}" -select "${rofiStyle}")


#// apply rofi style

if [ ! -z "${RofiSel}" ] ; then
    set_conf "rofiStyle" "${RofiSel}"
    notify-send -a "t1" -r 91190 -t 2200 -i "${rofiAssetDir}/style_${RofiSel}.png" " style ${RofiSel} applied..." 
fi

