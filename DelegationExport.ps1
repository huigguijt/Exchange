﻿Get-Mailbox -resultsize unlimited | Get-MailboxPermission | where {$_.user.tostring() -ne "NT AUTHORITY\SELF" -and $_.IsInherited -eq $false} | Select Identity,User,@{Name='AccessRights';Expression={[string]::join(', ', $_.AccessRights)}}
   | Export-Csv -NoTypeInformation mailboxpermissions.csv -Delimiter ";"