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

Just use `git` to get latest updates. Remember to add execute permissions to the scripts. For automatic updates (fetch, merge, clean up and file permission handling), use the included update scripts.

```bash
ttoolbox-update.sh
```

```powershell
ttoolbox-update.ps1
```

## Disclaimer

THE SOFTWARE IS PROVIDED “AS IS” AND WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. MISUSE OF THIS SOFTWARE COULD CAUSE SYSTEM INSTABILITY OR MALFUNCTION. THE AUTHOR SHALL NOT BE HELD LIABLE FOR ANY DAMAGES RESULTING FROM THE USE OF THIS SOFTWARE.
