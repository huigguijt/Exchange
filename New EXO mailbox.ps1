# Enter variable for the new user
$user = "z.beeblebrox"

# Create the remote mailbox
Enable-RemoteMailbox $user -RemoteRoutingAddress "$user@area365.mail.onmicrosoft.com"

# Create the In-Place Archive
Enable-RemoteMailbox $user -Archive

# Assign licenses to the user
Add-ADGroupMember -Identity "grp_lic_devE3" -Members $user
Add-ADGroupMember -Identity "grp_lic_emsE5" -Members $user