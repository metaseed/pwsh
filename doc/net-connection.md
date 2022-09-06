https://stackoverflow.com/questions/48198/how-do-i-find-out-which-process-is-listening-on-a-tcp-or-udp-port-on-windows

## get process of a tcp/udp port
Get-Process -Id (Get-NetTCPConnection -LocalPort YourPortNumberHere).OwningProcess
Get-Process -Id (Get-NetUDPEndpoint -LocalPort YourPortNumberHere).OwningProcess