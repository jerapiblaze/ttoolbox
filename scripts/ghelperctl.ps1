<#
.SYNOPSIS
Change GHelper modes via command-line.
.DESCRIPTION
This PowerShell script change the power mode and gpu mode of GHelper.
.PARAMETER FanMode
Specifies the name the fan mode. 
Default: Keep.
Available values: Keep/-1, Balanced/0, Turbo/1, Silent/2. Custom modes is not safely supported.
.PARAMETER GpuMode
Specifies the name the GPU mode. 
Default: Keep.
Available values: Keep, Standard, Eco, Ultimate.
.PARAMETER Force
Force restart GHelper.
.PARAMETER ConfigFile
Specifies the Path to the config file. Default: %AppData%/GHelper/config.json
.EXAMPLE
PS> ./ghelper-cli.ps1 -FanMode balanced
.EXAMPLE
PS> ./ghelper-cli.ps1 -GpuMode standard
.NOTES
Author: J12Tee | License: CC0
#>

param (
    [Parameter(Mandatory = $false)]
    [switch]$Help = $false,
    [Parameter(Mandatory = $false)]
    [string]$FanMode = "Keep",
    [Parameter(Mandatory = $false)]
    [string]$GpuMode = "Keep",
    [Parameter(Mandatory = $false)]
    [switch]$Force = $false,
    [Parameter(Mandatory = $false)]
    [string]$ConfigFile = ""
)

if ($Help) {
    Get-Help ghelper-cli.ps1 -Detailed;
    return;
}

Write-Output "GHelper-CLI";

switch ($FanMode) {
    "Balanced" {
        $FanMode = 0;
        break;
    }
    "Silent" {
        $FanMode = 2;
        break;
    }
    "Turbo" {
        $FanMode = 1;
        break;
    }
    "Keep" { 
        $FanMode = -1;
        break;
    }
    Default {
        try {
            $FanMode = [int16]$FanMode
        }
        catch [System.Exception] {
            throw "Invalid FanMode value of $FanMode!"
        }
    }
}

switch ($GpuMode) {
    "Standard" {
        $GpuMode = 0;
        break;
    }
    "Eco" {
        $GpuMode = 1;
        break;
    }
    "Ultimate" {
        $GpuMode = 2;
        break;
    }
    "Optimized" { 
        $GpuMode = 3;
        break;
    }
    "Keep" { 
        $GpuMode = -1;
        break;
    }
    Default {
        try {
            $GpuMode = [int16]$GpuMode;
        }
        catch [System.Exception] {
            throw "Invalid GpuMode value of $GpuMode!";
        }
        if ($GpuMode -notin @(-1, 0, 1, 2, 3)) {
            throw "GpuMode $GpuMode is not found in GHelper!";
        }
    }
}

function Edit-GHelperConfig {
    if ($ConfigFile -eq "") {
        $ConfigFile = Join-Path $env:APPDATA -ChildPath "GHelper/config.json";
    }
    Write-Output "👀 Reading config from $ConfigFile";
    $config = Get-Content -Path $ConfigFile -Raw | ConvertFrom-Json;
    if ($FanMode -ne -1) {
        Write-Output "🌀 Setting FanMode=$FanMode.";
        $config.performance_1 = $FanMode;
    }
    if ($GpuMode -ne -1) {
        Write-Output "❌ GHelper is not currently supports change GPU Mode via config!!!";
        # switch ($GpuMode) {
        #     0 {
        #         # standard
        #         $config.gpu_auto = 0;
        #         $config.gpu_mode = 1;
        #         break;
        #     }
        #     1 {
        #         # eco
        #         $config.gpu_auto = 0;
        #         $config.gpu_mode = 0;
        #         Write-Output "Hello";
        #         break;
        #     }
        #     2 {
        #         # ultimate
        #         break;
        #     }
        #     3 {
        #         # optimized
        #         $config.gpu_auto = 1;
        #         break;
        #     }
        # }
    }
    $config | ConvertTo-Json | Set-Content -Path $ConfigFile;
}

function Restart-GHelper {
    param (
    )
    $process = $false
    try {
        $process = Get-Process -Name "GHelper" -ErrorAction Stop;
    }
    catch [System.Exception] {
        Write-Output "👍 GHelper is not currently running!";
        $process = $false;
    }
    if ($process -ne $false) {
        $process_id = $process.Id;
        Write-Output "🛑 Stoping old GHelper process PID $process_id";
        Get-ScheduledTask -TaskName GHelper | Stop-ScheduledTask;
        while (Get-CimInstance Win32_Process -Filter "ProcessId=$process_id") {
            Write-Output "🕒 Waitng for GHelper to exit...";
            Start-Sleep -Milliseconds 1000;
        }
    }
    Write-Output "✏️ Writing new config file.";
    Edit-GHelperConfig;
    Write-Output "🟢 Starting GHelper";
    Get-ScheduledTask -TaskName GHelper | Start-ScheduledTask;
    while (-not (Get-CimInstance Win32_Process -Filter "Name='GHelper.exe'")) {
        Write-Output "🕒 Waitng for GHelper to start...";
        Start-Sleep -Milliseconds 1000;
    }
    Write-Output "✅ Done.";
}

if ($FanMode -eq -1 -and $GpuMode -eq -1) {
    Write-Output "Nothing changes.";
    if ($Force) {
        Restart-GHelper;
    }
    return;
}
else {
    Restart-GHelper;
    return;
}
