<# 
This script creates Office 365 mailboxes within a hybrid environment for users listed in a csv file.
The csv file should at least mention the column "account" and optionally "aliasses".

Huig.Guijt@Wortell.nl
#>

# Select csv file for importing user objects
$Users = Import-csv "C:\Users\adm_huigguijt\Documents\Import\testlist.csv" -Delimiter ";"

# Retrieve the tenantname
$tenant = $((Get-OrganizationRelationship).domainnames)

$Users | ForEach-Object {
    # Create an Office 365 mailbox
    Enable-RemoteMailbox -identity $_.account -RemoteRoutingAddress ($_.account+"@$tenant")
    # Add the current primary addres as an alias
    Set-RemoteMailbox -Identity $user.account -EmailAddresses @{Add=$user."primary account"}
    # Add the current aliasses
    Set-RemoteMailbox -Identity $user.account -EmailAddresses @{Add=$user.Aliasses}
    
}