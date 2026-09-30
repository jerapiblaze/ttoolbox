#!/usr/bin/env bash

set -euo pipefail

error() {
    echo
    echo "[ERROR] $*" >&2
    exit 1
}

info() {
    echo "[INFO] $*"
}

prompt_required() {
    local prompt="$1"
    local value

    while true; do
        read -rp "$prompt: " value

        if [[ -n "$value" ]]; then
            echo "$value"
            return
        fi

        echo "Value cannot be empty."
    done
}

echo
echo "===================================="
echo " Normal Wi-Fi Wizard"
echo "===================================="
echo

if ! command -v nmcli >/dev/null 2>&1; then
    error "nmcli not found."
fi

if ! nmcli general status >/dev/null 2>&1; then
    error "NetworkManager is not running."
fi

#
# Connection scope
#
if [[ $EUID -eq 0 ]]; then
    CONNECTION_SCOPE="system"

    echo "Running as root."
    echo
    echo "The Wi-Fi profile will be available to ALL users."
    echo "It can also be used before login."
else
    CONNECTION_SCOPE="user"

    echo "Running as regular user."
    echo
    echo "The Wi-Fi profile will be available ONLY to:"
    echo "  $USER"
    echo
    echo "Tip: run with sudo to make it available to all users."
fi

echo
echo "Default configuration:"
echo "  Security Type            : Auto-detect"
echo "  MAC Randomization        : Never"
echo

#
# Scan Wi-Fi
#
echo "Scanning Wi-Fi networks..."
nmcli dev wifi rescan >/dev/null 2>&1 || true
sleep 2

echo
echo "Available Wi-Fi networks:"
echo

mapfile -t WIFI_NETWORKS < <(
    nmcli -t -f SSID,SIGNAL dev wifi list |
    awk -F: '
        $1 != "" {
            if ($2 > max[$1])
                max[$1] = $2
        }
        END {
            for (ssid in max)
                printf "%s:%d\n", ssid, max[ssid]
        }
    ' |
    sort -t: -k2,2nr
)

if [[ ${#WIFI_NETWORKS[@]} -eq 0 ]]; then
    echo "No Wi-Fi networks found."
    SSID=$(prompt_required "SSID")
else
    for i in "${!WIFI_NETWORKS[@]}"; do
        SSID_NAME="${WIFI_NETWORKS[$i]%:*}"
        SIGNAL="${WIFI_NETWORKS[$i]##*:}"

        printf "%2d) %-40s %3s%%\n" \
            "$((i + 1))" \
            "$SSID_NAME" \
            "$SIGNAL"
    done

    echo

    read -rp \
        "Select network number or press Enter to type SSID manually: " \
        SELECTION

    if [[ -z "${SELECTION:-}" ]]; then
        SSID=$(prompt_required "SSID")
    elif [[ "$SELECTION" =~ ^[0-9]+$ ]] &&
         (( SELECTION >= 1 && SELECTION <= ${#WIFI_NETWORKS[@]} )); then
        SSID="${WIFI_NETWORKS[$((SELECTION - 1))]%:*}"
    else
        error "Invalid selection."
    fi
fi

echo
echo "Selected SSID: $SSID"
echo

#
# Password
#
read -rp "Is this an open network? [y/N]: " OPEN_NETWORK

PASSWORD=""

if [[ ! "$OPEN_NETWORK" =~ ^[Yy]$ ]]; then
    while true; do
        read -rsp "Wi-Fi Password: " PASSWORD
        echo

        if [[ -n "$PASSWORD" ]]; then
            break
        fi

        echo "Password cannot be empty."
    done
fi

CON_NAME="wifi-${SSID}"

echo
echo "Summary"
echo "-------"
echo "SSID       : $SSID"
echo "Profile    : $CON_NAME"

if [[ "$CONNECTION_SCOPE" == "system" ]]; then
    echo "Visibility : All users"
else
    echo "Visibility : Current user only"
fi

echo

#
# Remove previous profile
#
if nmcli connection show "$CON_NAME" >/dev/null 2>&1; then
    info "Removing existing profile..."
    nmcli connection delete "$CON_NAME" >/dev/null
fi

#
# Create profile
#
info "Creating profile..."

if [[ "$CONNECTION_SCOPE" == "system" ]]; then
    nmcli connection add \
        --private no \
        type wifi \
        ifname "*" \
        con-name "$CON_NAME" \
        ssid "$SSID" >/dev/null

    nmcli connection modify \
        "$CON_NAME" \
        connection.permissions ""
else
    nmcli connection add \
        --private yes \
        type wifi \
        ifname "*" \
        con-name "$CON_NAME" \
        ssid "$SSID" >/dev/null
fi

#
# Disable MAC randomization
#
nmcli connection modify \
    "$CON_NAME" \
    802-11-wireless.mac-address-randomization never

#
# Store password if supplied.
# NetworkManager will automatically determine
# WPA/WPA2/WPA3 capabilities from the access point.
#
if [[ ! "$OPEN_NETWORK" =~ ^[Yy]$ ]]; then
    nmcli connection modify \
        "$CON_NAME" \
        wifi-sec.psk "$PASSWORD"
fi

#
# Connect
#
echo
info "Connecting to '$SSID'..."

if nmcli connection up "$CON_NAME"; then
    echo
    echo "===================================="
    echo " Connection successful"
    echo "===================================="
    echo
    echo "SSID       : $SSID"
    echo "Profile    : $CON_NAME"

    if [[ "$CONNECTION_SCOPE" == "system" ]]; then
        echo "Visibility : All users"
    else
        echo "Visibility : Current user only"
    fi
else
    echo
    echo "===================================="
    echo " Connection failed"
    echo "===================================="
    exit 1
fi