$CreateEXOPSSession = (Get-ChildItem -Path $env:userprofile -Filter CreateExoPSSession.ps1 -Recurse -ErrorAction SilentlyContinue -Force | Select-Object -Last 1).DirectoryName
. "$CreateEXOPSSession\CreateExoPSSession.ps1"
Connect-EXOPSSession
cls
Write-Host "Verbonden met tenant $((Get-OrganizationConfig).Name) van $((Get-OrganizationConfig).DisplayName)." -ForegroundColor Yellow