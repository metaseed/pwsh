https://docs.microsoft.com/en-us/powershell/scripting/developer/module/importing-a-powershell-module?view=powershell-7.2#implicitly-importing-a-module-powershell-30
currently we use implicitly module importing: 
modules are imported automatically when any cmdlet or function in the module is used in a command. This feature works on any module in a directory that is included in the value of the PSModulePath environment variable.

when add new function into a module, we need to increase the module version in it's psd1 file. otherwise function will not be included.

> rebuilds the command cache and re-examines all modules in all PowerShell default locations
> so the implicitly auto-import module-command would work
Get-Module -ListAvailable -Refresh > $null

> to make implicitly import work, we need:
list functions or cmdlets in psd1
or in psm1, directly exportmodulememeber and give a function or cmdlet name directly as string, note: if the name is a variable is not work.