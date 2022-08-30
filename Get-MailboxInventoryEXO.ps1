## Get-MailboxInventoryEXO
## Create inventory of all mailboxes in Exchange Online.
## Outputs: All mailbox data, Inputfile (for migration), Mailbox sizes, Permissions, Mailboxes without onmicrosoft.com routing addresses 
## 
## By M Verweel - Wortell (marcel.verweel@wortell.nl)

# Check for existing Exchange Online connection and make connection
if (!(Get-PSSession | where { $_.ConfigurationName -eq 'Microsoft.Exchange' -and $_.ComputerName -eq 'outlook.office365.com' -and $_.State -eq 'Opened' -and $_.Availability -eq 'Available'})) {
    Write-Host "No connection to Exchange Online." -ForegroundColor Red
    try {
        Import-Module ExchangeOnlineManagement -ErrorAction Stop
        Connect-ExchangeOnline
        Write-Host "Connected to tenant '$((Get-OrganizationConfig).Name)' of organization '$((Get-OrganizationConfig).DisplayName)'." `n -ForegroundColor Cyan
    }
    catch {
        Write-Host "Exchange Online V2 Module not found, please install and re-run script" -Foregroundcolor Red
        Write-Host "https://docs.microsoft.com/en-us/powershell/exchange/exchange-online-powershell-v2?view=exchange-ps#install-the-exo-v2-module" -ForegroundColor Yellow
        exit
    }
}
else {
    Write-Host "Existing connection to Exchange Online found." -ForegroundColor Green
    Write-Host "You are currently connected to tenant '$((Get-OrganizationConfig).Name)' of organization '$((Get-OrganizationConfig).DisplayName)'." -ForegroundColor Cyan
    Write-Host "Is this correct?" -ForegroundColor Yellow
    $RespConn = Read-Host "(y/n)"
    if ($RespConn -eq "y") {
        Write-Host "Continuing Script" -ForegroundColor Cyan
    }
    else {
        Write-Host "Closing current connection" -ForegroundColor Cyan
        Disconnect-ExchangeOnline -Confirm:$False
        Connect-ExchangeOnline
        Write-Host "Connected to tenant $((Get-OrganizationConfig).Name) of organization $((Get-OrganizationConfig).DisplayName)." `n -ForegroundColor Cyan
    }
}

# Set filepaths
$Tenantname = (Get-OrganizationConfig).DisplayName
$FilePath = $PSCommandPath
$FileDate = Get-Date -Format ddMMyy-HHmm
$FileName = (Split-Path $PSCommandPath -Leaf).Split(".")[0]
$BasePath = Split-Path -path $FilePath
$FilePrefix = "$($FileName)_$($TenantName)_$($FileDate)_"
$OutputPath = "$($BasePath)\$($FilePrefix)"
$Transcriptfile = $OutputPath+"Transcript.log"

# Start Logging
Start-Transcript -Path $TranscriptFile

$Mbx = @()
$Mbx = Get-Mailbox -ResultSize Unlimited | where {$_.DisplayName -notlike "Discovery Search Mailbox"}

# Export all data (backup)
$Mbx | Export-Csv $OutputPath"AllMbxData.csv" -NoTypeInformation -Delimiter ";" -Encoding UTF8

# Export inputfile data
$OnMSSuffix = (Get-OrganizationConfig).Identity
$Mbx | select @{Name="OnmicrosoftAddress";Expression={($_.EmailAddresses | where {$_ -like "smtp:*$($OnMSSuffix)"}) -replace "smtp:",""}},IsDirSynced,RecipientType,RecipientTypeDetails,RemoteRecipientType,PrimarySmtpAddress,@{Name="EmailAddresses";Expression={($_.Emailaddresses | where {$_ -like "smtp:*" -or $_ -like "X500:*"}) -join ","}},Alias,Identity,Id,Name,DisplayName,AccountDisabled,UserPrincipalName,ArchiveStatus,ArchiveName,MessageCopyForSentAsEnabled,MessageCopyForSendOnBehalfEnabled,DeliverToMailboxAndForward,LitigationHoldEnabled,RetentionHoldEnabled,IsMailboxEnabled,RetentionPolicy,AddressBookPolicy,ExchangeGuid,ExchangeUserAccountControl,ForwardingAddress,ForwardingSmtpAddress,RetainDeletedItemsFor,ProhibitSendQuota,ProhibitSendReceiveQuota,IsResource,IsLinked,IsShared,ServerLegacyDN,WindowsLiveID,MicrosoftOnlineServicesID,RoleAssignmentPolicy,IsInactiveMailbox,HiddenFromAddressListsEnabled,LegacyExchangeDN,WindowsEmailAddress,ExchangeObjectId | Export-Csv $OutputPath"ProjectInputData.csv" -NoTypeInformation -Delimiter ";" -Encoding UTF8

# Export Mailbox sizes
$Mbx | Get-MailboxStatistics | Select-Object DisplayName,@{Name="TotalItemSizeMB";Expression={[math]::Round(($_.TotalItemSize.ToString().Split("(")[1].Split(" ")[0].Replace(",","")/1MB),0)}},ItemCount | Export-Csv $OutputPath"MbxSizes.csv" -NoTypeInformation -Delimiter ";" -Encoding UTF8

# Export Send On Behalf permissions
$Mbx | where {$_.GrantSendOnBehalfTo -ne $null} | select Identity,Alias,UserPrincipalName,PrimarySmtpAddress,@{l='Sender';e={$_.GrantSendOnBehalfTo -join ","}} | Export-Csv $OutputPath"SendOnBehalfPermissions.csv" -NoTypeInformation -Delimiter ";" -Encoding UTF8

# Export Send As permissions
$Mbx | Get-RecipientPermission | where {$_.trustee -ne "NT AUTHORITY\SELF" -and $_.IsInherited -ne "False"} | select Identity,Trustee,AccessControlType,AccessRights | Export-Csv $OutputPath"SendAsPermissions.csv" -NoTypeInformation -Delimiter ";" -Encoding UTF8

# Export Full Access permissions
$Mbx | Get-MailboxPermission | where {$_.user.tostring() -ne "NT AUTHORITY\SELF" -and $_.IsInherited -eq $false -and $_.accessrights -contains "Fullaccess"} | Select Identity,User,AccessRights | Export-Csv $OutputPath"FullAccessPermissions.csv" -NoTypeInformation -Delimiter ";" -Encoding UTF8

# Export mailboxes without onmicrosoft routing address
$Mbx | select Name,UserPrincipalName,PrimarySMTPAddress,Alias,@{Name="Addresses";Expression={$_.EmailAddresses -match "onmicrosoft.com"}} | Where-Object {$_.Addresses -eq $Null} | Export-Csv $OutputPath"NoOnMsSMTP.csv" -NoTypeInformation -Delimiter ";" -Encoding UTF8

Stop-Transcript