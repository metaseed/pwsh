# https://stackoverflow.com/questions/14351018/powershell-is-there-an-automatic-variable-for-the-last-execution-result
# https://vexx32.github.io/2018/10/19/Store-Last-Output/
# What this does is that any time Out-Default is called, by any function or cmdlet,
# it automatically applies the parameter -OutVariable '__' to the call.
# If you aren't currently aware, Out-Default is the command that all output passes through in PowerShell

# Output is stored in an ArrayList, which is a reference
# force PS to enumerate it before storing elsewhere $($__) or
# Output is stored in an ArrayList.
# manually retrieve the array $__.ToArray().
$PSDefaultParameterValues['Out-Default:OutVariable'] = '__' # use $($__) or $__[0]
function _ {
    $__[0]
}