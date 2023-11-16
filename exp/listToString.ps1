$a = 1,2,3
"$a" # 1 2 3
$a.ToString() # System.Object[]
# so the string interpolation does not use ToString method
[string]$a # 1 2 3
# so it use the type conversion
# https://learn.microsoft.com/en-us/powershell/scripting/lang-spec/chapter-06?view=powershell-7.3#68-conversion-to-string