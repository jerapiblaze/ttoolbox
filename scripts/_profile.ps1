# Exit early for non-interactive hosts to keep startup fast
if ($Host.Name -notin 'ConsoleHost','Windows Terminal Host','WindowsTerminalHost','Visual Studio Code Host') {
    return
}

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
    $Kernel32::GetConsoleMode($hConsoleHandle, [ref]$mode) > $null
    return ($mode -band 0x0004) -ne 0
}

function CanUsePredictionSource {
    if ([System.Console]::IsOutputRedirected) {
        return $false
    }

    if ($Host.UI) {
        $supportsVT = $Host.UI.PSObject.Properties['SupportsVirtualTerminal'] -and $Host.UI.SupportsVirtualTerminal
        if ($supportsVT) {
            return $true
        }
    }

    return (IsVirtualTerminalProcessingEnabled)
}

if (CanUsePredictionSource) {
    if (-not (Get-Module -Name PSReadLine)) {
        Import-Module PSReadLine -ErrorAction SilentlyContinue
    }

    if ((Get-Module -ListAvailable -Name Terminal-Icons) -and -not (Get-Module -Name Terminal-Icons)) {
        Import-Module Terminal-Icons -ErrorAction SilentlyContinue
    }

    Set-PSReadLineOption -PredictionViewStyle ListView -PredictionSource History -HistoryNoDuplicates
    Set-PSReadLineOption -Colors @{ InlinePrediction = '#9CA3AF' }
    Set-PSReadlineKeyHandler -Key Tab -Function MenuComplete
    Set-PSReadlineKeyHandler -Key UpArrow -Function HistorySearchBackward
    Set-PSReadlineKeyHandler -Key DownArrow -Function HistorySearchForward
    Set-PSReadLineOption -Colors @{ Parameter = 'Blue'; Operator = 'Red' }
}

# Better conda
$Env:CONDA_ROOT = Join-Path $HOME 'miniconda3'
$Env:CONDA_EXE = Join-Path $Env:CONDA_ROOT 'Scripts\conda.exe'
$Env:_CE_M = ''
$Env:_CE_CONDA = ''
$Env:CONDA_ENVS_PATH = Join-Path $HOME '.conda\envs'
$Env:CONDA_PKGS_DIRS = Join-Path $HOME '.conda\pkgs'

$CondaModulePath = Join-Path $Env:CONDA_ROOT 'shell\condabin\Conda.psm1'
if (Test-Path $CondaModulePath) {
    $CondaModuleArgs = @{ ChangePs1 = $True }
    Import-Module $CondaModulePath -ArgumentList $CondaModuleArgs -ErrorAction SilentlyContinue
    Remove-Variable CondaModuleArgs -ErrorAction SilentlyContinue
}

# Function to get shortcut details
function Get-ShortcutDetails {
    param (
        [Parameter(Mandatory = $true)]
        [string]$ShortcutPath
    )

    if (-Not (Test-Path -Path $ShortcutPath)) {
        Write-Error "The specified shortcut file does not exist: $ShortcutPath"
        return
    }

    try {
        $Shell = New-Object -ComObject WScript.Shell
        $Shortcut = $Shell.CreateShortcut($ShortcutPath)
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

    Write-Output "Usage: launch.ps1 ApplicationName|[-list]"
    Write-Output ''
    Write-Output '  -list     List all applications found in shell:appsFolder'
    Write-Output '  -verbose  Verbose logging'
    Write-Output '  ApplicationName     Launch the application'
    Write-Output ''
}

# oh-my-posh prompt initialization
if (-not [System.Console]::IsOutputRedirected -and (Get-Command oh-my-posh -ErrorAction SilentlyContinue)) {
    $themeDir = if ([string]::IsNullOrWhiteSpace($Env:POSH_THEMES_PATH)) {
        'C:\Program Files\WindowsApps\ohmyposh.cli_29.14.0.0_x64__96v55e8n804z4\themes'
    }
    else {
        $Env:POSH_THEMES_PATH
    }

    $themeFile = Join-Path $themeDir 'ys.omp.json'
    if (Test-Path $themeFile) {
        oh-my-posh init pwsh --config $themeFile | Invoke-Expression
    }
    else {
        oh-my-posh init pwsh | Invoke-Expression
    }
}