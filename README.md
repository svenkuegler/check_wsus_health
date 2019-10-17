Check WSUS Health Script for NSClient++ and Nagios
====

 
## Add the PowerShell script to NSClient++
Modify nsclient.ini file, to declare the external scripts. It is imperative to store it in the "scripts" directory of the NSClient++ installation folder.

Here is the line of code to include:
```
[/settings/external scripts/scripts]
check_wsus_health = cmd /c echo scripts\check_wsus_health.ps1; exit($lastexitcode) | powershell.exe -command -
```

Please be sure that ```CheckExternalScripts=enabled```

## Add the Check to Nagios

__Command Template__

```
define command{
        command_name    check_wsus_health
        command_line    $USER1$/check_wp_update $ARG1$
        }
```

__Service Check__
```
define service{
        use                     generic-service
        host_name               wsusserver
        service_description     WSUS Healthcheck
        check_command           check_wsus_health
        }
```