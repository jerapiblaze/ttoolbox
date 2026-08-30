#!/usr/bin/env bash
#!/usr/bin/env zsh

echo "----------------------------------------"
echo "Host   : $(hostname)"
echo "Time   : $(date)"
echo "----------------------------------------"
echo "Uptime : $(uptime -p)"
echo "Load   : $(uptime | awk -F'load average:' '{ print $2 }' | xargs)"
echo "CPU    : $(top -bn1 | grep "Cpu(s)" | awk '{print $2 + $4 "%"}')"
echo "RAM    : $(free -h | grep 'Mem' | awk '{print $3 "/" $2}')"
echo "Swap   : $(free -h | grep 'Swap' | awk '{print $3 "/" $2}')"
echo "Disk   : $(df -h / | grep '/' | awk '{print $3 "/" $2}')"
echo "----------------------------------------"
