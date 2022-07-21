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
                  # Write-Host ""
                  $newFolder = $true
              }
              $partsToPrint[$i] = $parts[$i]
          }
          # write-Host "$($parts[$i] -eq $partsToPrint[$i]), $($parts[$i]), $($partsToPrint[$i])"
      }
      # $parts[$parts.Length - 1] = $_.BaseName
      if($parts.Length -gt 1) {
        $folderParts = $parts[0..($parts.length -2)]
      }
      if($folderParts) {
        $folders =  '│' + ($folderParts -join ' ') + '│'
      } else {
        $folders = '│'
      }
      $cmd = $_.BaseName
      # $cmd = $parts -join ' '
      $syn = (Get-Help $_.FullName).Synopsis.TrimEnd("`n")
      if ($syn.startswith("$($_.BaseName).ps1")) {
          $syn = $syn.Substring("$($_.BaseName).ps1".Length).trim()
      }
      Write-Host -NoNewline "${folders}"
      Write-Host -NoNewline "${cmd}" -ForegroundColor Green
      if ($syn) {
        Write-Host ": $syn"
      } else {
        write-Host ""
      }
  }
}