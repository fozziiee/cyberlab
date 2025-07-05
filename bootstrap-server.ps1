

$domain = "xyz.local"
$safeModePassword = ConvertTo-SecureString "P@ssw0rd123" -AsPlainText -Force
$bootstrapScriptPath = "C:\cyberlab\AD\code\bootstrap_ad.ps1"

# Enable WinRM
Set-Item -Path "WSMan:\localhost\Service\AllowUnencrypted" -Value true
Set-Item -Path "WSMan:\localhost\Service\Auth\Basic" -Value true
Enable-PSRemoting -Force


# Ensure the script directory exists
if (-not (Test-Path "C:\cyberlab")) {
    New-Item -Path "C:\cyberlab" -ItemType Directory -Force | Out-Null
}

# Ensure Git is installed
if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    Invoke-WebRequest -Uri "https://github.com/git-for-windows/git/releases/download/v2.42.0.windows.1/Git-2.42.0-64-bit.exe" `
        -OutFile "C:Windows\Temp\git-installer.exe"
    Start-Process "C:Windows\Temp\git-installer.exe" -ArgumentList "/VERYSILENT", "/NORESTART" -Wait
}

# Clone AD repo
if (-not (Test-Path "C:\cyberlab\AD")) {
    git clone "https://github.com/fozziiee/AD.git" "C:\cyberlab\AD"
}


# Schedule it to run on startup with args
$action = New-ScheduledTaskAction -Execute "Powershell.exe" -Argument "-ExecutionPolicy Bypass -File `"$bootstrapScriptPath`" -Users 10 -Groups 3 -Admins 1"
$trigger = New-ScheduledTaskTrigger -AtStartup
Register-ScheduledTask -TaskName "RunPostADScript" -Action $action -Trigger $trigger -RunLevel Highest -User "SYSTEM"

# Set to static IP address
New-NetIPAddress -InterfaceAlias "Ethernet" -IPAddress 10.0.1.100 -PrefixLength 24 -DefaultGateway 10.0.1.1
Set-DnsClientServerAddress -InterfaceAlias "Ethernet" -ServerAddresses 127.0.0.1

# Install AD DS if not already installed
if (-not (Get-WindowsFeature AD-Domain-Services).Installed) {
    Install-WindowsFeature -Name AD-Domain-Services -IncludeManagementTools
}

# Promote to DC if not already promoted 
if (-not (Test-Path "C:\domain.promoted")) {
    Install-ADDSForest `
        -DomainName $domain `
        -SafeModeAdministratorPassword $safeModePassword `
        -Force:$true

    # Create flag file so it doesn't try to promote again after reboot
    New-Item -Path "C:\domain.promoted" -ItemType File -Force
}

