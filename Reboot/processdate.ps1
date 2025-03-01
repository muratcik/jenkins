param(
    [Parameter(Mandatory=$true)]
    [string]$InputValue
)

Write-Host "Received input: $InputValue"

# Simulate success or failure (0 = success, 1 = failure)
if ($InputValue) {
    Write-Host "Processing completed successfully with $InputValue"
    exit 0
} else {
    Write-Host "Processing failed due to missing input."
    exit 1
}