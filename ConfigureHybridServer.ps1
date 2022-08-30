# General variables
$ServerFQDN = "server.domain.local"
$localdblogdrive = "G:"
$PublicFQDN = "hybrid.domain.com"
$Primarymaildomain = "domain.com"

# Check for admin priveleges
If (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(`

    [Security.Principal.WindowsBuiltInRole] “Administrator”))

{
    Write-Warning “You do not have Administrator rights to run this script!`nPlease re-run this script as Administrator!”

    Break
}

# Setup session to Hybrid server
Write-Host "Connecting to Exchange Management session on $ServerFQDN" `n -ForegroundColor Yellow
Add-PSSnapin Microsoft.Exchange.Management.PowerShell.SnapIn
Write-Host "Done" `n -ForegroundColor Green

# Move IIS log files
$IISlogpath = "$localdblogdrive\Inetpub\LogFiles"
Write-Host "Moving IIS log files to $localdblogdrive drive" `n -ForegroundColor Yellow
Import-Module WebAdministration
Set-ItemProperty 'IIS:\Sites\Default Web Site' -name logFile.directory -value $IISlogpath
Set-ItemProperty 'IIS:\Sites\Exchange Back End’ -name logFile.directory -value $IISlogpath
Write-Host "Done" `n -ForegroundColor Green

# Configure virtual directory URL's
Write-Host "Setting all URL's to $PublicFQDN" `n -ForegroundColor Yellow
# Outlook Anywhere
Set-OutlookAnywhere –Identity "$ServerFQDN\Rpc (Default Web Site)" -ExternalClientAuthenticationMethod NTLM -ExternalHostname $PublicFQDN -ExternalClientsRequireSSL:$TRUE -InternalHostname $PublicFQDN -InternalClientsRequireSSL:$TRUE
# Autodiscover
Set-ClientAccessService -Identity $ServerFQDN -AutodiscoverServiceInternalUri “https://$PublicFQDN/autodiscover/autodiscover.xml”
# EWS
Set-WebServicesVirtualdirectory -Identity "$ServerFQDN\EWS (Default Web Site)” -InternalUrl “https://$PublicFQDN/ews/Exchange.asmx” -ExternalUrl “https://$PublicFQDN/ews/Exchange.asmx”
# OAB
Set-OABVirtualDirectory -Identity "$ServerFQDN\OAB (Default Web Site)” -InternalUrl “https://$PublicFQDN/oab” -ExternalUrl “https://$PublicFQDN/oab”
# OWA
Set-OWAVirtualDirectory -Identity "$ServerFQDN\OWA (Default Web Site)” -InternalUrl “https://$PublicFQDN/owa” -ExternalUrl “https://$PublicFQDN/owa”
# ECP
Set-ECPVirtualDirectory -Identity "$ServerFQDN\ECP (Default Web Site)” -InternalUrl “https://$PublicFQDN/ecp” -ExternalUrl “https://$PublicFQDN/ecp”
# ActiveSync
Set-ActiveSyncVirtualDirectory -Identity "$ServerFQDN\Microsoft-Server-ActiveSync (Default Web Site)” -InternalUrl "https://$PublicFQDN/Microsoft-Server-ActiveSync" -ExternalUrl "https://$PublicFQDN/Microsoft-Server-ActiveSync"
# PowerShell
Set-PowerShellVirtualDirectory -Identity "$ServerFQDN\Powershell (Default Web Site)” -InternalUrl "https://$PublicFQDN/powershell" -ExternalUrl “https://$PublicFQDN/powershell"
# MAPI
Set-MAPIVirtualDirectory -Identity "$ServerFQDN\MAPI (Default Web Site)” -InternalUrl "https://$PublicFQDN/mapi" -ExternalUrl "https://$PublicFQDN/mapi"

Write-Host "Done" -ForegroundColor Green
Write-Host "URL's have been changed to the following properties:" `n -ForegroundColor Yellow

#Display all URL's
$OA = Get-OutlookAnywhere -Server $ServerFQDN -AdPropertiesOnly | Select InternalHostName,ExternalHostName
Write-Host "Outlook Anywhere" -ForegroundColor Yellow
Write-Host " - Internal: $($OA.InternalHostName)"
Write-Host " - External: $($OA.ExternalHostName)"

$OWA = Get-OWAVirtualDirectory -Server $ServerFQDN -AdPropertiesOnly | Select InternalURL,ExternalURL
Write-Host "Outlook Web App" -ForegroundColor Yellow
Write-Host " - Internal: $($OWA.InternalURL)"
Write-Host " - External: $($OWA.ExternalURL)"

$ECP = Get-ECPVirtualDirectory -Server $ServerFQDN -AdPropertiesOnly | Select InternalURL,ExternalURL
Write-Host "Exchange Control Panel" -ForegroundColor Yellow
Write-Host " - Internal: $($ECP.InternalURL)"
Write-Host " - External: $($ECP.ExternalURL)"

$OAB = Get-OABVirtualDirectory -Server $ServerFQDN -AdPropertiesOnly | Select InternalURL,ExternalURL
Write-Host "Offline Address Book" -ForegroundColor Yellow
Write-Host " - Internal: $($OAB.InternalURL)"
Write-Host " - External: $($OAB.ExternalURL)"

$EWS = Get-WebServicesVirtualDirectory -Server $ServerFQDN -AdPropertiesOnly | Select InternalURL,ExternalURL
Write-Host "Exchange Web Services" -ForegroundColor Yellow
Write-Host " - Internal: $($EWS.InternalURL)"
Write-Host " - External: $($EWS.ExternalURL)"

$MAPI = Get-MAPIVirtualDirectory -Server $ServerFQDN -AdPropertiesOnly | Select InternalURL,ExternalURL
Write-Host "MAPI" -ForegroundColor Yellow
Write-Host " - Internal: $($MAPI.InternalURL)"
Write-Host " - External: $($MAPI.ExternalURL)"

$EAS = Get-ActiveSyncVirtualDirectory -Server $ServerFQDN -AdPropertiesOnly | Select InternalURL,ExternalURL
Write-Host "ActiveSync" -ForegroundColor Yellow
Write-Host " - Internal: $($EAS.InternalURL)"
Write-Host " - External: $($EAS.ExternalURL)"

$AutoD = Get-ClientAccessService $ServerFQDN | Select AutoDiscoverServiceInternalUri
Write-Host "Autodiscover" -ForegroundColor Yellow
Write-Host " - Internal SCP: $($AutoD.AutoDiscoverServiceInternalUri)"

# Configure Transport Settings to 150 Mb
$MaxMessageSize = "150MB"
$MaxTransportDumpsterSize = "150MB"
Write-Host "Increasing transport settings" `n -ForegroundColor Yellow
Set-TransportConfig -MaxReceiveSize $MaxMessageSize -MaxSendSize $MaxMessageSize -MaxDumpsterSizePerDatabase $MaxTransportDumpsterSize
Write-Host "Done" `n -ForegroundColor Green

# Exclude mailbox databases from provisioning
Write-Host "Excluding mailbox databases from provisioning" `n -ForegroundColor Yellow
Get-MailboxDatabase -Server $ServerFQDN | Set-MailboxDatabase -IsExcludedFromProvisioning $true
Write-Host "Done" `n -ForegroundColor Green

# Enable mailbox database circular logging
Write-Host "Enabling circular logging for all local databases" `n -ForegroundColor Yellow
Get-MailboxDatabase -Server $ServerFQDN | Set-MailboxDatabase -CircularLoggingEnabled:$True 
Get-MailboxDatabase -Server $ServerFQDN | Dismount-Database -Confirm:$False
Get-MailboxDatabase -Server $ServerFQDN | Mount-Database -Confirm:$False
Write-Host "Done" `n -ForegroundColor Green

# Create Relay Connector
Write-Host "Creating Relay Connector" `n -ForegroundColor Yellow
$ip = (Get-NetIPConfiguration).IPv4Address.IPAddress
New-Receiveconnector -Name "Internal relay" -Server $ServerFQDN -Usage CUSTOM -MaxMessageSize 150MB -FQDN $PublicFQDN -Bindings 0.0.0.0:25 -RemoteIPRanges $ip -Transportrole FRONTENDTRANSPORT -PermissionGroups ANONYMOUSUSERS
Write-Host "Done" `n -ForegroundColor Green

# Assign certificate to Exchange Services
$certificate = (Get-ExchangeCertificate -DomainName $PublicFQDN).subject
$ExchCertificateServices = "IIS, SMTP"
Write-Host "Assigning certificate $certificate to services $ExchCertificateServices" `n -ForegroundColor Yellow
Get-ExchangeCertificate -DomainName $PublicFQDN | Enable-ExchangeCertificate -Server $ServerFQDN -Services $ExchCertificateServices -DoNotRequireSSL -Force
Write-Host "Done" `n -ForegroundColor Green

# Set OWA redirect URL
Write-Host "Setting TargetOWAURL to $Primarymaildomain" `n -ForegroundColor Yellow
Get-OrganizationRelationship | Set-OrganizationRelationship -TargetOwaURL https://outlook.com/owa/$Primarymaildomain
Write-Host "Done" `n -ForegroundColor Green

# Configure Out of the Office
Write-Host "Configuring Out of the Office" `n -ForegroundColor Yellow
Get-RemoteDomain | where {$_.name -like "Hybrid Domain - *"} | Set-RemoteDomain -AllowedOOFType InternalLegacy -TNEFEnabled $true
Write-Host "Done" `n -ForegroundColor Green

# End Exchange PS session
Write-Host "Disconnecting from Exchange session" `n -ForegroundColor Yellow
Remove-PSSession $Session
Write-Host "Done" `n -ForegroundColor Green

# Restart IIS
Write-Host "Restarting IIS" `n -ForegroundColor Yellow
iisreset
Write-Host "Done" `n -ForegroundColor Green

Write-Host "Finished" `n -ForegroundColor Green