#!/usr/bin/env bash

# -----------------------------
# Parse arguments
# -----------------------------
Action="Install"
InstallPath="/opt"
UserFlag=0

while [[ $# -gt 0 ]]; do
    case "$1" in
        --Action|-a)
            Action="$2"
            shift 2
            ;;
        --InstallPath|-p)
            InstallPath="$2"
            shift 2
            ;;
        --User|-u)
            UserFlag=1
            shift
            ;;
        *)
            echo "Unknown argument: $1"
            exit 1
            ;;
    esac
done

GitRepo="https://github.com/jerapiblaze/ttoolbox.git"

# -----------------------------
# Admin check (Linux style)
# -----------------------------
if [[ $UserFlag -eq 0 ]]; then
    if [[ $EUID -eq 0 ]]; then
        echo "✅ The script is running as root."
    else
        echo "❌ The script is NOT running as root. Try using --User flag."
        return 1;
    fi
fi

add_to_all_rc() {
    local line="export PATH=\"\$PATH:$1\""

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
    local line="export PATH=\"\$PATH:$1\""

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


# -----------------------------
# Install action
# -----------------------------
if [[ "$Action" == "Install" ]]; then
    echo "Installing the application..."

    # Clone repo
    $clone_path = "$InstallPath/ttoolbox"
    git clone "$GitRepo" "$clone_path"

    script_path="$clone_path/scripts"

    chmod +x "$script_path/*"

    # -----------------------------
    # Add to PATH
    # -----------------------------
    if [[ $UserFlag -eq 1 ]]; then
        # User PATH
        add_to_all_rc "$script_path"
        echo "Added to user PATH."
    else
        # System PATH
        add_to_all_system_rc "$script_path"
        echo "Added to system PATH."
    fi
    echo "✅ Done. It is recommended to reload your current session enviromnent."
    exit 0
else
    echo "Invalid action. Please specify 'Install'."
    exit 0
fi
