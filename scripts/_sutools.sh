#!/bin/bash
#!/bin/zsh
# ==========================================================================
# Filename: SUPERUSER.sh
# Author: J12T
# Description: 
# This script contains definitions of bash/zsh functions that I used a lot. 
# Useful for home-server admins.
# How to use:
# Append contents in this file in to .bashrc or .zshrc file.
# ==========================================================================

# Name: pfind (process find)
# Description: Find the process by any criteria: name, command, user, pid,...
# Example: pfind python, pfind xrdp
function pfind(){ ps -ef | grep $@; }

# Name: killxrdpsession (Kill xrdp session)
# Description: Kill the active xrdp session of an user
# Require: sudo/root privilege
# Example: killxrdpsession j12t, killxrdpsession stu0
function killxrdpsession(){ ps u -u "$1" | awk '/xrdp/ && ! /awk / {system("sudo kill "$2)}' }

# Name: rebootrequired Debian
# Description: Check if a reboot is required in Debian, useful in scripts
function rebootrequired-deb(){ if [ -f /var/run/reboot-required ]; then echo 1; else echo 0; fi}

# Name: rebootrequired RHEL
# Description: Check if a reboot is required in RHEL, useful in scripts
# Require: yum-utils is installed
function rebootrequired-rhel(){ needs-restarting -r -q > /dev/null; echo $?; }

# Name: StartSSHAgent
# Description: Use keychain to store ssh-agent across sessions
# Require: keychain
eval $(keychain --eval --quiet --agents ssh)
