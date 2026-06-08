param (
    [Parameter(Mandatory = $false)]
    [string]$Action,
    [Parameter(Mandatory = $false)]
    [int]$Time = 0,
    [Parameter(Mandatory = $false)]
    [switch]$Help
)

if ($Help -or ($Action -eq "")) {
    Get-Help teectl.ps1 -Detailed
    return;
}

Write-Output "TeeCtl"

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
    ghelperctl -FanMode silent;
    awakectl -Action stop;
}

function Set-SleepMode {
    Set-DimMode;
    Start-SleepPrompt 60 "Delaying to provide G-Helper time to start. Hit anykey to skip waiting." -AllowInterrupt
    psshutdown -x -t 0;
}

function Set-AwakeMode {
    ghelperctl -FanMode balanced;
    awakectl -Action start;
}

function Set-MoveMode {
    psshutdown -d -t 0;
}

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