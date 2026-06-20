#/bin/bash
#/bin/zsh

ts=$(date -u)
rs=$(curl -sL https://j12tee.qzz.io/ipcheck/json)

echo "$ts, $rs"