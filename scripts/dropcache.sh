#!/usr/bin/bash
#!/usr/bin/zsh
#!/usr/bin/sh

# Script to drop system caches and reset swap
# Usage: ./dropcache.sh --[swap|cache|all] (default: all)

# Use sudo to execute the script with elevated privileges
# Make use of sudo session caching to avoid repeated password prompts
sudo -v
sudo sh -c "echo Starting cache drop process"

function drop_cache(){
    sudo sh -c "echo Dropping caches"
    sudo sh -c "sync; echo 3 > /proc/sys/vm/drop_caches"
    sudo sh -c "echo Caches dropped"
}


function drop_swap(){
    sudo sh -c "echo Dropping Swap"
    if swapon --show | grep -q '/dev/zram'; then
        sudo swapoff -a
        sudo systemctl restart zram-config
        sudo swapon -a
    else
        sudo swapoff -a
        sudo swapon -a
    fi
}

function main(){
    case "$1" in
        --swap)
            drop_swap
            ;;
        --cache)
            drop_cache
            ;;
        --all|"" )
            drop_swap
            drop_cache
            ;;
        *|"-h"|--help)
            echo "Usage: sudo ./dropcache.sh --[swap|cache|all] (default: all)"
            exit 1
            ;;
    esac
}

main "$1"