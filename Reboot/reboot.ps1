[CmdletBinding()]
param(
    [Parameter(Mandatory=$true)]
    [string]$ComputerName,

    [Parameter(Mandatory=$true)]
    [string]$Username,

    [Parameter(Mandatory=$true)]
    [string]$Password
)

$ErrorActionPreference = 'Stop'

Write-Host "Attempting to schedule a forced reboot on '$ComputerName' with user '$Username' (3-sec delay)..."

try {
    # Convert plain-text password to a secure string
    $SecurePassword = ConvertTo-SecureString -String $Password -AsPlainText -Force

    # Create a credential object
    $Credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $Username, $SecurePassword

    # Invoke the remote command
    $result = Invoke-Command -ComputerName $ComputerName -Credential $Credential -ScriptBlock {
        param($ComputerName)

        try {
            Write-Host "Scheduling a forced reboot on '$ComputerName' in 3 seconds..."
            # /r = reboot, /f = force close apps, /t 3 = 3-second delay
            shutdown.exe /r /f /t 3

            # Return 0 on success
            return 0
        }
        catch {
            Write-Host "ERROR: $($_.Exception.Message)"
            # Return non-zero if something went wrong
            return 1
        }
    } -ArgumentList $ComputerName

    # $result should be 0 or 1 if the remote session had time to return it
    Write-Host "Remote script block exit code: $result"

    if ($result -eq 0) {
        Write-Host "Restart command (3-sec delay) issued successfully to '$ComputerName'."
        exit 0
    }
    else {
        Write-Host "Failed to schedule the reboot on '$ComputerName'. Exit code: $result"
        exit 1
    }
}
catch {
    Write-Host "ERROR: Unable to invoke command on '$ComputerName'. Details: $($_.Exception.Message)"
    exit 1
}