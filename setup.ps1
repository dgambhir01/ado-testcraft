# One-time setup for ado-testcraft.
# Run this once after installing the plugin. It stores your Azure DevOps
# credentials as persistent user environment variables so Claude Code can
# connect on every launch.
#
# Usage: .\setup.ps1

Write-Host ""
Write-Host "ado-testcraft setup" -ForegroundColor Cyan
Write-Host "===================" -ForegroundColor Cyan
Write-Host "Credentials will be stored as user environment variables."
Write-Host "You only need to run this once."
Write-Host ""

$org     = Read-Host "Azure DevOps organization name  (e.g. mycompany)"
$project = Read-Host "Azure DevOps project name       (e.g. MyProject)"
$patSec  = Read-Host "Your Personal Access Token (PAT)" -AsSecureString

# Decode SecureString to plain text just long enough to store it
$bstr     = [Runtime.InteropServices.Marshal]::SecureStringToBSTR($patSec)
$patPlain = [Runtime.InteropServices.Marshal]::PtrToStringAuto($bstr)
[Runtime.InteropServices.Marshal]::ZeroFreeBSTR($bstr)

# Persist as user-level env vars (survives reboots, no shell profile editing needed)
[System.Environment]::SetEnvironmentVariable("ADO_ORG",     $org,      "User")
[System.Environment]::SetEnvironmentVariable("ADO_PROJECT", $project,  "User")
[System.Environment]::SetEnvironmentVariable("ADO_PAT",     $patPlain, "User")

# Overwrite plaintext PAT in this script's memory
$patPlain = $null

Write-Host ""
Write-Host "Done! Environment variables saved:" -ForegroundColor Green
Write-Host "  ADO_ORG     = $org"
Write-Host "  ADO_PROJECT = $project"
Write-Host "  ADO_PAT     = [hidden]"
Write-Host ""
Write-Host "Restart Claude Code, then try:" -ForegroundColor Yellow
Write-Host "  /ado-testcraft:generate <your-story-id>"
Write-Host ""
