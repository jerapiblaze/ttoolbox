#!/bin/bash
# notify-send-all

PATH=/usr/bin:/bin

send-to() {
    local name busroute
    name="$1";  shift
    busroute="/run/user/$(id -u "$name")/bus"  ||  return 1
    sudo -u "$name" \
        PATH="$PATH" \
        DBUS_SESSION_BUS_ADDRESS="unix:path=$busroute" \
        -- \
        notify-send "$@"  2>&1  |  sed "s/^/$name\t/"
}

send-all() {
    for name in $(who | cut -f1 -d" " | sort -u)
    do
        send-to "$name" "$@" &
    done
    wait
}

broadcast() {
        wall "$1
$2"
        send-all $1 $2 -u critical -a "From sysadmin" -e
}

sudo --validate
broadcast "$@"