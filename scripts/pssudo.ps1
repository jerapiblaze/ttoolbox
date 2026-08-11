<#
.SYNOPSIS
    Wrapper around new sudo of windows to allow for elevation of privileges in PowerShell scripts.

.DESCRIPTION
    This script is designed to be used in conjunction with the `pssudo` module, which provides a way to run commands with elevated privileges.
    For advanced usage, use the `sudo` command directly.

.EXAMPLE
    pssudo.ps1 commands
#>

$command = $args -join " "
Write-Output "Executing command with elevated privileges: $command"
sudo powershell -c "$command"