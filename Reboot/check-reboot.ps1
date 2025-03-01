[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$ComputerName,

    [Parameter(Mandatory = $true)]
    [string]$Username,

    [Parameter(Mandatory = $true)]
    [string]$Password,

    # Number of times to attempt checking the server
    [int]$MaxRetries = 30,

    # Seconds to wait between each retry
    [int]$SleepInterval = 10
)

$ErrorActionPreference = 'Stop'

Write-Host "Checking if server '$ComputerName' is back online after reboot..."

try {
    # Convert the plaintext password into a SecureString
    $SecurePassword = ConvertTo-SecureString -String $Password -AsPlainText -Force
    # Build a PSCredential
    $Credential = New-Object System.Management.Automation.PSCredential($Username, $SecurePassword)

    $isOnline = $false
    $tryCount = 0
    $initialsleep = 3
    sleep $initialsleep

    while (-not $isOnline -and $tryCount -lt $MaxRetries) {
        $tryCount++
        Write-Host "[$tryCount/$MaxRetries] Pinging '$ComputerName'..."

        # Quick check: Can we ping the server?
        $ping = Test-Connection -ComputerName $ComputerName -Count 1 -Quiet -ErrorAction SilentlyContinue
        if ($ping) {
            Write-Host "Ping succeeded. Attempting remote PowerShell command..."

            # Next check: Is PowerShell remoting ready?
            try {
                # A simple command to ensure the server is responding. For example: Get the system's current date/time
                Invoke-Command -ComputerName $ComputerName -Credential $Credential -ScriptBlock {
                    Get-Date
                } | Out-Null

                Write-Host "Invoke-Command succeeded. Server '$ComputerName' is operational."
                $isOnline = $true
                break
            }
            catch {
                Write-Host "Invoke-Command failed. Details: $($_.Exception.Message)"
            }
        }
        else {
            Write-Host "Ping failed."
        }

        Write-Host "Sleeping for $SleepInterval seconds before next attempt..."
        Start-Sleep -Seconds $SleepInterval
    }

    if ($isOnline) {
        # All checks passed
        Write-Host "Check completed: '$ComputerName' is online and accepting remote commands."
        exit 0
    }
    else {
        Write-Host "ERROR: Server '$ComputerName' is not reachable or not accepting remote commands after $MaxRetries attempts."
        exit 1
    }
}
catch {
    Write-Host "ERROR: Could not complete the check. Details: $($_.Exception.Message)"
    exit 1
}
