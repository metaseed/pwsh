function Git-DeleteAllLocalBranches {
  [CmdletBinding()]
  param (
    [Parameter()]
    [boolean]
    $merged = $false
  )

  # if your branches names contains non ascii characters
  # [Console]::OutputEncoding = [System.Text.Encoding]::UTF8

  # list branches
  $branches = git branch "$($merged ?'--merged': '')" | 
  # filter out branches contains 'master' or 'development' and the current branche (marked by *)
  # note: if just filter out current: '^[^\*].*'
  Select-String -Pattern '^(?!.*(master|development|\*)).*$' 

  if($branches.Length -eq 0) {
    Write-Host "No Branch to Delete!`nbranches available:" -ForegroundColor yellow
    git branch
    return
  }
  Write-Warning "$([Environment]::NewLine) $($branches -join ([System.Environment]::NewLine))"
  $answer = Read-Host "Delete these brancheds(Y or Enter)?"
  if ($answer -eq 'y' -or $answer -eq [ConsoleKey]::Enter) {
    $branches |
    % { 
   
      git branch -d $_.ToString().Trim() 
    }
  } else {
    Write-Host ''
    Write-Host 'No Branches Deleted!' -ForegroundColor yellow
  }
}