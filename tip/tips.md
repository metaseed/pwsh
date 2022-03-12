* copy current dir
```
# pwd: print work directory
(pwd).path|scb
note: (pwd).path|clip when gcb would return [path, '']
scb (gl).path 
# scb: set-clipboard; gcb: get-clipboard; gl: get-location
scb (pwd).path
pwd|scb
gl|scb
```

* make dir and change to that dir
```
# mcd is a function in profile
mcd dir
```

* cmd's where command

```
get-command code
(gcm code).source
```
* exec cmd's command in pwsh and get result
```
cmd /c where code
```
* grep, findstr
select-string (sls)

* get Verb
get-verb |%{$_.verb}|? {$_ -like '*start*'}
get-verb |% verb|? {$_ -like '*start*'}
get-verb|? verb -like '*start*'

* hide command error 
// run below command in a none git dir
// 0: success
git status 2>$null; $LASTEXITCODE

* hide output
"aa"|out-null
"aa" > $null

* get all env variables start with
gci env:planck*

* get cmd path
gcm code |% source|split-path
gcm code|select -exp source|split-path 
get-command code|select-object -expandProperty Source|Split-Path

* copy file content to clipboard
gc file|scb

* get date in file path
get-date -Format FileDate
20210526
* get time zone relevant to UTC
get-date -f "zz"
-05 (day time saver included)
could also call: get-timezone 
(UTC-06:00) Central Time (US & Canada)

* more page 
gcm | oh -p
get-command | out-host -paging
* first 10
gcm|select -first 10
* clear screen 
cls
ctrl+L

## peek function implementation
gcm mkdir |% scriptblock
(Get-Command mkdir).ScriptBlock
gcm mkdir|% scriptblock| Set-Content c:\tmp\tt.ps1; code C:\tmp\tt.ps1 

## beep
1. just the Ctrl+G: inclose the Ctrl+G in a string and output it. 
1. [Console]::Beep(1000,1000)