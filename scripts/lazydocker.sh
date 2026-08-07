#!/usr/bin/bash
#!/usr/bin/zsh
#!/usr/bin/sh

COMPOSE_FILE="../docker/lazydocker.compose.yaml"
if [ "$1" == "--build" ]; then
    docker compose -f "$COMPOSE_FILE" build
    exit;
fi
if [ ! -d "/root/lazydocker/config" ]; then
    mkdir -p /root/lazydocker/config
fi
docker compose -f "$COMPOSE_FILE" up -d && docker attach lazydocker && docker compose -f "$COMPOSE_FILE" down