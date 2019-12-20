<#
.SYNOPSIS
    Mezobyte Windows 10 Script to install nxlog
.DESCRIPTION
    Installs nxlog
.EXAMPLE
    PS C:\> nxlog -gateway 192.168.194.254
    Installs NXLog and forwards all WELF Logs to 192.168.194.254 in a GELF format
.INPUTS
    -gateway
    GELF Forwarding IP Destination. Mandatory
    -port
    GELF Forwarding Port. Not Mandatory
    -confdir
    Location to copy dir to. Not Mandatory
.OUTPUTS
    None
.NOTES
    Used by bootstrap script
#>

[CmdletBinding()]
param (
    # SNMP Community
    [Parameter(Mandatory)]
    [string]$gateway,
    # Manager IPs in a CSV format
    [Parameter]
    [string]$port = '12201',
    # Gateway parameters
    [Parameter]
    [string]$confdir = 'C:\Program Files (x86)\nxlog\conf'
)


# Trim trailing dir slash
$confdir = $confdir.trim('\')

# Function to install NXLog application
function install-nxlog {
    Write-Host "Installing NXLog"
    Start-Process msiexec.exe -Wait -ArgumentList '/I nxlog.msi /quiet'
}

function start-nxlog {
    Write-Host 'Starting NXLog Service'
    Start-Service -Name "nxlog"
}

function new-config {
    Write-Host 'Generating NXLog Config'
    $base_file = '.\nxlog.conf.base'
    (Get-Content $base_file) | ForEach-Object {
        $_ -replace '{hostname}', $gateway `
        -replace '{port}', $port
     } | Set-Content "$confdir\nxlog.conf"
}

# Function to copy generated config to default config location
function copy-config {
    Write-Host 'Copying NXLog Config'
    Copy-Item nxlog.conf $confdir
}

install-nxlog
new-config
# copy-config 
start-nxlog