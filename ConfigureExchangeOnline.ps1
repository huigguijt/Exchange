# Setup session to Exchange Online
Write-Host "Connecting to Exchange Online" `n -ForegroundColor Yellow
Connect-ExchangeOnline
Connect-IPPSSession
Write-Host "Connected to tenant $((Get-OrganizationConfig).Name) of organization $((Get-OrganizationConfig).DisplayName)." -ForegroundColor Yellow
Write-Warning "Please verify tenant connection!!!"
Read-Host -Prompt "Press Enter to continue or CRTL-C to stop the script"

# Enable Audit log
Write-Host "Enabling Audit log" -ForegroundColor Yellow
Set-AdminAuditLogConfig -UnifiedAuditLogIngestionEnabled $true

# Enable modern authentication for Exchange Online
Write-Host "Current status modern authentication" -ForegroundColor Yellow
Get-OrganizationConfig | FT NAME, *OAUTH*
Write-Host "Enabling modern authentication" -ForegroundColor Yellow
Set-OrganizationConfig -OAUTH2CLIENTPROFILEENABLED:$TRUE
Write-Host "Done" `n -ForegroundColor Green

# Block legacy authentication for Exchange Online
Write-Host "Blocking legacy authentication for Exchange Online" -ForegroundColor Yellow
New-AuthenticationPolicy -Name "Block Legacy Auth"
Set-OrganizationConfig -DefaultAuthenticationPolicy "Block Legacy Auth"
Write-Host "Done" `n -ForegroundColor Green

# Configure Out of the Office for hybrid setup
Write-Host "Configuring Out of the Office for hybrid setup" -ForegroundColor Yellow
$doms = (Get-AcceptedDomain).domainname
foreach($dom in $doms){
    New-RemoteDomain "$dom" -DomainName "$dom"
    Set-RemoteDomain “$dom” -AllowedOOFType InternalLegacy -TNEFEnabled $true
}
Write-Host "Done" `n -ForegroundColor Green

# Prevent automatic forwarding to external domains
Write-Host "Current status automatic forwarding" -ForegroundColor Yellow
Get-RemoteDomain DEFAULT | FL AUTOFORWARDENABLED
Write-Host "Disabling automatic forwarding to external domains" -ForegroundColor Yellow
Set-RemoteDomain DEFAULT -AutoForwardEnabled $FALSE
Write-Host "Done" `n -ForegroundColor Green

# Set RetainDeletedItemsFor to 30 days for all current mailboxes and future mailboxes
Write-Host "Setting RetainDeletedItemsFor to 30 days for all current and future mailboxes" -ForegroundColor Yellow
Get-Mailbox * -ResultSize Unlimited| Set-Mailbox -RetainDeletedItemsFor 30
Get-MailboxPlan | Set-MailboxPlan -RetainDeletedItemsFor 30
Write-Host "Done" `n -ForegroundColor Green

# Disable POP and IMAP for all current and future mailboxes
Write-Host "Disabling IMAP and POP for future mailboxes" -ForegroundColor Yellow
Get-CASMailboxPlan -Filter {ImapEnabled -eq "true" -or PopEnabled -eq "true" } | set-CASMailboxPlan -ImapEnabled $false -PopEnabled $false
$confirmPlans = Get-CASMailboxPlan -Filter {ImapEnabled -eq "true" -or PopEnabled -eq "true" }
if (!$confirmPlans) {
    Write-Host "IMAP and POP disabled for all future mailboxes" -ForegroundColor Green
}
else {
    Write-Host "IMAP and POP not disabled for all future mailboxes" -ForegroundColor Red
}
 
Write-Host "Disabling IMAP and POP on all current mailboxes" -ForegroundColor Yellow
Get-CASMailbox -Filter {ImapEnabled -eq "true" -or PopEnabled -eq "true" } | Select-Object @{n = "Identity"; e = {$_.primarysmtpaddress}} | Set-CASMailbox -ImapEnabled $false -PopEnabled $false
$confirmMailboxes = Get-CASMailbox -Filter {ImapEnabled -eq "true" -or PopEnabled -eq "true" }
if (!$confirmMailboxes) {
    Write-Host "IMAP and POP disabled on all current mailboxes`n" -ForegroundColor Green
}
else {
    Write-Host "IMAP and POP not disabled for all current mailboxes" -ForegroundColor Red
}
Write-Host "Done" `n -ForegroundColor Green

# Enable Enhance Filtering for Hybrid Connector
$hybridconnector = Get-InboundConnector | where {$_.ConnectorSource -eq "HybridWizard"}
Write-Host "Enable Enhance Filtering on connector $hybridconnector" -ForegroundColor Yellow
Get-InboundConnector | where {$_.ConnectorSource -eq "HybridWizard"} | Set-InboundConnector -EFSkipLastIP $true
Write-Host "Done" `n -ForegroundColor Green

# Configure Exchange Online Protection settings
Write-Host "Configuring Exchange Online Protection settings" -ForegroundColor Yellow
# Enable file filter
Set-MalwareFilterPolicy -Identity Default -EnableFileFilter $true
# Enable safe list
Set-HostedConnectionFilterPolicy -Identity Default -EnableSafeList $true
# Enable Quarantine
Set-HostedContentFilterPolicy -Identity Default -QuarantineRetentionPeriod 30 -SpamAction Quarantine -HighConfidenceSpamAction Quarantine -BulkSpamAction Quarantine -PhishSpamAction Quarantine -BulkThreshold 6 -EnableEndUserSpamNotifications $true
# Limit outbound spam
Set-HostedOutboundSpamFilterPolicy -Identity Default -RecipientLimitExternalPerHour 500 -RecipientLimitInternalPerHour 1000 -RecipientLimitPerDay 1000 -ActionWhenThresholdReached BlockUser
Write-Host "Done" `n -ForegroundColor Green

Write-Host "Finished" `n -ForegroundColor Green