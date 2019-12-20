# Mezobyte Windows 10 SNMP Install Script
# Installs and configures SNMP

# Setup variables from install run parameters

[CmdletBinding()]
param (
    # SNMP Community
    [Parameter(Mandatory)]
    [string]$community,
    # Manager IPs in a CSV format
    [Parameter(Mandatory)]
    [string]$managers,
    # Gateway parameters
    [Parameter(Mandatory)]
    [string]$gateway
)

# Split entries in csv string in SNMP Managers

$managers = ($managers -split ',').replace(' ','')



<#
 # Install SNMP Windows Service
 #>


Write-Host 'Installing SNMP Feature'
Add-WindowsCapability  -Online -Name 'SNMP.Client~~~~0.0.1.0'

# Add SNMP community
reg add 'HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\services\SNMP\Parameters\ValidCommunities' /v '$community' /t REG_DWORD /d 4 /f | Out-Null 


# Add accepted SNMP managers
ForEach($item in $managers) {
    reg add 'HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\services\SNMP\Parameters\PermittedManagers' /v 2 /t REG_SZ /d '$item' /f | Out-Null 
}


# Restart SNMP Windows Service
Restart-service snmp** 

# Create Firewall Accept Rule
Import-Module NetSecurity
New-NetFirewallRule -Name ICMPv4 -DisplayName 'ICMPv4'  -Description 'ICMPv4' -Protocol ICMPv4 -IcmpType 8 -Enabled True -Profile Any -Action Allow
New-NetFirewallRule -DisplayName 'SNMP' -Direction Inbound -LocalPort 161 -Protocol UDP -Action Allow

