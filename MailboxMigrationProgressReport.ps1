##### Migration Progress Reporting Script #####
#                                             #
# This scripts counts the number of mailboxes #
# on-premises and remote. Then it calculates  #
# the percentage of mailboxes migrated        #
# to Exchange Online and exports the values   #
# to an HTML file and mail message.           #
#                                             #
#           Huig.Guijt@wortell.nl             #
###############################################

# Setup a session to an Exchange Server
$exchserver = "localexhchangeserver"
$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri http://$exchserver/PowerShell/ -Authentication Kerberos
Import-PSSession $Session

# Count the number of local mailboxes
$amountlocal = (Get-Mailbox -resultsize unlimited).count

# Count the number of remote mailboxes
$amountremote = (Get-RemoteMailbox -resultsize unlimited).count

# Calculate the total amount of mailboxes for the organisation
$sumamount = $amountlocal + $amountremote

# Calculate the percentage of mailboxes that are hosted online
$percentage = ($amountremote/$sumamount).tostring("P") 

# Generate information to display on the report
$date = Get-Date -format d
$body = "Total amount of mailboxes: $sumamount <br>"
$body += "Number of local mailboxes: $amountlocal <br>"
$body += "Number of online mailboxes: $amountremote <br><p></p>"
$body += "We are now on <b>$percentage</b> and counting!"

# Generate the report and export to HTML file
$filepath = "C:\Report\migrationprogressreport.html"
ConvertTo-HTML -Body $body -Head “<h1>Mailbox migration progress report for $((Get-OrganizationConfig).Id) on $date</h1>” -Title "Migration progress report" | Out-File -FilePath $filepath

# Generate the report and send by mail
$sender = "sender@domain.com"
$recipients = "recipient@domain.com"
Send-MailMessage -Body $body -Subject “Mailbox migration progress report for $((Get-OrganizationConfig).Id) on $date” -BodyAsHtml -SmtpServer $exchserver -To $recipients -From $sender