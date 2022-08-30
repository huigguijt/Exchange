#Maak een nieuwe managementrole in Exchange met permissie voor alle gebruikers om distributiegroepen te beheren waarvan de gebruiker eigenaar is.

New-ManagementRole -Name "Manage-MyDGs" -Parent "Distribution Groups"
Get-ManagementRoleEntry "Manage-MyDGs\*" | Where {$_.Name -ne "Get-Recipient" -and $_.Name -ne "Update-DistributionGroupMember" -and $_.Name -ne "Add-DistributionGroupMember"-and $_.Name -notlike "Get-*Group*"} | Remove-ManagementRoleEntry -Confirm:$false
New-RoleGroup -Name "Self-Managed Distribution Group Management" –Description "Members of this management role group can update the members of groups they are the managers of." -Roles "Manage-MyDGs"
Set-ManagementRoleAssignment "Manage-MyDGs-Self-Managed Distribution Group Management" -RecipientRelativeWriteScope MyDistributionGroups
Add-ADGroupMember "Self-Managed Distribution Group Management" "Domain Users"