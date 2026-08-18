<#
.SYNOPSIS
    Launch a Windows application from the Start menu.

.DESCRIPTION
    This script allows you to launch a Windows application by its name, list all available applications, and enable verbose logging.

.PARAMETER list
    List all applications found in shell:AppsFolder.

.PARAMETER verbose
    Enable verbose logging.

.PARAMETER Help
    Display detailed help information.

.EXAMPLE
    .\launch-application.ps1 -list

.EXAMPLE
    .\launch-application.ps1 "Calculator"

#>
param (
    [switch]$list = $false,
    [switch]$verbose = $false,
    [switch]$Help = $false
)

if ($Help) {
    Get-Help launch-application.ps1 -Detailed
    exit
}

if ($null -ne $args[0]) {
    $appItem = get-StartApps -Name $args[0]
    $appId = Write-Output $appItem | Select-Object AppID -ExpandProperty AppID
    $appName = Write-Output $appItem | Select-Object Name -ExpandProperty Name

    if ($verbose) {
        Write-Output "AppName        : $($appName)"
        Write-Output "AppId          : $($appID)"
        Write-Output "LaunchFilePath : shell:AppsFolder\$($appId)"
        Write-Output "LaunchParams   : $($args[1..$args.Length])"
    }

    if ($null -eq $appId) {
        Write-Output "Application not found"
        return
    }

    if ($null -eq $args[1]) {
        Start-Process -FilePath "shell:AppsFolder\$appId"
    }
    else {
        Start-Process -FilePath "shell:AppsFolder\$appId" $args[1..$args.Length]
    }

    return
}

if ($list) {
    get-StartApps | Select-Object -ExpandProperty Name
    return
}