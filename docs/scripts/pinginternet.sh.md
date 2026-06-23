# PingInternet - The story

Another place, another rules. The network at TCD auto-disconnects if there is no active traffic for a while. So this script is used to "generate" some *countable* traffic (HTTP requests) to avoid being disconnected.

By default, the script request for public IP information, as seen from [my Cloudflare worker](https://tapi.j12tee.qzz.io).

In my experiments, it must run for every 3 minutes.

Config in crontab of `root`:

```txt
*/3 * * * * /opt/ttoolbox/scripts/pinginternet.sh >> /var/log/pinginternet.txt
```

And remeber to use `logrotate` to avoid the file `/var/log/pinginternet.txt` becoming a disk space killer.

Config in `/etc/logrotate.d/pinginternet`:

```txt
# pinginternet -- cleanup every 3 days
/var/log/pinginternet.txt
    missingok
    daily
    create 660 root root
    compress
    delaycompress
    rotate 7
```