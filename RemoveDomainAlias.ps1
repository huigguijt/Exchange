$Domain = "domain.nl"
$RemoveSMTPDomain = "smtp:*@$Domain"
 
$AllMailboxes = Get-Mailbox -ResultSize unlimited | Where-Object {$_.EmailAddresses -clike $RemoveSMTPDomain}
$AllMailboxes | select name,emailaddresses | Out-GridView

pause
 
ForEach ($Mailbox in $AllMailboxes)
{
        
   $AllEmailAddress  = $Mailbox.EmailAddresses -cnotlike $RemoveSMTPDomain
   $RemovedEmailAddress = $Mailbox.EmailAddresses -clike $RemoveDomainsmtp
   $MailboxID = $Mailbox.PrimarySmtpAddress 
   $MailboxID | Set-Mailbox -EmailAddresses $AllEmailAddress #-whatif
 
   Write-Host "The following E-mail address where removed $RemovedEmailAddress from $MailboxID Mailbox "
    
}