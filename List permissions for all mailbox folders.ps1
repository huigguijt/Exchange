$mbx = "Huig Guijt"
$permissions = @()
$Folders = Get-MailboxFolderStatistics $mbx | % {$_.folderpath} | % {$_.replace(“/”,”\”)}
$list = ForEach ($F in $Folders)
   {
    $FolderKey = $mbx + ":" + $F
    $Permissions += Get-MailboxFolderPermission -identity $FolderKey -ErrorAction SilentlyContinue | Where-Object {$_.User -notlike “Default” -and $_.User -notlike “Anonymous” -and $_.AccessRights -notlike “None”}
   }
$permissions