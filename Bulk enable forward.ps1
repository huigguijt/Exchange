# Loop though the object returned by Get-Mailbox with each element represented by $mailbox
foreach ($mailbox in (Get-MailBox -ResultSize Unlimited -Filter {PrimarySmtpAddress -like "n.anderson*"}))
{
# Create the forwarding address string
$ForwardingAddress = $mailbox.alias+"@migratie.area365.nl"
# Check there isn't a contact, then add one
#If (!(Get-MailContact $ForwardingAddress -ErrorAction SilentlyContinue))
#{
#New-MailContact $ForwardingAddress -ExternalEmailAddress $ForwardingAddress
#}
# Set the forwarding address
Set-Mailbox $mailbox.UserPrincipalName -ForwardingSmtpAddress $ForwardingAddress
}