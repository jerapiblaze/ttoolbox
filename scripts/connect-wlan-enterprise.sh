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
        [[ -n "$value" ]] && {
            echo "$value"
            return
        }
        echo "Value cannot be empty."
    done
}

echo
echo "===================================="
echo " Enterprise Wi-Fi (802.1X PEAP)"
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
    echo "Tip: run using sudo to make it available to all users."
fi

echo

echo "Default configuration:"
echo "  EAP Method                : PEAP"
echo "  Inner Authentication      : MSCHAPv2"
echo "  Key Management            : WPA-EAP"
echo "  MAC Address Randomization : Never"
echo

#
# Scan networks
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
    read -rp "Select network number or press Enter to type SSID manually: " SELECTION

    if [[ -z "${SELECTION:-}" ]]; then
        SSID=$(prompt_required "SSID")
    elif [[ "$SELECTION" =~ ^[0-9]+$ ]] &&
         (( SELECTION >= 1 && SELECTION <= ${#WIFI_NETWORKS[@]} )); then
        SSID="${WIFI_NETWORKS[$((SELECTION - 1))]%:*}"
    else
        error "Invalid selection"
    fi
fi

echo
echo "Selected SSID: $SSID"
echo

#
# Credentials
#
IDENTITY=$(prompt_required "Username")

while true; do
    read -rsp "Password: " PASSWORD
    echo
    [[ -n "$PASSWORD" ]] && break
    echo "Password cannot be empty."
done

#
# CA certificate
#
echo
read -rp "Use a CA certificate? [y/N]: " USE_CA

CA_CERT=""

if [[ "$USE_CA" =~ ^[Yy]$ ]]; then
    CA_CERT=$(prompt_required "CA certificate path")
    [[ -f "$CA_CERT" ]] || error "CA certificate not found: $CA_CERT"
fi

CON_NAME="wifi-${SSID}"

echo
echo "Summary"
echo "-------"
echo "SSID       : $SSID"
echo "Username   : $IDENTITY"
echo "Profile    : $CON_NAME"

if [[ "$CONNECTION_SCOPE" == "system" ]]; then
    echo "Visibility : All users"
else
    echo "Visibility : Current user only"
fi

if [[ -n "$CA_CERT" ]]; then
    echo "CA Cert    : $CA_CERT"
else
    echo "CA Cert    : Disabled"
fi

echo

#
# Remove existing profile
#
if nmcli connection show "$CON_NAME" >/dev/null 2>&1; then
    info "Removing existing connection profile..."
    nmcli connection delete "$CON_NAME" >/dev/null
fi

#
# Create connection
#
info "Creating connection profile..."

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
# Enterprise defaults
#
nmcli connection modify "$CON_NAME" \
    wifi-sec.key-mgmt wpa-eap \
    802-1x.eap peap \
    802-1x.phase2-auth mschapv2 \
    802-1x.identity "$IDENTITY" \
    802-1x.password "$PASSWORD" \
    802-11-wireless.mac-address-randomization never

#
# Certificate handling
#
if [[ -n "$CA_CERT" ]]; then
    nmcli connection modify \
        "$CON_NAME" \
        802-1x.ca-cert "$CA_CERT"
else
    nmcli connection modify \
        "$CON_NAME" \
        802-1x.system-ca-certs no
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