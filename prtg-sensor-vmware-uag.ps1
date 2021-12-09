<#
.SYNOPSIS
Outputs a PRTG XML structure with multiple information about UAG

.DESCRIPTION
Get Status and Session-statistics from UAG

.INSTRUCTIONS
1) Copy the script file into the PRTG Custom EXEXML sensor directory C:\Program Files (x86)\PRTG Network Monitor\Custom Sensors\EXEXML
        - prtg-sensor-vmware-uag.ps1 (PowerShell Sensor Script)
3) Create Sensor Custom EXE/ Script Advanced Sensor for each sensor you wish to monitor (refer Scope) and give it a meaniful name
4) Set Parameters for sensor
    - (URL) "https://[VMware-UAG]:9443/rest/v1/monitor/stats"
    - (Username) and (Password) to gain access 
   e.g. -url "https://%host:9443/rest/v1/monitor/stats" -username "%windowsuser" -password "%windowspassword"

.NOTES
Authors: jean-marc.rechsteiner@nios.ch, daniel.scarcella@nios.ch 
Website: https://nios.ch/
Version: 1.1
Date: 1.12.2021

.PARAMETER URL
DNS Name or IP Address of the VMWare UAG

.PARAMETER UserName
The name of the account to be used to access the UAG (mostly admin)

.PARAMETER Password
The password of the account 

.EXAMPLES
C:\PS>prtg-sensor-vmware-uag.ps1 -URL "https://vmware-uag:9443/rest/v1/monitor/stats" -username admin -password TopSecretPW

#>


param
(
    [string]$URL,# = "",
    [string]$Username,# = "admin",
    [string]$Password # = "",
)

#Import Modules
#Set-PowerCLIConfiguration -Scope User -ParticipateInCEIP $true -Confirm:$false
Get-ChildItem -Path "C:\Program Files (x86)\WindowsPowerShell\Modules" -Recurse | Unblock-File
Get-ChildItem -Path "C:\Program Files\WindowsPowerShell\Modules" -Recurse | Unblock-File

#Disable Cert Check
Add-Type @"
    using System;
    using System.Net;
    using System.Net.Security;
    using System.Security.Cryptography.X509Certificates;
    public class ServerCertificateValidationCallback
    {
        public static void Ignore()
        {
            ServicePointManager.ServerCertificateValidationCallback += 
                delegate
                (
                    Object obj, 
                    X509Certificate certificate, 
                    X509Chain chain, 
                    SslPolicyErrors errors
                )
                {
                    return true;
                };
        }
    }
"@
[ServerCertificateValidationCallback]::Ignore();

$base64AuthInfo = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(("{0}:{1}" -f $username,$password)))
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$Request = Invoke-RestMethod -Method Get -Uri $URL -Headers @{Authorization=("Basic {0}" -f $base64AuthInfo)}

Write-Host "<prtg>"

    Write-Host "<result>"
    Write-Host "<channel>Authenticated Session Count</channel>"
    Write-Host "<value>$($Request.accessPointStatusAndStats.authenticatedSessionCount)</value>"
    Write-Host "</result>"

    if ($($Request.accessPointStatusAndStats.overAllStatus.status) -eq "RUNNING"){$OverAllStatus = 1}Else{$OverAllStatus = 0}
    Write-Host "<result>"
    Write-Host "<channel>OverAllStatus</channel>"
    Write-Host "<value>$OverAllStatus</value>"
    Write-Host "<LimitMinError>0.5</LimitMinError>"
    Write-Host "<LimitMode>1</LimitMode>"
    Write-Host "</result>"

    if ($($Request.accessPointStatusAndStats.authentication.authBrokerStatus.status) -eq "RUNNING"){$BrokerStatus = 1}Else{$BrokerStatus = 0}
    Write-Host "<result>"
    Write-Host "<channel>Broker Status</channel>"
    Write-Host "<value>$BrokerStatus</value>"
    Write-Host "<LimitMinError>0.5</LimitMinError>"
    Write-Host "<LimitMode>1</LimitMode>"
    Write-Host "</result>"

    if ($($Request.accessPointStatusAndStats.viewEdgeServiceStats.backendStatus.status) -eq "RUNNING"){$BackendStatus = 1}Else{$BackendStatus = 0}
    Write-Host "<result>"
    Write-Host "<channel>Backend Status</channel>"
    Write-Host "<value>$BackendStatus</value>"
    Write-Host "<LimitMinError>0.5</LimitMinError>"
    Write-Host "<LimitMode>1</LimitMode>"
    Write-Host "</result>"

    if ($($Request.accessPointStatusAndStats.viewEdgeServiceStats.edgeServiceStatus.Status) -eq "RUNNING"){$edgeServiceStatus = 1}Else{$edgeServiceStatus = 0}
    Write-Host "<result>"
    Write-Host "<channel>Edge Service Status</channel>"
    Write-Host "<value>$edgeServiceStatus</value>"
    Write-Host "<LimitMinError>0.5</LimitMinError>"
    Write-Host "<LimitMode>1</LimitMode>"
    Write-Host "</result>"

    foreach ($item in $($Request.accessPointStatusAndStats.viewEdgeServiceStats.protocol))
    {
        write-host "<result>"
        write-host "<channel>$($item.name)</channel>"
        write-host "<value>$($item.sessions)</value>"
        write-host "<CustomUnit>Sessions</CustomUnit>"
        write-host "</result>"
    }

Write-Host "</prtg>"
exit $code 