#!/usr/bin/bash
#!/usr/bin/zsh
#!/usr/bin/sh

if [[ $EUID -ne 0 ]]; then
    echo "Please run this script as root."
    exit 1;
fi
if [[ $# -ne 1 ]]; then
    echo "Usage: $0 <username>"
    exit 1;
fi
echo ">>> Killing xrdp session for user: $1"
ps u -u "$1" | awk '/xrdp/ && ! /awk / {system("sudo kill "$2)}'