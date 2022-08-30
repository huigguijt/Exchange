# Connect to Exchange session
Add-PSSnapin Microsoft.Exchange.Management.PowerShell.SnapIn

$Time = Get-Date
$computername = ([System.Net.Dns]::GetHostByName(($env:computerName))).Hostname
$mailbox = Get-Mailbox -RecipientTypeDetails UserMailbox | Select-Object PrimarySmtpAddress
$RandomMailbox = Get-Random -InputObject $mailbox | ft -HideTableHeaders | Out-String

Send-MailMessage -From $RandomMailbox -To huig.guijt@wortell.nl -Subject 'Testbericht' -Body "Dit is een periodiek testbericht, verzonden vanaf $computername om $Time" -SmtpServer srvmail