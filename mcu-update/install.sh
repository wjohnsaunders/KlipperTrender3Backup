#!/bin/bash -x

KLIPPER=~/klipper
MCU_UPDATE=~/mcu-update

update_if_changed() {
    cmp -s $1 $2 || cp $1 $2
}

build_klipper() {
    local CONFIG_FILE=$1
    cd ${KLIPPER}
    cp ${MCU_UPDATE}/${CONFIG_FILE} ${KLIPPER}/.config
    make clean
    make menuconfig
    make
    update_if_changed ${KLIPPER}/.config ${MCU_UPDATE}/${CONFIG_FILE}
}

flash_via_can() {
    ~/katapult/scripts/flashtool.py -i can0 -u "$1"
    sleep 3
}

flash_via_serial() {
    ~/katapult/scripts/flashtool.py -d "$1" -r
    ~/katapult/scripts/flashtool.py -d "$1"
    sleep 3
}

sudo service klipper stop

echo "Updating mcu - Fysetc Spider H7"
build_klipper config-spiderH7
flash_via_can 5fa18a5c2751

#echo "Updating mcu - Creality V4.2.2"
#build_klipper config-creality-v4
#flash_via_serial /dev/serial/by-path/platform-xhci-hcd.0-usb-0:1:1.0-port0

echo "Updating mcu - Mellow Fly SHT36 V3"
build_klipper config-sht36-v3
flash_via_can bdcba9d5a55b
#flash_via_can 270a34f9f254

sudo service klipper start

