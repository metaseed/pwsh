function Write-AllSubCommands {
  param($commandFolder)
  Write-Host "You could run these commands:"

  $partsToPrint = 1..15
  Get-AllPwshFiles $commandFolder | Sort-object | % { 
      $start = "\Command\"
      $index = $_.FullName.IndexOf($start)
      $cmd = $_.FullName.Substring($index + $start.Length)
      $parts = $cmd.split('\')
      # if($parts.length -eq 0){
      #     Write-Host ""
      # }
      $newFolder = $false
      for ($i = 0; $i -lt $parts.Length - 1; $i++) {
          if ($parts[$i] -eq $partsToPrint[$i]) {
              $parts[$i] = ' ' * $parts[$i].Length
          }
          else {
              # new folder
              if (! $newFolder) {
                  Write-Host ""
                  $newFolder = $true
              }
              $partsToPrint[$i] = $parts[$i]
          }
          # write-Host "$($parts[$i] -eq $partsToPrint[$i]), $($parts[$i]), $($partsToPrint[$i])"
      }
      $parts[$parts.Length - 1] = $_.BaseName 
      $cmd = $parts -join ' '
      $syn = (Get-Help $_.FullName).Synopsis.TrimEnd("`n")
      if ($syn.startswith("$($_.BaseName).ps1")) {
          $syn = $syn.Substring("$($_.BaseName).ps1".Length).trim()
      }
      if ($syn) {
        Write-Host "${cmd}: $syn"
      }
      else {
        Write-Host "${cmd}"
      }
  }
}