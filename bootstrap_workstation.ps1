$logPath = "C:\temp"

# Ensure temp folder exists
New-Item -ItemType Directory -Path $logPath

# Helper flag check
function StepCompleted($flag) {
    return (Test-Path $flag)
}

# ====== Setup =============
$credsUrl = "${creds_url}"
$domain = "xyz.local"
$logFile = "$env:ProgramData\ADJoin\ad_join.log"
$maxWaitMinutes = 15
$waitIntervalSeconds = 30
$VerboseLogging = $true

# Setup logging
$logDir = Split-Path $logFile
if (!(Test-Path $logDir)) {
    New-Item -ItemType Directory -Path $logDir -Force | Out-Null
}

function Write-Log {
    param (
        [string]$Message, [string]$Level = "INFO"
    )
    $timestamp = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
    $logMessage = "[$timestamp] [$Level] $Message"
    Add-Content -Path $logFile -Value $logMessage
    if ($VerboseLogging) { Write-Host $logMessage }
}



# ======= Variables =============
$credsPath = "$env:TEMP\lab-creds.json"
$elapsed = 0
Write-Log "Starting AD joing wait script..."
Write-Log "Polling for credentials at: $credsUrl"


# Poll for the file to become available
while ($elapsed -lt ($maxWaitMinutes * 60)) {
    try {
        Invoke-WebRequest -Uri $credsUrl -OutFile $credsPath -ErrorAction Stop
        Write-Log "Credential file downloaded."
        break
    }
    catch {
        Write-Log "Credentials not found yet. Waiting..." "DEBUG"
        Start-Sleep -Seconds $waitIntervalSeconds
        $elapsed += $waitIntervalSeconds
    }
}

if (!(Test-Path $credsPath)) {
    Write-Log "Timed out after $maxWaitMinutes minutes waiting for credentials." "ERROR"
    exit 1
}

# ======== Read and Parse Creds ===========
try {
    $creds = Get-Content $credsPath | ConvertFrom-Json
    $username = $creds.username
    $password = $creds.password
    Write-Log "Parsed credentials for user: $username"
}
catch {
    Write-Log "Failed to parse credentials JSON." "ERROR"
    exit 1
}

# ========= Join Domain ==============
$computerSystem = Get-WmiObject Win32_ComputerSystem 

if (-not $computerSystem.PartOfDomain) {
    try {
        $securePass = ConvertTo-SecureString $password -AsPlainText -Force
        $cred = New-Object System.Management.Automation.PSCredential("$domain\$username", $securePass)
        Write-Log "Joining Domain: $domain as $username"
        Add-Computer -DomainName $domain -Credential $cred -Restart
    }
    catch {
        Write-Log "Domain join failed: $_" "ERROR"
        exit 1
    }
}
else {
    Write-Log "Already joined the domain: $domain"
}

# ========= Set Auto Login ===============
try {
    $regPath = "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon"
    Set-ItemProperty -Path $regPath -Name 'AutoAdminLogon' -Value "1"
    Set-ItemProperty -Path $regPath -Name "DefaultDomainName" -Value $domain
    Set-ItemProperty -Path $regPath -Name "DefaultUserName" -Value $username
    Set-ItemProperty -Path $regPath -Name "DefaultPassword" -Value $password
    Write-Log "Configured auto logon for $domain\$username"
}
catch {
    Write-Log "Auto-login configuration failed: $_" "ERROR"
    exit 1
}

Write-Log "Script Complete. Machine will reboot if required."