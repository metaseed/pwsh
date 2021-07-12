# https://stackoverflow.com/questions/14351018/powershell-is-there-an-automatic-variable-for-the-last-execution-result
$PSDefaultParameterValues['Out-Default:OutVariable'] = '__' # use $($__) or $__[0]
function _ {
    $__[0]
}