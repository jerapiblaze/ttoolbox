<#
.SYNOPSIS
    Delays a specified power action (Shutdown, Restart, Sleep, Hibernate, etc.) by a given time or delay in seconds.

.DESCRIPTION
    This script allows you to schedule a power action with an optional delay or at a specific time.

.PARAMETER Action
    The power action to perform. Valid options are "Shutdown", "Restart", "Sleep", "Hibernate", "RestartToAdvanced", "RestartToFirmware", "Logoff", "Lock".

.PARAMETER Delay
    The delay in seconds before performing the action.

.PARAMETER Time
    The specific time to perform the action. Format should be recognizable by [datetime]::Parse().

.PARAMETER Force
    Forces the action (e.g., forces shutdown or restart).

.PARAMETER NoCountdown
    If specified, the countdown prompt will be skipped.
#>
param(
    [Parameter(Mandatory = $false)][ValidateSet("Shutdown", "Restart", "Sleep", "Hibernate", "RestartToAdvanced", "RestartToFirmware", "", "Logoff", "Lock")]
    [string]$Action = "",
    [Parameter(Mandatory = $false)]
    [int]$Delay = 0,
    [Parameter(Mandatory = $false)]
    [string]$Time = "",
    [Parameter(Mandatory = $false)]
    [switch]$Force = $false,
    [Parameter(Mandatory = $false)]
    [switch]$NoCountdown = $false
)

if ($Action -eq ""){
    Get-Help powerctl.ps1 -Detailed;
    exit
}

# Calculate delay in seconds if Time is provided
if ($Time -ne "") {
    try {
        $targetTime = [datetime]::Parse($Time)
        $currentTime = Get-Date
        $Delay = ($targetTime - $currentTime).TotalSeconds
        # if time if in the past, add 24 hours to schedule for next day
        if ($Delay -lt 0) {
            $targetTime = $targetTime.AddDays(1)
            $Delay = [math]::Max(0, ($targetTime - $currentTime).TotalSeconds)
        }
    }
    catch {
        throw "Invalid time format. Please provide a valid time."
    }
    Write-Output "Calculated delay: $Delay seconds until action [$Action] at $targetTime."
}

if ($Delay -lt 0) {
    throw "Delay must be a non-negative integer."
}

if ($Action -in @("Shutdown", "Restart", "Hibernate", "Sleep", "RestartToAdvanced", "RestartToFirmware")) {
    # Check if running as Administrator
    $isAdmin = ([Security.Principal.WindowsPrincipal] `
            [Security.Principal.WindowsIdentity]::GetCurrent()
    ).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

    if (-not $isAdmin) {
        throw "This action must be run as Administrator."
    }
}

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

if ($Delay -gt 0 -and -not $NoCountdown) {
    Start-SleepPrompt $Delay "Delaying action [$Action]..."
    switch ($Action) {
        "Sleep" { 
            # Check if psshutdown is available
            if (-not (Get-Command psshutdown -ErrorAction SilentlyContinue)) {
                throw "psshutdown command not found. Please ensure PsTools is installed and psshutdown is in your PATH."
            }
            # Check if modern standby is supported
            $modernStandby = (powercfg /a) -match "S0 Low Power Idle"
            if ($modernStandby) {
                Write-Output "Modern Standby is supported.";
                psshutdown -x -t 0;
                exit;
            } else {
                Write-Output "Modern Standby is not supported.";
                psshutdown -d -t 0;
                exit;
            }
        }
        "Hibernate" { 
            shutdown.exe /h;
            exit;
        }
        "Shutdown" { 
            if ($Force) {
                shutdown.exe /s /t 0 /f;
                exit;
            } else {
                shutdown.exe /s /t 0;
                exit;
            }
        }
        "Restart" { 
            if ($Force) {
                shutdown.exe /r /t 0 /f;
                exit;
            } else {
                shutdown.exe /r /t 0;
                exit;
            }
        }
        "RestartToAdvanced" { 
            shutdown.exe /r /o /t 0;
            exit;
        }
        "RestartToFirmware" { 
            shutdown.exe /r /fw /t 0;
            exit;
        }
        "Logoff" { 
            # Logoff the current user
            shutdown.exe /l /f;
            exit;
        }
        "Lock" { 
            # Lock the current user session
            rundll32.exe user32.dll,LockWorkStation;
            exit;
        }
    }
}
if ($Delay -gt 0 -and $NoCountdown) {
    Start-Sleep -Seconds $Delay
    switch ($Action) {
        "Sleep" { 
            throw "Sleep action is not supported with NoCountdown option.";
        }
        "Hibernate" { 
            throw "Hibernate action is not supported with NoCountdown option.";
        }
        "Shutdown" { 
            if ($Force) {
                shutdown.exe /s /t $Delay /f;
            } else {
                shutdown.exe /s /t $Delay;
            }
        }
        "Restart" { 
            if ($Force) {
                shutdown.exe /r /t $Delay /f;
            } else {
                shutdown.exe /r /t $Delay;
            }
        }
        "RestartToAdvanced" { 
            throw "RestartToAdvanced action is not supported with NoCountdown option.";
        }
        "RestartToFirmware" { 
            throw "RestartToFirmware action is not supported with NoCountdown option.";
        }
        "Logoff" { 
            throw "Logoff action is not supported with NoCountdown option.";
        }
        "Lock" { 
            throw "Lock action is not supported with NoCountdown option.";
        }
    }
}