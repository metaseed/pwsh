* gh
gh Get-ChildItem -Online

* reload profile
```
& $profile.CurrentUserAllHosts

* to reload the module after changing:
```
ipmo metaseed.git -fo
import-module metaseed.git -force
rmo metaseed.git
```
* copy current dir
```
# pwd: print work directory
(pwd).path|scb
note: (pwd).path|clip when gcb would return [path, '']
clip is C:\WINDOWS\system32\clip.exe
scb (gl).path
# scb: set-clipboard; gcb: get-clipboard; gl: get-location
scb (pwd).path
pwd|scb
gl|scb
pwd and gl is the aliases of get-location
```

* make dir and change to that dir
```
# mcd is a function in profile
mcd dir
nsl dir (new and set location)
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
* find cmd of nodejs
```
$notInstalled = (npm list -g vsts-npm-auth)[1] -like "*(empty)*"
```
* grep, findstr
select-string (sls)

* get Verb
get-verb |%{$_.verb}|? {$_ -like '*start*'}
get-verb |foreach-object {$_.verb}|where-object{$_ -like '*start*'}
get-verb |% verb|? {$_ -like '*start*'}
get-verb|? verb -like *start*

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

* get date to be used in file path
> get-date -Format FileDate
> 20210526

> get-date -f "yyMMdd_HHmmss"
> 220616_115046
* get time zone relevant to UTC
get-date -f zz
-05 (day time saver included)
could also call: get-timezone
(UTC-06:00) Central Time (US & Canada)

* more page
ga | oh -p
get-command | out-host -paging
* first 10
gcm|select -first 10
* clear screen
cls (remove all content)
ctrl+L (just scroll all content to top)

F8: complete command line from history
remove cmd history: Remove-Item (Get-PSReadlineOption).HistorySavePath
Ctrl+]: goto Brace (){}[]
ctrl-l: clear screen
alt-.: last argument of previous command
ctrl-space: MenuComplete

## peek function implementation
gcm mkdir |% scriptblock
(Get-Command mkdir).ScriptBlock
gcm mkdir|% scriptblock| Set-Content c:\tmp\tt.ps1; code C:\tmp\tt.ps1

## beep
1. beep-DingDong: just the Ctrl+G: inclose the Ctrl+G in a string and output it. (type ctrl+g in console and copy it to file: )
1. [Console]::Beep(), [Console]::Beep(1000,1000)

* show unicode: [char]0x2261

## write format table to host
  $process = [System.Diagnostics.Process]::GetCurrentProcess()
  $process |Format-Table | Out-String|%{ Write-Verbose $_}

## execute job and capture scope variables
$a = 10
$b = &{
write-host $a
play-ring
}&
receive-job $b

## foreach parallel write to console work
1,2,3|% -Parallel {write-host $_}
note: in job we can not directly write to console
* modify outside variable
$a = @{}
1,2,3|% -Parallel {write-host $_; ($using:a).b = $_}

## open 'this pc'
explorer file:
* open c:
explorer c:
## -contains operator
work on list not on string
'abc' -contains 'a' not work
'abc'.contains('a') work
'abc','e','fd' -contains 'fd' work

## web browser
saps msedge or Start-Process microsoft-edge://
saps chrome

# resource monitor
resmon
taskmgr

## use embedded module inside Module
* one way: export all function(from embedded module or rootModule) inside FunctionsToExport. (could not use  Export-ModuleMember in psm1)
* another way: remove the root module and put it inside the  `NestedModules     = @('Metaseed.Terminal.psm1','_bin\TerminalBackground.dll')`
## create pwsh dotnet module
```
dotnet new -i Microsoft.PowerShell.Standard.Module.Template
dotnet new psmodule
dotnet build
Import-Module "bin\Debug\netstandard2.0\$module.dll"
Get-Module $module
```
```
snl Utility
dotnet new psmodule
```

## show all properties of obj
gi c:\app|format-list -p(roperty) *

## open solution
saps (find-fromParent *.sln)

## ANSI escape sequence
https://duffney.io/usingansiescapesequencespowershell/#:~:text=ANSI%20escape%20sequences%20are%20often,character%20representing%20an%20escape%20character.
https://www.lihaoyi.com/post/BuildyourownCommandLinewithANSIescapecodes.html

## clear screen
ctrl-l just scroll the screen
cls clear the buffer
## check windows version
winver

## create file from clipboard
gcb > 1.txt

## quickly open the 'optional features' dialog
type `optionalfeatues` in terminal

## new/delete/rename/copy/paste/view-property file/dir
ni test
ni test -ty d # type directory
ri test
mi test test1
copy test test2
get-itemProperty *

view sizes in folder `a wizTree -- $pwd`

## get computer info
Get-ComputerInfo -pro *processor*
Get-ComputerInfo
systemInfo.exe

## pwsh webs
https://ironscripter.us/
https://jdhitsolutions.com/blog/

## open recycle bin
start shell:RecycleBinFolder

## show psreadline helper
Get-PSReadlineKeyHandler


## file management
cd sl
ga cd
ga -d set-location
ga -d Get-ChildItem

z location
https://github.com/vors/ZLocation

start c:\app
https://github.com/mgunyho/tere

shortcuts: search, home, end

ni test
ni test -ty d # type directory
ri test
mi test test1

ni test_safe
ris test_safe # remove item safely
gri -OriginalPathRegex 'safe'
gri -OriginalPathRegex 'test'|rri # restore-recycledItem; get-recycledItem
gci '*safe'

copy test test2
ga gp
gp *
start .

## PSFzf
https://github.com/kelleyma49/PSFzf
c-t: