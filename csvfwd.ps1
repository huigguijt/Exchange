$fwds = Import-csv "C:\Users\Guijt\OneDrive - Wortell\Documenten\Aeres\fwd\Overzicht MBOlifesciences medewerkers vs Aeres.csv"
foreach ($fwd in $fwds) {
    Write-Host "setting forward for $fwd"
    Set-Mailbox -Identity $fwd.Nordwin -ForwardingSMTPAddress $fwd.Aeres
}


$fwds = Import-csv "C:\Users\Guijt\OneDrive - Wortell\Documenten\Aeres\fwd\Overzicht leerlingen Aeres vs Nordwin.csv"
foreach ($fwd in $fwds) {
    Write-Host "Currently checking $fwd"
    Get-Mailbox $fwd.Nordwin | Select-Object Displayname,*forward* | Export-Csv "C:\Users\Guijt\OneDrive - Wortell\Documenten\Aeres\fwd\fwdcheck.csv" -NoTypeInformation -Append
}