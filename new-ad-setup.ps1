

$domain = "xyz.local"
$safeModePassword = Convert-To-SecureString "P@ssw0rd123" -AsPlainText -False
$bootstrapScriptUrl = "https://raw.githubusercontent.com/fozziiee/AD/main/code/bootstrap_ad.ps1"
$bootstrapScriptPath = "C:\cyberlab\code\bootstrap_ad.ps1"

# Ensure the script directory exists
if (-not (Test-Path "C:\cyberlab\code")) {
    New-Item -Path "C:\cyberlab\code" -ItemType Directory -Force | Out-Null
}

# Download the bootstrap script
Invoke-WebRequest -Uri $bootstrapScriptUrl -OutFile $bootstrapScriptPath

# Schedule it to run on startup with args
$action = NewScheduledTaskAction -Execute "Powershell.exe" -Argument "-ExecutionPolicy Bypass -File `"$bootstrapScriptPath`" -Users 10 -Groups 3 -Admins 1"
$trigger = NewScheduledTaskTrigger -AtStartup
Register-ScheduledTask -TaskName "RunPostADScript" -Action $action -Trigger $trigger -RunLevel Highest -User "SYSTEM"

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

