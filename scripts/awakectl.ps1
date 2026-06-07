<#
.SYNOPSIS
Change PowerToys.Awake modes via command-line.
.DESCRIPTION
This PowerShell script change the modes of PowerToys.Awake.
.PARAMETER Action
Action to execute. Available actions: start, stop.
Start: start awake indefinitely
Stop: Off
.EXAMPLE
PS> ./awakectl.ps1 -Action start
.NOTES
Author: J12Tee | License: CC0
#>

param (
    [Parameter(Mandatory = $false)]
    [switch]$Help = $false,
    [Parameter(Mandatory = $false)]
    [string]$Action
)

if ($Help -or $Action -eq "") {
    Get-Help awakectl.ps1 -Detailed;
    return;
}

Write-Output "PowerToysAwake Control";

$ConfigFile = Join-Path $env:localappdata -ChildPath "Microsoft\PowerToys\Awake\settings.json";

Write-Output "👀 Reading config file $ConfigFile";

$Config = Get-Content -Path $ConfigFile -Raw | ConvertFrom-Json;

switch ($Action){
    "stop" {
        $Config.properties.mode = 0;
        break;
    }
    "start" {
        $Config.properties.mode = 1;
        break;
    }
    Default {
        throw "Invalid action $Action";
    }
}

Write-Output "✏️ Writing config to file"

$Config | ConvertTo-Json | Set-Content -Path $ConfigFile;

Write-Output "✅ Done."
