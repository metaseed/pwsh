* ghp
ghp -o ls
ghp Get-ChildItem -Online

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
# get sub dirs
gci -at d
get-childItem -attribute directory
gci -n
get-childItem -Name # only show dir name

# pwd: print work directory
> gl|scb
> gcb

$pwd is a context variable
''pwd' and 'gl' is the alias of get-location
(pwd).path|scb
(pwd).gettype()
note: (pwd).path|clip when gcb would return [the-path, ''], it's an string array

clip is C:\WINDOWS\system32\clip.exe # gcm clip
scb (gl).path
gl|gp|fl #get-location|get-property|format-list
# view all properties of an obj
gl|select -p *|fl #get-location|select-object -property *|format-list
> note: gl|gm # get-location|get-memeber # will list all members
> (gl).gettype() # to get the type

# scb: set-clipboard; gcb: get-clipboard; gl: get-location
scb (pwd).path
pwd|scb
gl|scb
pwd and gl is the aliases of get-location
```
## create file from clipboard
gcb > 1.txt

* make dir and change to that dir
```
# Set-LocationNew  is a function in Utility module
sln dir # set to location, create new dir if not exist)
```

* cmd's where command

```
get-command code
(gcm code).source
gcm code|select -p source
get-command code | select-object -property source
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
[void]2


* get all env variables start with
gci env:planck*

* get cmd dir
gcm code |% source|split-path
gcm code | foreach-object source\split-path
gcm code|select -exp source|split-path # note for `select` -exp -p is different

gcm code|select -p source
Source
------
C:\Program Files\Microsoft VS Code\bin\code.cmd
gcm code|select -exp source
C:\Program Files\Microsoft VS Code\bin\code.cmd

get-command code|select-object -expandProperty Source|Split-Path
* select vs %
gcm code|% source # string
gcm code|select source # custom obj

* copy file content to clipboard
gc file|scb
get-content file|scb

* get date to be used in file path
get-date -f filedate
> get-date -Format FileDate
> 20210526

> get-date -f yyMMdd_HHmmss # MM is month, mm is minute, HH is 24h, hh is 12h
> 220616_115046
* get time zone relevant to UTC
get-date -f zz
-05 (day time saver included) houston
+01 paris
could also call: get-timezone
(UTC-06:00) Central Time (US & Canada)
(UTC+01:00) Brussels, Copenhagen, Madrid, Paris

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
Get-PSReadLineOption|% HistorySavePath|code
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
> about code has problem, it's not run in background, because it is $b = result&
$a = 10
$b = Start-Job -ScriptBlock {
    Write-Host $using:a
    play-ring
}
receive-job $b

## foreach parallel write to console work
1,2,3|% -Parallel {write-host $_}
note: in job we can not directly write to console
* modify outside variable
$a = @{}
1,2,3|% -Parallel {write-host $_; ($using:a).b = $_}

## open 'this pc'
explorer file:
start file:
* open c:
explorer c:
start c:
## -contains operator
work on list not on string
'abc' -contains 'a' not work
'abc'.contains('a') work
'abc','e','fd' -contains 'fd' work

## web browser
saps msedge or Start-Process microsoft-edge://
saps chrome
start chrome
sa firefox

# open file/dir from pipeline in vscode
> vscode does not accept parameter from stdin,
> so it's not valid: `gi *.json|code`

gci|%{code $_}

# how to open multiple files from command line
```pwsh
gi *.json |%{ code $_ }
```

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
sln Utility
dotnet new psmodule
```

## get item is directory or file
gci |?{ $_ -is [IO.DirectoryInfo]} # [IO.FileInfo]

## show all properties of obj
gi c:\app|format-list -p(roperty) *
gi c:\app|fl -p * # ft: format-table
gi c:\app|select -p* #select-object

## open solution
sa (find-fromParent *.sln)
> `find-fromParent *.sln|sa will` not work, as the `sa` does not accept pipeline arg
find-fromParent *.sln|ii
find-fromParent *.sln|invoke-item # to Opens a file or directory using its default associated application

## ANSI escape sequence
https://duffney.io/usingansiescapesequencespowershell/#:~:text=ANSI%20escape%20sequences%20are%20often,character%20representing%20an%20escape%20character.
https://www.lihaoyi.com/post/BuildyourownCommandLinewithANSIescapecodes.html

## clear screen
ctrl-l just scroll the screen
cls clear the buffer

## check windows version
winver

## quickly open the 'optional features' dialog
type `OptionalFeatures` in terminal

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
gin # alias of Get-ComputerInfo
gin -pro *processor*
systemInfo.exe
systeminfo|? {$_ -like '*host*'}
systeminfo|? {$_ -match 'host|memory|zone|OS'}

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

* zip (compress)
Compress-Archive
ca listOfFilesOrFolders z.zip


ni test_safe
ris test_safe # remove item safely
gri -OriginalPathRegex 'safe'
gri -OriginalPathRegex 'test'|rri # restore-recycledItem; get-recycledItem
gci '*safe'

copy test test2
ga gp
gp *
start .
* rename-item
ga -d rename-item
rni test test1 # rename test to test1


# to show verbose for all sub function calls in module
 $VerbosePreference = 'Continue'

# how to monitor log file
tail -f logfile| bat --paging=never -l log
gc logfile -wait -tail 10

## run vscode / code in admin
https://code.visualstudio.com/docs/setup/windows#_unable-to-run-as-admin-when-applocker-is-enabled
https://github.com/microsoft/vscode/issues/185057

> `code --no-sandbox`

# split and combine file of fix size
`a 7z a -- -h`
Usage: 7z <command> [<switches>...] <archive_name> [<file_names>...] [@listfile]

split files:
// 1G
// large_file.iso: original large file
// large_file.7z: name used to append '.001'...
// -v1000m: partition size 1G
// a : Add files to archive
7z a -v1000m large_file.7z large_file.iso

combine files:
copy /b file1 file2 file3 file
or
7z x large_file.7z.001

## navigating inside location history
```pwsh
cd - # previous location
cd + # next location
`sl` or `sl ~` change to home directory
```

# write-output vs write-host
ga echo # write-output
write-output "hello"| out-file kk.txt
"hello"| out-file kk.txt

Write-Output is Stream 1
Write-Error (Stream 2) → Error messages
Write-Warning (Stream 3) → Warnings
Write-Verbose (Stream 4) → Verbose logging
Write-Debug (Stream 5) → Debug messages

Write-Output sends data to the pipeline (it may or may not reach the host).
Output can be redirected to files, variables, or different streams.

# ForEach-Object: if the returned obj is enumerable, its content will be forwarded to the next pipe instead of the enumerable.
 @(@(1,2),@(3,4))|%{write-host $_}
 1 2
 3 4
 @(@(1,2),@(3,4))|%{$_.getenumerrator()}|%{write-host $_}
 1
 2
 3
 4

 # ForEach-Object: return nothing r $null to filter it out
@(1,2,3,4)|%{if($_ -lt 3) {return $_}else {return}}
@(1,2,3,4)|%{if($_ -lt 3) {return $_}else {return $null}}
> '%': it's the map operator with filter capability

# expression in function will be trait as one of returned value
function A{'a';'b';return 'c'}
a
b
c
> to prevent the expression to be the return value, assigned it to a var or
> [void]expression or expression|out-null

# parenthesis `()` is important
 Test-Admin ? "a":"b" # True
(Test-Admin) ? "a":"b" # a
## Ternary operator does not work with cmd invoke as condition directly
> https://github.com/PowerShell/PowerShell/issues/25194
function A {$true}
A ? 'a':'b'
the simplest walkaround current is:
(A)?'a':'b'

gc

(1) will output 1 to stream-out
write-out 1
(1);(2);($a = 3)
1
2
3

## output from expression
$v = 1 # sets $v to 1 and output nothing
($v = 1) # sets $v to 1 and output assigned value
($v) # var in expression
1
($a=7);$b = 2;($c=3)
7
3
$a = $b = 1 # a,b are 1

## we can use () to make a string as command and adjust command execution precedency
git checkout (fgb)
> it's also output from expression and
> it will trait 'fgb' as a command instead of a string, execute `fgb` first and then checkout the branch returned from the cmd.
> the `fgb` will return the git branch name with fuzzy search.
>
# open system settings
opss envVar
opss OptionalFeatures
opss ProgramsAndFeatures
opss DeviceManager

# open know folders
opkf startup
opkf RecycleBinFolder
opkf Downloads
opkf DocumentsLibrary
# .? null conditional operator
$a = 'dddd'
$a.length # 4
$a?.length # 0

## explanation
> https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_operators?view=powershell-7.5#null-conditional-operators--and-

'?' is teated as part of var name, since it can be part of var name, we need to use:
${a}?.length # 4, ${a} is the way to force query 'a' as var name
or
($a)?.length # 4

$a = 1..10
${a}?[0]

# configPsFzf
for the shortcuts of searching


# make sure the output is a array
$a = 1
@($a)
,1
$a = ,1
@($a)
> use @(,$a) to wrapper array inside array
,1
> @($var) will return a new array, if $var is enumerable, the items get from the enumerable $var
>
```
$a = [System.Collections.ArrayList]::new()
$a.Add(1)
$a.Add(1)
$a.gettype() # arraylist
$b = @($a)
$b.gettype() #
```

# how to find the target of a hardlink

```
fsutil hardlink list M:\app\wiztree_4_10_portable\size.exe
```
\App\wiztree_4_10_portable\size.exe
\App\wiztree_4_10_portable\WizTree64.exe

> note: we can not use `gi`, `gi M:\app\wiztree_4_10_portable\size.exe|fl`, the`Target` property is empty,
> because window does not trace the oder of the file name creation to the content, and it's two file names to same data on disk.