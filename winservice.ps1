[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$ComputerName,

    [Parameter(Mandatory = $true)]
    [string]$Username,

    [Parameter(Mandatory = $true)]
    [SecureString]$Password,

    [Parameter(Mandatory = $true)]
    [string]$ServiceName,

    [Parameter(Mandatory = $true)]
    #[ValidateSet("Start","Stop","Restart")]
    [string]$Action
)

$ErrorActionPreference = 'Stop'

# Convert the plain-text password to a secure string
# $SecurePassword = ConvertTo-SecureString $Password -AsPlainText -Force

# Build a PSCredential object from the username and secure string
$Credential = New-Object -TypeName System.Management.Automation.PSCredential `
    -ArgumentList $Username, $SecurePassword

Write-Host "Invoking service action '$Action' on remote computer '$ComputerName'..."

try {
    # Invoke-Command returns whatever the script block returns
    $result = Invoke-Command -ComputerName $ComputerName -Credential $Credential -ScriptBlock {
        param($ServiceName, $Action)

        # Convert non-terminating errors into terminating errors
        $ErrorActionPreference = 'Stop'

        try {

            if (-not (Get-Service -Name $ServiceName -ErrorAction SilentlyContinue)) {
                Write-Host "ERROR: Service '$ServiceName' not found on this system."
                return 1
            }

            switch ($Action) {
                "Start" {
                    Write-Host "Attempting to START service: $ServiceName"
                    Start-Service -Name $ServiceName
                    Write-Host "Service $ServiceName started successfully."
                }
                "Stop" {
                    Write-Host "Attempting to STOP service: $ServiceName"
                    Stop-Service -Name $ServiceName -Force
                    Write-Host "Service $ServiceName stopped successfully."
                }
                "Restart" {
                    Write-Host "Attempting to RESTART service: $ServiceName"
                    Restart-Service -Name $ServiceName -Force
                    Write-Host "Service $ServiceName restarted successfully."
                }
                default { Write-Host "Wrong Argument: $Action"; return 1; }
            }

            # Return exit code 0 to indicate success
            return 0
        }
        catch {
            Write-Host "ERROR: Unable to $Action service '$ServiceName'. Details: $($_.Exception.Message)"
            # Return a non-zero exit code to indicate failure
            return 1
        }

    } -ArgumentList $ServiceName, $Action

    # $result now holds the exit code returned by the remote script block.
    # If you specified only one -ComputerName, $result should be a single integer (0 or 1).
    # If multiple computers were specified, $result is an array.

    Write-Host "Remote script block exit code: $result"

    # Check exit code locally
    if ($result -eq 0) {
        Write-Host "Service action completed successfully on '$ComputerName'."
        exit 0
    }
    else {
        Write-Host "Service action FAILED on '$ComputerName'. Exit code: $result"
        exit 1
        # Optionally set a local $LASTEXITCODE or throw an error
        # $global:LASTEXITCODE = $result
        # throw "Remote script block returned exit code $result"
    }
}
catch {
    # This catch block is for local errors in Invoke-Command (e.g., connection issues, bad credentials)
    Write-Host "ERROR: Failed to invoke command on '$ComputerName'. Details: $($_.Exception.Message)"
    exit 1
    # Optionally set local exit code or re-throw
    # $global:LASTEXITCODE = 2
    # throw
}
