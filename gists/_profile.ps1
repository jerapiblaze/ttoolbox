# notepad $profile.CurrentUserAllHosts
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
    if ([System.Console]::IsOutputRedirected) { return $false }
    if ($Host.UI -and $Host.UI.SupportsVirtualTerminal) { return $true }
    return (IsVirtualTerminalProcessingEnabled)
}

if (CanUsePredictionSource) {
    Import-Module PSReadLine -ErrorAction SilentlyContinue
    Import-Module Terminal-Icons -ErrorAction SilentlyContinue

    Set-PSReadLineOption -PredictionViewStyle ListView -PredictionSource History -HistoryNoDuplicates -Colors @{ InlinePrediction = '#9CA3AF'; Parameter = 'Blue'; Operator = 'Red' }
    Set-PSReadlineKeyHandler -Key Tab -Function MenuComplete
    Set-PSReadlineKeyHandler -Key UpArrow -Function HistorySearchBackward
    Set-PSReadlineKeyHandler -Key DownArrow -Function HistorySearchForward
}

# Conda setup (lazy-load only if conda exists)
$condaRoot = Join-Path $HOME 'miniconda3'
if (Test-Path (Join-Path $condaRoot 'Scripts\conda.exe')) {
    $Env:CONDA_ROOT = $condaRoot
    $Env:CONDA_EXE = Join-Path $condaRoot 'Scripts\conda.exe'
    $Env:_CE_M = ''
    $Env:_CE_CONDA = ''
    $Env:CONDA_ENVS_PATH = Join-Path $HOME '.conda\envs'
    $Env:CONDA_PKGS_DIRS = Join-Path $HOME '.conda\pkgs'

    $CondaModulePath = Join-Path $condaRoot 'shell\condabin\Conda.psm1'
    if (Test-Path $CondaModulePath) {
        Import-Module $CondaModulePath -ArgumentList @{ ChangePs1 = $True } -ErrorAction SilentlyContinue
    }
}

# oh-my-posh prompt initialization
if (-not [System.Console]::IsOutputRedirected -and (Get-Command oh-my-posh -ErrorAction SilentlyContinue)) {
    $themeDir = if ([string]::IsNullOrWhiteSpace($Env:POSH_THEMES_PATH)) { 'C:\Program Files\WindowsApps\ohmyposh.cli_29.14.0.0_x64__96v55e8n804z4\themes' } else { $Env:POSH_THEMES_PATH }
    $themeFile = Join-Path $themeDir 'ys.omp.json'
    if (Test-Path $themeFile) {
        oh-my-posh init pwsh --config $themeFile | Invoke-Expression
    }
    else {
        # oh-my-posh init pwsh | Invoke-Expression
        oh-my-posh init pwsh --config ys | Invoke-Expression
    }
}
