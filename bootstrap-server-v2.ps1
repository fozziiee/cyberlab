
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
$gitFlag = "$cyberlabPath\git_installed.flag"
$adFlag = "C:\domain.promoted"
$rebootFlag = "$tempPath\after-reboot.flag"
$restartedFlag = "$cyberlabPath\restarted_after_git.flag"


# ===== Ensure Required Folders ==========
New-Item -ItemType Directory -Force -Path $tempPath, $cyberlabPath | Out-Null


# ========== Enable WinRM ==========================
Set-Item -Path "WSMan:\localhost\Service\AllowUnencrypted" -Value true
Set-Item -Path "WSMan:\localhost\Service\Auth\Basic" -Value true
Enable-PSRemoting -Force


# ============= Install Git ============================
if (-not (StepCompleted $gitFlag)) {
    Write-Host "Downloading and Installing Git..."
    try {
        $gitInstaller = "C:\Temp\GitInstaller.exe"

        Invoke-WebRequest `
            -Uri "https://github.com/git-for-windows/git/releases/download/v2.45.1.windows.1/Git-2.45.1-64-bit.exe" `
            -OutFile $gitInstaller
        
        Start-Process -FilePath $gitInstaller -ArgumentList "/VERYSILENT", "/NORESTART" -Wait
        New-Item -ItemType File -Path $gitFlag -Force
    }
    catch {
        Write-Error "it install failed: $_"
        exit 1
    }
}

# ============ Restart Shell if FIrst Run After Git Install ===========

# if (-not (Test-Path $restartedFlag)) {
#     Write-Host "Git installed. Opening new terminal..."
#     New-Item -ItemType File -Path $restartedFlag -Force
#     Start-Process powershell.exe -ArgumentList "-ExecutionPolicy Bypass -File `"$bootstrapScriptPath`""
    
# }


# ==== Clone AD repo =============

$gitPath = "C:\Program Files\Git\cmd\git.exe"
if (-not (Test-Path $repoPath)) {
    try {
        & $gitPath clone "https://github.com/fozziiee/AD.git" $cyberlabPath
    }
    catch {
        Start-Sleep -Seconds 5
        & $gitPath clone "https://github.com/fozziiee/AD.git" $cyberlabPath
    }
}

# ============ Schedule AD Bootstrap Script ==================
$repoPath = "$cyberlabPath\AD"
$bootstrapADScriptPath = "$repoPath\code\bootstrap_ad.ps1"
$adTaskExists = Get-ScheduledTask -TaskName "RunPostADScript" -ErrorAction SilentlyContinue

if (-not $adTaskExists) {
    Write-Host "Creating scheduled task for AD bootstrap script..."
    $action = New-ScheduledTaskAction -Execute "Powershell.exe" -Argument "-ExecutionPolicy Bypass -File `"$bootstrapADScriptPath`" -Users 10 -Groups 3 -Admins 1"
    $trigger = New-ScheduledTaskTrigger -AtStartup
    Register-ScheduledTask -TaskName "RunPostADScript" -Action $action -Trigger $trigger -RunLevel Highest -User "SYSTEM"
}

# ============ Set Static IP ==============================
if (-not (Get-NetIPAddress -IPAddress "10.0.1.100" -ErrorAction SilentlyContinue)) {
    New-NetIPAddress -InterfaceAlias "Ethernet" -IPAddress 10.0.1.100 -PrefixLength 24 -DefaultGateway 10.0.1.1
    Set-DnsClientServerAddress -InterfaceAlias "Ethernet" -ServerAddresses 127.0.0.1
}

# ================= Install AD-Domain-Services ===========================
if (-not (Get-WindowsFeature AD-Domain-Services).Installed) {
    Write-Host "Installing AD DS Feature..."
    Install-WindowsFeature -Name AD-Domain-Services -IncludeManagementTools
}


# ======== Promote to Domain Controller ========================

# Set DNS suffix 
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" -Name "Domain" -Value "xyz.local"

# Verify Hostname resolution
$hostname = $env:COMPUTERNAME
if (-not (Test-Connection $hostname -Count 1 -Quiet)) {
    Write-Error "Hostname $hostname is not resolving. Check network/DNS config."
    exit 1
}

if (-not (StepCompleted $adFlag)) {
    $domain = "xyz.local"
    $safeModePassword = ConvertTo-SecureString "P@ssw0rd123" -AsPlainText -Force

    try {
        Write-Host "Promoting to Domain Controller for $domain..."
        Install-ADDSForest -DomainName $domain -SafeModeAdministratorPassword $safeModePassword -Force:$true
        New-Item -ItemType File -Path $adFlag -Force
        Write-Host "Domain promotion complete"
        Restart-Computer -Force
    }
    catch {
        Write-Error "Domain promotion failed: $_"
        Get-Content "C:\Windows\Debug\DcPromo.log" -Tail 50
        exit 1
    }

}

Write-Host "Bootstrap Complete"

Remove-Item $restartedFlag -Force -ErrorAction SilentlyContinue
Unregister-ScheduledTask -TaskName "RunPostADScript" -Confirm:$false

Stop-Transcript