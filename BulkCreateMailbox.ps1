﻿$Users = Import-csv "C:\Users\admin_huig.AREA365\Documents\users.csv"
$Users | ForEach-Object {Enable-RemoteMailbox -identity $_.user -PrimarySmtpAddress $_.email -RemoteRoutingAddress ($_.user+"@area365.mail.onmicrosoft.com")}