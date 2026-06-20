# T-Toolbox

A toolbox for my everyday need.

## Install

Windows:

```powershell
Invoke-WebRequest "https://raw.githubusercontent.com/jerapiblaze/ttoolbox/refs/heads/main/install.ps1" -UseBasicParsing | iex
```

Linux:

```bash
curl -fsSL "https://raw.githubusercontent.com/jerapiblaze/ttoolbox/refs/heads/main/install.sh" | bash
```

## Update

Just use `git pull` to get latest updates. For automatic update, add the following line into your crontab.

```text
0 0 * * * cd /opt/ttoolbox && git fetch origin && git reset --hard origin/main
```

## Disclaimer

THE SOFTWARE IS PROVIDED “AS IS” AND WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. MISUSE OF THIS SOFTWARE COULD CAUSE SYSTEM INSTABILITY OR MALFUNCTION. THE AUTHOR SHALL NOT BE HELD LIABLE FOR ANY DAMAGES RESULTING FROM THE USE OF THIS SOFTWARE.
