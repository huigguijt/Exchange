Get-MoveRequest

Get-MigrationUser

Get-MoveRequest | Get-MoveRequestStatistics

# Voortgang van de batches
Get-MigrationUser -BatchId "BigBang" | Get-MoveRequestStatistics
Get-MigrationUser -BatchId "BigBang" -ResultSize unlimited | where {$_.status -notlike "Completed"} | Get-MoveRequestStatistics
Get-MigrationUser -BatchId "Groep2b" | Get-MoveRequestStatistics

# Overzicht van errors
Get-MigrationUserStatistics -Identity "kim.dekkers@tilburg.nl" -IncludeReport | Format-List Status,Error,Report
Get-MigrationUser -BatchId bigbang -Status failed| Get-MigrationUserStatistics | select identity, status, error | Out-GridView
Get-MigrationUser -BatchId bigbang -Status failed| Get-MigrationUserStatistics | select identity, status, error | Export-Csv c:\temp\migrationerrors.csv -NoTypeInformation
# Mislukte mailboxen herstarten
Get-MigrationUser -BatchId bigbang -Status failed | Start-MigrationUser

# Dubbele migrationusers verwijderen
Get-MigrationUser -Identity charles.dickens@tilburg.nl | where {$_.batchid -eq "bigbang"}
Remove-MigrationUser -Identity 89151169-f690-403f-b124-cf56d448e7cf
Get-MigrationUser -BatchId groep2 | Get-MigrationUser | where {$_.batchid -eq "bigbang"} |  ft identity, batchid, guid
Get-MigrationUser -BatchId "groep2b" | Get-MigrationUser |  ft identity, batchid, guid




Get-MoveRequest -BatchName "MigrationService:Performancetest_100" | Get-MoveRequestStatistics
get-migrationbatch test06 | fl
Get-MigrationUserStatistics -Identity exchtest04@tilburg.nl -IncludeReport | fl Status,Error,Report
get-migrationuser exchtest06@tilburg.nl | Get-MoveRequestStatistics

Get-MigrationBatch -Identity performancetest_100 | Select-Object TotalCount,ActiveCount,FailedCount,SyncedCount

Get-MoveRequestStatistics -Identity "Identity" | select Displayname, status, starttimestamp, InitialSeedingCompletedTimestamp, LastSuccessfulSyncTimestamp, PercentComplete, TotalMailboxSize, ItemsTransferred | ft
Get-MoveRequest -BatchName "MigrationService:Performancetest_100" | Get-MoveRequestStatistics | select Displayname, status, starttimestamp, InitialSeedingCompletedTimestamp, LastSuccessfulSyncTimestamp, PercentComplete, TotalMailboxSize, ItemsTransferred | Out-GridView