# enable-ssh.ps1

# Install OpenSSH Server if not present
if (-not (Get-WindowsCapability -Online | Where-Object Name -like 'OpenSSH.Server*' | Where-Object State -eq 'Installed')) {
    Add-WindowsCapability -Online -Name OpenSSH.Server~~~~0.0.1.0
}

# Start the SSH server
Start-Service sshd

# Set sshd to start automatically
Set-Service -Name sshd -StartupType 'Automatic'

# (Optional but recommended) Set the firewall rule to allow SSH
if (-not (Get-NetFirewallRule -Name "SSHD-In-TCP" -ErrorAction SilentlyContinue)) {
    New-NetFirewallRule -Name "SSHD-In-TCP" -DisplayName "OpenSSH Server (sshd)" `
        -Enabled True -Direction Inbound -Protocol TCP -Action Allow -LocalPort 22
}

Write-Output "OpenSSH Server installed and running. SSH is ready."

