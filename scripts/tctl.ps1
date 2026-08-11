<#
.SYNOPSIS
    Control various power and system modes.

.DESCRIPTION
    This script allows you to set different system modes such as dim, sleep, awake, and move.

.PARAMETER Action
    The action to perform. Valid options are "dim", "sleep", "awake", "move".

.PARAMETER PreservePowerMode
    If specified, preserves the current power mode when changing system modes.

.PARAMETER Time
    The delay time in seconds before performing the action.

.PARAMETER Help
    Displays this help message.
#>
param (
    [Parameter(Mandatory = $false)]
    [string]$Action,
    [parameter(Mandatory = $false)]
    [switch]$PreservePowerMode,
    [Parameter(Mandatory = $false)]
    [int]$Time = 0,
    [Parameter(Mandatory = $false)]
    [switch]$Help
)

if ($Help -or ($Action -eq "")) {
    Get-Help tctl.ps1 -Detailed
    return;
}

Write-Output "TeeCtl"
$oldTitle = $Host.UI.RawUI.WindowTitle
$Host.UI.RawUI.WindowTitle = "TeeCtl - $Action"

Function Start-SleepPrompt {
    param(
        [int]$seconds,
        [string]$text = "Waiting...",
        [switch]$AllowInterrupt
    )

    $s = 0

    while ($s -lt $seconds) {

        $p = [math]::Round(100 - (($seconds - $s) / $seconds * 100))
        Write-Progress -Activity $text -Status "$p% Complete:" -SecondsRemaining ($seconds - $s) -PercentComplete $p

        # Sleep in small chunks so we can detect keypress if enabled
        for ($i = 0; $i -lt 10; $i++) {
            Start-Sleep -Milliseconds 100

            if ($AllowInterrupt -and [Console]::KeyAvailable) {
                $null = [Console]::ReadKey($true)   # clear buffer
                Write-Progress -Activity $text -Completed
                return
            }
        }

        $s++
    }

    Write-Progress -Activity $text -Completed
}


if ($Time -gt 0) {
    Start-SleepPrompt $Time "Delaying action $Action..."
}

function Set-DimMode {
    if ($PreservePowerMode) {
        ghelperctl -FanMode keep -KbLed 1;
    } else {
        ghelperctl -FanMode silent -KbLed 1;
    }
    awakectl -Action stop;
}

function Set-SleepMode {
    if ($PreservePowerMode) {
        ghelperctl -FanMode keep -KbLed 0;
    } else {
        ghelperctl -FanMode silent -KbLed 0;
    }
    awakectl -Action stop;
    Start-SleepPrompt 60 "Delaying to provide G-Helper time to start. Hit anykey to skip waiting." -AllowInterrupt
    psshutdown -x -t 0;
}

function Set-AwakeMode {
    if ($PreservePowerMode) {
        ghelperctl -FanMode keep -KbLed 3;
    } else {
        ghelperctl -FanMode balanced -KbLed 3;
    }
    awakectl -Action start;
}

function Set-MoveMode {
    psshutdown -d -t 0;
}

try {
    switch ($Action) {
        "dim" {
            Set-DimMode;
            break;
        }
        "sleep" {
            Set-SleepMode;
            break;
        }
        "awake" {
            Set-AwakeMode;
            break;
        }
        "move" {
            Set-MoveMode;
            break;
        }
        Default {
            throw "Action $Action is not defined."
        }
    }
}
catch {
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
}
finally {
    $Host.UI.RawUI.WindowTitle = $oldTitle
}