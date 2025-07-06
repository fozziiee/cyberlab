
$ErrorActionPreference = "Stop"

# ===== Enable Logging =======
$logPath = "C:\cyberlab\bootstrap.log"
Start-Transcript -Path $logPath -Append

# ====== Helper: Flag Check ========
function StepCompleted($flag) {
    return (Test-Path $flag)
}

# === Path =====
$tempPath = "C:\Temp"
$cyberlabPath = "C:\cyberlab"
$bootstrapScriptPath = "C:\bootstrap.ps1"
$netFlag = "$cyberlabPath\net_installed.flag"
$chocoFlag = "$cyberlabPath\choco_installed.flag"
$gitFlag = "$cyberlabPath\git_installed.flag"
$adFlag = "C:\domain.promoted"
$rebootFlag = "$tempPath\after-reboot.flag"

# ===== Ensure Required Folders ==========
New-Item -ItemType Directory -Force -Path $tempPath, $cyberlabPath | Out-Null

# ======== Resume Script Task ===========================
$taskExists = Get-ScheduledTask -TaskName "ResumeBootstrap" -ErrorAction SilentlyContinue

if (-not $taskExists) {
    Write-Host "Registering startup task to resume bootstrap script..."
    $action = New-ScheduledTaskAction -Execute "Powershell.exe" -Argument "-ExecutionPolicy Bypass -File `"$bootstrapScriptPath`""
    $trigger = New-ScheduledTaskTrigger -AtStartup
    Register-ScheduledTask -TaskName "ResumeBootstrap" -Action $action -Trigger $trigger -RunLevel Highest -User "SYSTEM"
}

# ========== Enable WinRM ==========================
Set-Item -Path "WSMan:\localhost\Service\AllowUnencrypted" -Value true
Set-Item -Path "WSMan:\localhost\Service\Auth\Basic" -Value true
Enable-PSRemoting -Force

# ============== .NET 4.8 Install ======================

if (-not (StepCompleted $netFlag)) {
    try {
        Write-Host "Installing .NET 4.8..."
        $netInstaller = "$tempPath\ndp48.exe"
        Invoke-WebRequest `
            -Uri "https://download.visualstudio.microsoft.com/download/pr/2d6bb6b2-226a-4baa-bdec-798822606ff1/8494001c276a4b96804cde7829c04d7f/ndp48-x86-x64-allos-enu.exe" `
            -OutFile $netInstaller
        Start-Process $netInstaller -ArgumentList "/quiet /norestart" -Wait
        
        New-Item -ItemType File -Path $rebootFlag -Force
        New-Item -ItemType File -Path $netFlag -Force
        Write-Host "Rebooting to Complete .NET installation..."
        Stop-Transcript
        Restart-Computer -Force
        exit
    }
    catch {
        Write-Error ".NET install failed: $_"
    }
}

if (StepCompleted $netFlag) {
    Start-Transcript -Path $logPath -Append
}

# ============ Install Chocolatey =======================
if (-not (StepCompleted $chocoFlag)) {
    try {
        Write-Host "Installing Chocolatey..."
        Set-ExecutionPolicy Bypass -Scope Process -Force
        Invoke-WebRequest "https://chocolatey.org/install.ps1" -UseBasicParsing | iex
        New-Item -ItemType File -Path $chocoFlag -Force
    }
    catch {
        Write-Error "Chocolatey install failed: $_"
        exit 1
    }
}

# ============= Install Git ============================
if (-not (StepCompleted $gitFlag)) {
    try {
        choco install git -y
        New-Item -ItemType File -Path $gitFlag -Force
    }
    catch {
        Write-Error "it install failed: $_"
    }
}


# ==== Clone AD repo =============
if (-not (Test-Path "$cyberlabPath\AD")) {
    git clone "https://github.com/fozziiee/AD.git" "C:\cyberlab"
}

# ============ Schedule AD Bootstrap Script ==================
$bootstrapADScriptPath = "$cyberlabPath\AD\code\bootstrap_ad.ps1"
$taskExists = Get-ScheduledTask -TaskName "RunPostADScript" -ErrorAction SilentlyContinue

if (-not $taskExists) {
    Write-Host "Creating scheduled task for AD bootstrap script..."
    $action = New-ScheduledTaskAction -Execute "Powershell.exe" -Argument "-ExecutionPolicy Bypass -File `"$bootstrapADScriptPath`" -Users 10 -Groups 3 -Admins 1"
    $trigger = New-ScheduledTaskTrigger -AtStartup
    Register-ScheduledTask -TaskName "RunPostADScript" -Action $action -Trigger $trigger -RunLevel Highest -User "SYSTEM"
}

# ============ Set Static IP ==============================
New-NetIPAddress -InterfaceAlias "Ethernet" -IPAddress 10.0.1.100 -PrefixLength 24 -DefaultGateway 10.0.1.1
Set-DnsClientServerAddress -InterfaceAlias "Ethernet" -ServerAddresses 127.0.0.1


# ======== Promote to Domain Controller ========================    
if (-not (StepCompleted $adFlag)) {
    $domain = "xyz.local"
    $safeModePassword = ConvertTo-SecureString "P@ssw0rd123" -AsPlainText -Force

    try {
        Write-Host "Promoting to Domain Controller for $domain..."
        Install-ADDSForest -DomainName $domain -SafeModeAdministratorPassword $safeModePassword -Force:$true
        New-Item -ItemType File -Path $adFlag -Force
        Write-Host "Domain promotion complete"
    }
    catch {
        Write-Error "Domain promotion failed: $_"
        exit 1
    }

}

Write-Host "Bootstrap Complete"

Unregister-ScheduledTask -TaskName "ResumeBootstrap" -Confirm:$false
Unregister-ScheduledTask -TaskName "RunPostADScript" -Confirm:$false

Stop-Transcript