#!/usr/bin/bash
#!/usr/bin/zsh
#!/usr/bin/sh

# Check if keychain is installed
if ! command -v keychain &> /dev/null; then
    echo "keychain is not installed. Please install it to use this script."
    exit 1
fi
eval $(keychain --eval --quiet --agents ssh)