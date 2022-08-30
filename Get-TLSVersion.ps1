function Get-TLSVersion {
    
# Retrieve a list of all Exchange servers
$exchangeserver = Get-ExchangeServer

# List all supported TLS levels for each server
Invoke-Command -ComputerName $exchangeserver -ScriptBlock

    {

    [Net.ServicePointManager]::SecurityProtocol

    }

}