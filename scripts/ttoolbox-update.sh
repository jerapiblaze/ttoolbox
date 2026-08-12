#!/usr/bin/env bash
#!/usr/bin/env zsh

# add -c flag to run check only mode

# Get the current script dir
script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ttoolbox_dir="$(cd "$script_dir/.." && pwd)"
cd "$ttoolbox_dir" || exit 1

CHECK_ONLY=false
while getopts "c" opt; do
    case $opt in
        c)
            CHECK_ONLY=true
            ;;
    esac
done
git fetch --depth=1 origin
if [ "$CHECK_ONLY" = true ]; then
    localCommit=$(git rev-parse HEAD)
    remoteCommit=$(git rev-parse origin/main)
    if [ "$localCommit" = "$remoteCommit" ]; then
        printf "\033[33mNo updates available.\n\033[0m" # Yellow
    else
        printf "\033[32mUpdates are available. Run this script without -c flag to update.\n\033[0m" # Green
    fi
    exit 0
fi
git reset --hard origin/main && chmod +rx scripts/*