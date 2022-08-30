Import-Module ActiveDirectory

# Replace PLACE YOUR OU HERE with the OU where the search is needed.

$ADUsers = Get-ADUser -Filter * -SearchBase 'PLACE YOUR OU HERE' -Properties ProxyAddresses

foreach ($ADUser in $ADUsers) {
    
    # Replace contoso.com with your domain to be removed from the user.

    $RemoveProxy = @($ADUser.ProxyAddresses) -like "contoso.com"
    
    if ($RemoveProxy.Count -gt 0)
    {
        Set-Aduser $ADUser -remove @{ProxyAddresses="$RemoveProxy"}
    }

}