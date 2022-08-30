$user = "voornaam.achternaam"
Enable-RemoteMailbox -Identity $user -RemoteRoutingAddress ($user+"tenant.onmicrosoft.com")