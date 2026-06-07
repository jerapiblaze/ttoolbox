# Autosuggestions
function IsVirtualTerminalProcessingEnabled {
    $MethodDefinitions = @'
[DllImport("kernel32.dll", SetLastError = true)]
public static extern IntPtr GetStdHandle(int nStdHandle);
[DllImport("kernel32.dll", SetLastError = true)]
public static extern bool GetConsoleMode(IntPtr hConsoleHandle, out uint lpMode);
'@
    $Kernel32 = Add-Type -MemberDefinition $MethodDefinitions -Name 'Kernel32' -Namespace 'Win32' -PassThru
    $hConsoleHandle = $Kernel32::GetStdHandle(-11) # STD_OUTPUT_HANDLE
    $mode = 0
    $Kernel32::GetConsoleMode($hConsoleHandle, [ref]$mode) >$null
    if ($mode -band 0x0004) {
        # 0x0004 ENABLE_VIRTUAL_TERMINAL_PROCESSING
        return $true
    }
    return $false
}

function CanUsePredictionSource {
    return (! [System.Console]::IsOutputRedirected) -and (IsVirtualTerminalProcessingEnabled)
}

if (CanUsePredictionSource) { 
    Import-Module -Name Terminal-Icons
    Import-Module PSReadLine
    Set-PSReadLineOption -PredictionViewStyle ListView -PredictionSource History -HistoryNoDuplicates
    Set-PSReadLineOption -Colors @{ InlinePrediction = '#9CA3AF' }
    # Shows navigable menu of all options when hitting Tab
    Set-PSReadlineKeyHandler -Key Tab -Function MenuComplete
    # Autocompletion for arrow keys
    Set-PSReadlineKeyHandler -Key UpArrow -Function HistorySearchBackward
    Set-PSReadlineKeyHandler -Key DownArrow -Function HistorySearchForward
    Set-PSReadLineOption -Colors @{
        #Command = 'Green'
        Parameter = 'Blue'
        #Variable = 'Red'
        Operator  = 'Red'
    }
}

# Better conda
$Env:CONDA_EXE = "~\miniconda3\Scripts\conda.exe"
$Env:_CE_M = ""
$Env:_CE_CONDA = ""
$Env:_CONDA_ROOT = "~\miniconda3"
$Env:_CONDA_EXE = "~\miniconda3\Scripts\conda.exe"
$Env:CONDA_ENVS_PATH = "~\.conda\envs"
$Env:CONDA_PKGS_DIRS = "~\.conda\pkgs"
$CondaModuleArgs = @{ChangePs1 = $True; }
Import-Module "$Env:_CONDA_ROOT\shell\condabin\Conda.psm1" -ArgumentList $CondaModuleArgs

Remove-Variable CondaModuleArgs

# Function to get shortcut details
function Get-ShortcutDetails {
    param (
        [Parameter(Mandatory = $true)]
        [string]$ShortcutPath
    )

    # Check if the file exists
    if (-Not (Test-Path -Path $ShortcutPath)) {
        Write-Error "The specified shortcut file does not exist: $ShortcutPath"
        return
    }

    # Create a COM object for the shortcut
    try {
        $Shell = New-Object -ComObject WScript.Shell
        $Shortcut = $Shell.CreateShortcut($ShortcutPath)

        # Display shortcut details
        Write-Output $Shortcut
    }
    catch {
        Write-Error "Failed to retrieve shortcut details: $_"
    }
}

# Function to start app
function Launch-Application {
    param (
        [switch]$list = $false,
        [switch]$verbose = $false
    )

    if ($args[0] -ne $null) {
        $appItem = get-StartApps -Name $args[0]
        $appId = Write-Output $appItem | Select AppID -ExpandProperty AppID
        $appName = Write-Output $appItem | Select Name -ExpandProperty Name

        if ($verbose) {
            Write-Output "AppName        : $($appName)"
            Write-Output "AppId          : $($appID)"
            Write-Output "LaunchFilePath : shell:AppsFolder\$($appId)"
            Write-Output "LaunchParams   : $($args[1..$args.Length])"
        }

        if ($appId -eq $null) {
            Write-Output "Application not found"
            return
        }

        if ($args[1] -eq $null) {
            Start-Process -FilePath "shell:AppsFolder\$appId" 
        }
        else {
            Start-Process -FilePath "shell:AppsFolder\$appId" $args[1..$args.Length]
        }

        return
    }

    if ($list) {
        get-StartApps | select Name -ExpandProperty Name
        return
    }

    Write-Output "Usage: launch.ps1 ApplicationName|[-list]" 
    Write-Output ""
    Write-Output "  -list     List all applications found in shell:appsFolder"
    Write-Output "  -verbose  Verbose logging"
    Write-Output "  ApplicationName     Launch the application"
    Write-Output ""
}

# oh-my-posh
if (! [System.Console]::IsOutputRedirected) {
    oh-my-posh init pwsh --config "$env:POSH_THEMES_PATH\ys.omp.json" | Invoke-Expression;
}

clear;