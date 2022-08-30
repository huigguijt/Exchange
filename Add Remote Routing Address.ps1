# Get mailboxes
# Optie1 - per OU
# $mailboxes = get-mailbox -ResultSize unlimited #-OrganizationalUnit mail.loc/org/gebruikers/office365
# Optie2 - alles zonder proxyadres
# $mailboxes = get-mailbox -filter {emailaddresses -notlike '*mail.onmicrosoft.com'}

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
        
        if ($emailaddresses[$i].smtpaddress -like "*@tenant.mail.onmicrosoft.com") {$onexists=1}

    }
    If ($onexists -eq 0) {Set-Mailbox $UPN -EmailAddresses @{add="$SAM@tenant.mail.onmicrosoft.com"}}

} 
