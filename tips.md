* copy current dir
```
# pwd: print work directory
(pwd).path|clip
scb (gl).path 
# scb: set-clipboard; gcb: get-clipboard; gl: get-location
scb (pwd).path
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
gcm code
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

* hide output
"aa"|out-null
"aa > $null

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
get-date "zz"
-05 (day time saver included)
could also call: get-timezone 

* more page 
gcm | oh -p
get-command | out-host -paging
* first 10
gcm|select -first 10