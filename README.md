Check WSUS Health Script for NSClient++ and Nagios
====

 
## Add the PowerShell script to NSClient++
Still in the nsclient.ini file, we will declare the external scripts that we want to use. In my example, this will be the PowerShell script "check-dhcp-failover.ps1". It is imperative to store it in the "scripts" directory of the NSClient ++ installation folder.

Here is the line of code to include:
```
[/settings/external scripts/scripts]
check_wsus_health = cmd /c echo scripts\check-dhcp-failover.ps1; exit($lastexitcode) | powershell.exe -command -
```

Please be sure that ```CheckExternalScripts=enabled```

## Add the Check to Nagios
