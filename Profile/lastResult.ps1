# https://stackoverflow.com/questions/14351018/powershell-is-there-an-automatic-variable-for-the-last-execution-result
# https://vexx32.github.io/2018/10/19/Store-Last-Output/
$PSDefaultParameterValues['Out-Default:OutVariable'] = '__' # use $($__) or $__[0]
# What this does is that any time Out-Default is called, by any function or cmdlet, 
# it automatically applies the parameter -OutVariable 'LastOut' to the call. 
# If you aren't currently aware, Out-Default is the command that all output passes through in PowerShell

# Output is stored in an ArrayList, which is a reference
# force PS to enumerate it before storing elsewhere $($LastOut) or
# manually retrieve the array $LastOut.ToArray().
function _ {
    $__[0]
}