#!/usr/bin/env bash
#!/usr/bin/env zsh

cd /opt/ttoolbox && git fetch --depth=1 origin && git reset --hard origin/main && chmod +rx scripts/*