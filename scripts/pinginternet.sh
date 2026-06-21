#!/usr/bin/env bash
#!/usr/bin/env zsh

ts=$(date -u)
cs=$(nmcli -t -f CONNECTIVITY general 2>/dev/null)
cn=$(nmcli -t --fields NAME --colors no --mode tabular c show --active 2>/dev/null | head -n 1)
cd=$(nmcli -t --fields DEVICE --colors no --mode tabular c show --active 2>/dev/null | head -n 1)
ca=$(nmcli -g IP4.ADDRESS device show $cd 2>/dev/null)
cg=$(nmcli -g IP4.GATEWAY device show $cd 2>/dev/null)
cq=$(nmcli -f IN-USE,SIGNAL,SSID device wifi | awk '/^\*/{if (NR!=1) {print $2}}')
rs=$(curl -sL https://j12tee.qzz.io/ipcheck/json)

echo "$ts; $cs; $cd; $cn; $cq; $ca; $cg; $rs"