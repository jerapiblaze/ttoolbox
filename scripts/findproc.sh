#!/usr/bin/bash
#!/usr/bin/zsh
#!/usr/bin/sh

if [[ $1 == "" ]]; then
    echo "Usage: $0 <find criteria>"
    echo "Example: $0 python, $0 xrdp, $0 6769"
    exit 1;
fi
ps -ef | grep $@;