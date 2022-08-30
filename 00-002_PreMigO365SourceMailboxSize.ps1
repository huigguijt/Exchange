<#
Script created by Wortell - Team Porsche for requirements 'O365-O365 keep Domain Name'migratie.
Manual input variables
#>
$ExportSourceMailboxSize="C:\Export\MigrationInputFiles\00-002SourceMailboxSize.csv"
$ExportSourceMailboxLastChanged="C:\Export\MigrationInputFiles\00-002SourceMailboxLastChanged.csv"
$ExportSourceMailboxRegionalConfiguration="C:\Export\MigrationInputFiles\00-002SourceMailboxRegionalConfiguration.csv"

# Create an Export folder
$ChkFolder = "c:\Export\"
$FolderExists = Test-Path -Path $ChkFolder
If ($FolderExists -eq $True) {
Write-Host "Skipping!!! Export folder exists" -ForegroundColor Green
}
Else{ 
New-Item -Path "C:\" -Name "Export" -ItemType "directory"
}

# Create an MigrationInputFiles folder
$ChkFolder = "c:\Export\MigrationInputFiles\"
$FolderExists = Test-Path -Path $ChkFolder
If ($FolderExists -eq $True) {
Write-Host "Skipping!!! MigrationInputFiles folder exists" -ForegroundColor Green
}
Else{ 
New-Item -Path "C:\Export\" -Name "MigrationInputFiles" -ItemType "directory"
}

# Create an MigrationLogOutputFile folder
$ChkFolder = "c:\Export\MigrationLogOutputFiles\"
$FolderExists = Test-Path -Path $ChkFolder
If ($FolderExists -eq $True) {
Write-Host "Skipping!!! MigrationLogOutputFiles folder exists" -ForegroundColor Green
}
Else{ 
New-Item -Path "C:\Export\" -Name "MigrationLogOutputFiles" -ItemType "directory"
}

# MailboxSize plus item count
$mailboxes = Get-EXOMailbox -resultsize Unlimited
$mailboxes | Get-ExoMailboxStatistics | Select-Object DisplayName `
@{Name="TotalItemSizeMB"; Expression={[math]::Round(($_.TotalItemSize.ToString().Split("(")[1].Split(" ")[0].Replace(",","")/1MB),0)}}, `
ItemCount  | Export-CSV $ExportSourceMailboxSize -Delimiter ';' -NoTypeInformation

# Mailbox LastAccess exported
$mailboxes | Select-Object DisplayName,WhenChanged | Export-CSV $ExportSourceMailboxLastChanged -Delimiter ';' -NoTypeInformation

# Mailbox Regional Configuration
$mailboxes | Get-MailboxRegionalConfiguration | Export-CSV $ExportSourceMailboxRegionalConfiguration -Delimiter ';' -NoTypeInformation
