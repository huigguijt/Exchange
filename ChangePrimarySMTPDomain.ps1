$oldDomain = "@nordwincollege.nl"
$newDomain = "@stichtingnordwincollege.onmicrosoft.com"

#$mailboxes = Get-Mailbox nwbomb
$mailboxes = (Get-Mailbox -ResultSize Unlimited -RecipientTypeDetails UserMailbox).where{$_.PrimarySmtpAddress -like "*$oldDomain"}
foreach ($mbx in $mailboxes){
$newSMTPAddress = $mbx.PrimarySmtpAddress -split '@'
$newSMTPAddress = $newSMTPAddress[0] + $newDomain
Write-Host "Processing: $mbx.Name -> $newSMTPAddress"
Set-Mailbox $mbx.Identity -WindowsEmailAddress $newSMTPAddress
}