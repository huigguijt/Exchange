$exchserver = "srvmail"
$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri http://$exchserver/PowerShell/ -Authentication Kerberos
Import-PSSession $Session
cls
Write-Host "You are now connected to server $((Get-PSSession).ComputerName) in organisation $((Get-OrganizationConfig).Id)" -ForegroundColor Yellow