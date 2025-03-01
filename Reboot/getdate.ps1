# getdate.ps1
# Generates a timestamp and exits with status 0

$timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
Write-Output $timestamp

$exitCode = 123

Write-Host "##exitcode:$exitCode"

# Exit with success code 0
exit 0
