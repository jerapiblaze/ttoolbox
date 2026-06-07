param (
    [string]$Action="install",
    [string]$InstallPath="C:\",
    [switch]$User
)

$GitRepo = "https://github.com/jerapiblaze/ttoolbox.git"

if (-not $User){
    # Check if the current PowerShell session is running as Administrator
    try {
        $currentUser = [Security.Principal.WindowsIdentity]::GetCurrent()
        $principal = New-Object Security.Principal.WindowsPrincipal($currentUser)

        if ($principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
            Write-Host "✅ The script is running as Administrator." -ForegroundColor Green
        }
        else {
            Write-Host "❌ The script is NOT running as Administrator. Try to use -User flag." -ForegroundColor Red
        }
    }
    catch {
        Write-Host "⚠️ Error checking admin rights: $($_.Exception.Message)" -ForegroundColor Yellow
        return 1;
    }
}

if ($Action -eq "Install") {
    # Install the application
    Write-Host "Installing the application..."
    # Clone the Git repository
    git clone $GitRepo $InstallPath
    # Add to path
    $script_path = Join-Path $InstallPath -ChildPath "scripts"
    if ($User){
        [Environment]::SetEnvironmentVariable(
            "Path",
            "$env:Path;$script_path",
            "User"
        )
    } else {
        [Environment]::SetEnvironmentVariable(
            "Path",
            "$env:Path;$script_path",
            "Machine"
        )
    }
    return 0;
} else {
    Write-Host "Invalid action. Please specify either 'Install' or 'Uninstall'.";
    return 0;
}