<#
.SYNOPSIS
the path string of the git root folder where .git exists
#>
function Git-Root {
  $p = git rev-parse --show-toplevel
  if ($LASTEXITCODE -ne 0) {
    return ''
  }
  return $p
}