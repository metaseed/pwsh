<#
.SYNOPSIS
the path string of the git root folder where .git exists
#>
function Git-Root {
  param (
  )
  git rev-parse --show-toplevel
  
}