#Requires -version 2
#Requires -RunAsAdministrator

<#
.SYNOPSIS
  Check WSUS Health

.DESCRIPTION
  Check WSUS Health

.PARAMETER $RunWsusUtil
  Runs WsusUtil.exe checkhealth before requesting Logs

.OUTPUTS
  Simple Message, finished with Nagios compatible exit codes
   0 = OK
   1 = WARNING
   2 = CRITICAL
   
.NOTES
  Version:        1.0
  Author:         Sven Kügler
  Creation Date:  10.10.2019
  Purpose/Change: Initial script development
  
.EXAMPLE
  -
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
[String]$Date = (Get-Date -Format "dd.MM.yyyy").AddDays(-1)

# --------------------------------------------------------------------------------------------

if($RunCheckHealth -eq $True) {
    if(Test-Path $WsusUtilPath) {
        # Run Healthcheck
        # Set-Location -Path $WsusUtilPath
        Start-Process -FilePath $WsusUtilPath"\WsusUtil.exe" -ArgumentList "checkhealth"
    }        
}

# Get Results from Eventlog
$results = Get-EventLog -Source "Windows Server Update Services" -LogName Application -After $Date -EntryType Warning,Error

# Filter Results
$warningCount = ($results | Where-Object {$_.EntryType -eq "Warning"}).Length 
$errorCount = ($results | Where-Object {$_.EntryType -eq "Error"}).Length

# Return Results
if ($errorCount -gt 0) {
    Write-Output "CRITICAL: There are " $errorCount " Errors (" $Date ") logged!"
    exit 2 #Returns CRITICAL STATUS
}
elseif ($warningCount -gt 0) {
    Write-Output "WARNING: There are " $warningCount " Warnings (" $Date ") logged!"
    exit 1 #Returns WARNING STATUS
}
else {
    Write-Output "OK: No Errors or Warnings logged"
    exit 0 #Returns OK STATUS
}