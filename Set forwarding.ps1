#Geef alle forwardinstellingen voor een mailbox weer
Get-Mailbox -Identity mailbox@mifa.nl | Select Name, ForwardingAddress, ForwardingsmtpAddress, DeliverToMailboxAndForward

#Geef alle forwardinstellingen voor alle mailboxen weer waarop forwarding staat ingeschakeld
Get-Mailbox -ResultSize Unlimited | Where-Object {($_.ForwardingAddress -ne $Null) -or ($_.ForwardingsmtpAddress -ne $Null)} | Select Name, ForwardingAddress, ForwardingsmtpAddress, DeliverToMailboxAndForward | Out-GridView

#Geef alle forwardinstellingen voor alle mailbox weer waarop forwarding staat uitgeschakeld
Get-Mailbox -ResultSize Unlimited | Where {($_.ForwardingAddress -eq $Null) -and ($_.ForwardingsmtpAddress -eq $Null)} | Select Name, ForwardingAddress, ForwardingsmtpAddress, DeliverToMailboxAndForward

#Schakel forwarding in voor een mailbox
Set-Mailbox -Identity mailbox@mifa.nl -ForwardingSmtpAddress mailbox@venlo.mifa.nl

#Verwijder alle forwarding voor een mailbox
Set-Mailbox -Identity mailbox@mifa.nl -ForwardingAddress $NULL -ForwardingSmtpAddress $NULL

Get-exoMailbox -ResultSize Unlimited | Select Name, ForwardingAddress, ForwardingsmtpAddress, DeliverToMailboxAndForward | Out-GridView

Get-exoMailbox -ResultSize Unlimited | Where-Object {($_.ForwardingAddress -ne $Null)}

Get-Mailbox -ResultSize Unlimited | Where-Object {($_.ForwardingAddress -ne $Null)} | Set-Mailbox -ForwardingAddress $NULL

$fwds = Get-EXOMailbox -ResultSize Unlimited | Where-Object {($_.ForwardingAddress -ne $Null)}
