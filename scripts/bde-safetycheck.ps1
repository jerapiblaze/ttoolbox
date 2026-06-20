<#
.SYNOPSIS
Check BitLocker state and keys backup.
.DESCRIPTION
This PowerShell script checks if BitLocker is enabled and the keys is backed up online.
.NOTES
Author: J12Tee | License: CC0
#>

Write-Output "You MUST allow UAC to continue..."

# Self-elevate
if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] 'Administrator')) {
    Start-Process -FilePath PowerShell.exe -Verb Runas -ArgumentList "-File `"$($MyInvocation.MyCommand.Path)`"  `"$($MyInvocation.MyCommand.UnboundArguments)`""
    Exit
}

function Get-BitLockerBackupInfo {
    param(
        [Parameter(Mandatory=$true)]
        [string]$Drive
    )

    # Capture manage-bde output
    $output = (manage-bde -protectors -get $Drive 2>$null)
    $status_output = (manage-bde -status $Drive 2>$null)
    if (-not $output) {
        return [PSCustomObject]@{
            DriveLetter = $Drive
            IsEnabled   = $false
            BackupType  = $null
            DriveId     = $null
        }
    }

    # Join lines to handle multi-line ID blocks
    $text = $output -join "`n"

    # Extract Numerical Password protector block
    $numBlock = ($text -split "Numerical Password:")[1]

    if (-not $numBlock) {
        return [PSCustomObject]@{
            DriveLetter = $Drive
            IsEnabled   = [bool]( ($status_output -join "`n") -match 'Protection Status:\s*Protection On' -or ($status_output -join "`n") -match 'Protection Status:\s*Unknown' )
            BackupType  = $null
            DriveId     = $id
        }
    }

    # Extract ID (handles multi-line IDs)
    $idMatch = [regex]::Match($numBlock, 'ID:\s*{([^}]*)}')
    $id = if ($idMatch.Success) { $idMatch.Groups[1].Value.Trim() } else { $null }

    # Extract backup type
    $backupMatch = [regex]::Match($numBlock, 'Backup type:\s*(.+)')
    $backup = if ($backupMatch.Success) { $backupMatch.Groups[1].Value.Trim() } else { $null }

    # Determine if BitLocker is enabled
    $is_enabled = [bool]( ($status_output -join "`n") -match 'Protection Status:\s*Protection On' -or ($status_output -join "`n") -match 'Protection Status:\s*Unknown' )

    return [PSCustomObject]@{
        DriveLetter = $Drive
        IsEnabled   = $is_enabled
        BackupType  = $backup
        DriveId     = $id
    }
}



# Get all fixed drives
$FixedDrives = [System.IO.DriveInfo]::getdrives() | Where-Object { $_.DriveType -eq 'Fixed' }

Write-Output "BitLocker Drive Encryption -- Safety Check"

$is_danger = $false
$is_attention_needed = $false
foreach ($drive in $FixedDrives){
    $driveletter = Split-Path $drive.RootDirectory -Qualifier
    
    $checkresult = Get-BitLockerBackupInfo $driveletter
    if ($checkresult.IsEnabled -eq $true){
        if ($null -eq $checkresult.BackupType){
            $is_danger = $true
        }
        if ($checkresult.BackupType -eq 'Saved to file'){
            $is_attention_needed = $true
        }
    }
    Write-Output $checkresult
}

if ($is_danger){
    Write-Host "You should backup keys!" -ForegroundColor Red
} elseif ($is_attention_needed) {
    Write-Host "Local file save detected. You should have the file backed up." -ForegroundColor Yellow
} else {
    Write-Host "All good." -ForegroundColor Green
}

Write-Host "Press any key to continue..."
[System.Console]::ReadKey() > $null