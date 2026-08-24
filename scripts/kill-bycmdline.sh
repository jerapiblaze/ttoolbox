#!/usr/bin/bash
#!/usr/bin/zsh
#!/usr/bin/sh

if [[ $1 == "" ]]; then
    echo "Bulk kill processes by command line criteria"
    echo "Usage: $0 <find criteria>"
    echo "Example: $0 python, $0 xrdp, $0 6769"
    exit 1;
fi

for pid in /proc/[0-9]*; do
    cmdline=$(tr '\0' ' ' < "$pid/cmdline" 2>/dev/null)
    if [[ "$cmdline" == *$1* ]]; then
        kill -9 "${pid##*/}"
    fi
done