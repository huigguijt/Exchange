$mbxs = Get-EXOMailbox -ResultSize unlimited

foreach ($mbx in $mbxs) {
    Get-MailboxStatistics -Identity $mbx.Address | Select-Object Displayname,@{name=”TotalItemSize (MB)”;expression={[math]::Round((($_.TotalItemSize.Value.ToString()).Split(“(“)[1].Split(” “)[0].Replace(“,”,””)/1MB),2)}},ItemCount,MailboxGuid | Export-Csv -Path "C:\Users\Guijt\OneDrive - Wortell\Documenten\Aeres\Stats 18-8\nbmbxsize.csv" -Delimiter ";" -Append -NoTypeInformation
    #Get-MailboxStatistics -Identity $mbx.Address | Select-Object Displayname,@{name=”TotalItemSize (MB)”;expression={[math]::Round( `($_.TotalItemSize.ToString().Split(“(“)[1].Split(” “)[0].Replace(“,”,””)/1MB),2)}},ItemCount,MailboxGuid #| Export-Csv -Path "C:\Users\Guijt\OneDrive - Wortell\Documenten\Aeres\Stats 18-8\nbmbxsize.csv" -Delimiter ";" -Append -NoTypeInformation
}

$mbxs | Measure-Object

get-mailbox simonveenstra@mbolifesciences.nl | fl
Get-MailboxStatistics simonveenstra@mbolifesciences.nl | fl

(Get-MailboxStatistics -Identity simonveenstra@mbolifesciences.nl).TotalItemSize.Value.ToGB()