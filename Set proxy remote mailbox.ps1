# Get mailboxes
$mailboxes = Get-RemoteMailbox -ResultSize Unlimited | Where-Object {$_.OnPremisesOrganizationalUnit -eq "alphatron-group.com/Alphatron Global/_COE-Singapore/Singapore/Shared Mailbox"}

# Loop through each mailbox
foreach ($mailbox in $mailboxes) 
{
    $emailaddresses = $mailbox.emailaddresses;
    $Addresses = $emailaddresses
    $UPN = $mailbox.UserPrincipalName;
    $SAM=$mailbox.samaccountname;
  

    $onexists=0
    #Loop through each SMTP address found on each mailbox
    for ($i=0; $i -lt $emailaddresses.count; $i++) {
        
        if ($emailaddresses[$i].smtpaddress -like "*@alphatronmarine.mail.onmicrosoft.com") {$onexists=1}

    }
    If ($onexists -eq 0) {
        Write-Host "Setting proxy address for $upn"
        Set-RemoteMailbox $UPN -EmailAddresses @{add="$SAM@alphatronmarine.mail.onmicrosoft.com"}}

}