Param(
    [Parameter(Mandatory=$True)]
    [ValidateSet('Reset', 'Change', 'Show')]
    [String]$Mode,
    [Parameter()]
    [String]$InterfaceAlias='Wi-Fi',
    [Parameter()]
    [ValidateSet('IPv4', 'IPv6')]
    [String]$AddressFamily='IPv4',
    [Parameter()]
    [String]$DNSServerAddresses
)


function Get-Interface($InterfaceAlias, $AddressFamily) {
    $AddressFamilyId = Get-AddressFamilyId $AddressFamily
    return Get-DnsClientServerAddress `
        | Where-Object { $_.InterfaceAlias -eq $InterfaceAlias -and $_.AddressFamily -eq $AddressFamilyId }
}

function Get-AddressFamilyId($AddressFamily) {
    switch ($AddressFamily) {
        'IPv4' { return 2 }
        'IPv6' { return 23 }
    }
}

$Interface = Get-Interface $InterfaceAlias $AddressFamily

switch ($Mode) {
    "Reset" {
        Set-DnsClientServerAddress -InterfaceIndex $Interface.InterfaceIndex -ResetServerAddress
        Write-Host "Reseted DNSClientServerAddress"
        Get-Interface $InterfaceAlias $AddressFamily
    }
    "Change" {
        Set-DnsClientServerAddress -InterfaceIndex $Interface.InterfaceIndex -ResetServerAddress
        Set-DnsClientServerAddress -InterfaceIndex $Interface.InterfaceIndex -ServerAddress $DNSServerAddresses
        Write-Host "Changed DNSServerAddresses"
        Get-Interface $InterfaceAlias $AddressFamily
    }
    "Show" {
        Write-Host "Current DNSServerAddresses"
        Get-Interface $InterfaceAlias $AddressFamily        
    }
}
