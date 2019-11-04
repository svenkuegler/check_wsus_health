
<#PSScriptInfo

.VERSION 1.1.0

.GUID f6224bba-6b59-4c76-b22a-8da7f21b39d4

.AUTHOR Sven Kuegler

.COMPANYNAME None

.COPYRIGHT None

.TAGS Nagios Check WSUS WsusUtil

.LICENSEURI https://github.com/svenkuegler/check_wsus_health/blob/master/LICENSE

.PROJECTURI https://github.com/svenkuegler/check_wsus_health

.ICONURI 

.EXTERNALMODULEDEPENDENCIES None

.REQUIREDSCRIPTS None

.EXTERNALSCRIPTDEPENDENCIES None

.RELEASENOTES
Version:        1.0
  Author:         Sven Kuegler
  Creation Date:  10.10.2019
  Purpose/Change: Initial script development
  Version:        1.1
  Author:         Sven Kuegler
  Creation Date:  21.10.2019
  Purpose/Change: Output Message Changes

#> 

#Requires -Module None
#Requires -Version 2
#Requires -RunAsAdministrator

<#
.SYNOPSIS
Check WSUS Health

.DESCRIPTION 
Check WSUS Health

#>
[CmdletBinding()]
Param(
  [Parameter(Mandatory=$false)]
   [switch]$RunWsusUtil
)

# --------------------------------------------------------------------------------------------

# Parameter to run WsusUtil
[Boolean]$RunCheckHealth = $RunWsusUtil

# Path to WsusUtil.exe
[String]$WsusUtilPath = "C:\Program Files\Update Services\Tools"

# Date of Yesterday
$Date = (Get-Date).AddDays(-1)

# --------------------------------------------------------------------------------------------

if($RunCheckHealth -eq $True) {
    if(Test-Path $WsusUtilPath) {
        # Run Healthcheck
        # Set-Location -Path $WsusUtilPath
        Start-Process -FilePath $WsusUtilPath"\WsusUtil.exe" -ArgumentList "checkhealth"
    }        
}

# Get Results from Eventlog
$results = Get-EventLog -Source "Windows Server Update Services" -LogName Application -After $Date.ToShortDateString() -EntryType Warning,Error

# Filter Results
$warningCount = ($results | Where-Object {$_.EntryType -eq "Warning"}).Length 
$errorCount = ($results | Where-Object {$_.EntryType -eq "Error"}).Length

# Return Results
if ($errorCount -gt 0) {
    Write-Host "CRITICAL: There are "$errorCount" Errors (since " $Date ") logged! For more information look into the Event Log!"
    exit 2 #Returns CRITICAL STATUS
}
elseif ($warningCount -gt 0) {
    Write-Host "WARNING: There are "$warningCount" Warnings (since " $Date ") logged! For more information look into the Event Log!"
    exit 1 #Returns WARNING STATUS
}
else {
    Write-Host "OK: No Errors or Warnings logged"
    exit 0 #Returns OK STATUS
}
