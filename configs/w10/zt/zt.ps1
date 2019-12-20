<#
.SYNOPSIS
    Mezobyte Windows 10 Script to install/configure zt
.DESCRIPTION
    Installs/Configures ZT
.EXAMPLE
    PS C:\> zt.ps1 -network am37asd36la
    Installs Zerotier and joins the network ID 'am37asd36la'
.INPUTS
    -network
    Specifies Network ID(s) to join
.OUTPUTS
    None
.NOTES
    Used by bootstrap script
#>

[CmdletBinding()]
param (
    [Parameter(Mandatory)]
    [string]$network
)

$network = ($network -split ',').replace(' ','')

function install-zt {
    Write-Host "Installing ZT"
    Start-Process msiexec.exe -Wait -ArgumentList '/package zt.msi /qn /norestart '
}

function new-ztnet {
    # Wait until ZT service is listening
    $test_loop = 0
    while($test_loop -ne 1){
        Write-Host 'Testing Local ZT Port'
        $res = Test-NetConnection -ComputerName '127.0.0.1' -Port 9993 -InformationLevel Detailed
        if ($res.TcpTestSucceeded -eq $true) {
            Write-Output 'Local ZT Port Reachable'
            $test_loop = 1
        }
        Else {
            Write-Output 'Could not reach local ZT port'
        }
    }
    # Add each network from $network
    foreach($net in $network) {
        Write-Host "Joining ZT Network $net"
        Start-Process -FilePath '.\zt-join.bat' -Wait -ArgumentList "$net" -Verb RunAs
    }
}

function start-zt {
    Write-Host "Starting ZT Service"
    Start-Service -Name 'ZeroTierOneService'
}

install-zt
start-zt
new-ztnet