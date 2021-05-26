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