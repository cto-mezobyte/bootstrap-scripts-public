# Mezobyte Windows 10 Monitoring Bootstrap Script
# Installs and configures SNMP, nxlog, zt

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

<#
 # Initialize
 #>

 New-Item -Path . -Name 'includes'