#!/usr/bin/bash
#!/usr/bin/zsh
#!/usr/bin/sh

COMPOSE_FILE="/opt/ttoolbox/docker/lazydocker.compose.yaml"
if [ "$1" == "--build" ]; then
    docker compose -f "$COMPOSE_FILE" build
    exit;
fi
echo "Alternatively, use \`d4s\` for better experience."
if [ "$(id -u)" -eq 0 ]; then
    echo "Running lazydocker as root user. Using /root/lazydocker/config for config."
    if [ ! -d "/root/lazydocker/config" ]; then
        mkdir -p /root/lazydocker/config
    fi
    docker compose -f "$COMPOSE_FILE" up -d && docker attach lazydocker && docker compose -f "$COMPOSE_FILE" down
    exit;
else
    echo "Running lazydocker as non-root user. Using $HOME/.config/lazydocker for config."
    cp /opt/ttoolbox/docker/lazydocker.compose.yaml /tmp/lazydocker.compose.yaml
    sed -i "s|/root/lazydocker/config|$HOME/.config/lazydocker|g" /tmp/lazydocker.compose.yaml
    if [ ! -d "$HOME/.config/lazydocker" ]; then
        mkdir -p "$HOME/.config/lazydocker"
    fi
    docker compose -f /tmp/lazydocker.compose.yaml up -d && docker attach lazydocker && docker compose -f /tmp/lazydocker.compose.yaml down
    rm -f /tmp/lazydocker.compose.yaml
    exit;
fi