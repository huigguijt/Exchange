#Global to Universal
get-adgroup -Filter * -SearchBase "OU=Groups,DC=lab,DC=area365,DC=nl" | Set-ADGroup -GroupScope Universal

#Mailenable security groups without mail
$group = get-adgroup -filter * -SearchBase "OU=Groups,DC=lab,DC=area365,DC=nl" -properties mail | where{($_.mail -eq $Null) -and ($_.groupcategory -eq "Security")}
Enable-DistributionGroup $group.name