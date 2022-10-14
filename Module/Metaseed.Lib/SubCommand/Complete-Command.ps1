function Test-WordToComplete {
  [CmdletBinding()]
  param (
    [Parameter()]
    [object]
    $obj,
    [Parameter()]
    [string]
    $wordToComplete,
    [Parameter()]
    [float]
    $oderBase = 0
  )
  if ($null -eq $wordToComplete -or $wordToComplete.length -le 1) {
    return $true
  }
  # start with
  elseif ($obj.Name.StartsWith($wordToComplete, [StringComparison]::InvariantCultureIgnoreCase)) {
    $obj.Order = $oderBase
    return $true
  }
  # $_ -like "*$wordToComplete*"
  # contains while word
  elseif ($obj.Name.Contains($wordToComplete, [StringComparison]::InvariantCultureIgnoreCase)) {
    $obj.Order = ($oderbase + 1)
    return $true
  }
  # start with the first char and has the remaining chars of the word
  elseif ($obj.Name -like (($wordToComplete -split '' -join '*').Substring(1))) {
    $obj.Order = $oderBase + 2
    return $true
  }
  # has the chars of the word
  elseif ($obj.Name -like ($wordToComplete -split '' -join '*')) {
    $obj.Order = $oderbase + 3
    return $true
  }
  else {
    return $false
  }
}


function Complete-Command {
  param(
    [Parameter()]
    [string]
    $cacheName,
    $commandFolder,
    $wordToComplete,
    [string]$filter = '*.ps1'
  )
  $cacheValue = Get-CmdsFromCache $cacheName $commandFolder $filter

  # retry(update cache) when can not find any command
  $retries = 1
  do {
    if ($cacheValue.count -eq 0) {
      $cacheValue = Get-CmdsFromCache $cacheName $commandFolder $filter -update
    }

    $commands = $cacheValue.Values|%{[IO.Path]::GetFileNameWithoutExtension($_)}

    if (!$wordToComplete) {
      # all commands
      return $commands
    }

    $cmds = $commands |
    % { return @{Name = $_; Order = 0 } } |
    ? {
      Write-Verbose "command name: $($_.Name)"
      $dashIndex = $_.Name.IndexOf('-');
      # command name do not has '-'
      if ($dashIndex -eq -1) {
        return Test-WordToComplete $_ $wordToComplete 1
      }

      # command name has '-'
      if ($wordToComplete.length -eq 1) {
        return Test-WordToComplete $_ $wordToComplete
      }
      elseif ($wordToComplete.length -eq 2) {
        $verb = $_.Name.Substring(0, $dashIndex);
        $noun = $_.Name.Substring($dashIndex + 1);
        $r = $verb.StartsWith($wordToComplete[0], [StringComparison]::InvariantCultureIgnoreCase) -and ($noun.StartsWith($wordToComplete[1], [StringComparison]::InvariantCultureIgnoreCase))
        if ($r) {
          return $r
        }
        else {
          return Test-WordToComplete $_ $wordToComplete 1
        }
      }
      else {
        $verb = $_.Name.Substring(0, $dashIndex);
        $noun = $_.Name.Substring($dashIndex + 1);
        # one-many
        $v = $wordToComplete[0];
        $n = ($wordToComplete.Substring(1) -split '' -join '*').Substring(1);
        if ($verb.startswith($v, [StringComparison]::InvariantCultureIgnoreCase) -and ($noun -like $n)) {
          return $true
        }
        # two-many
        $v = ($wordToComplete.Substring(0, 2) -split '' -join '*').Substring(1);
        $n = ($wordToComplete.Substring(2) -split '' -join '*').Substring(1);
        if (($verb -like $v) -and ($noun -like $n)) {
          $_.Order = 0.5
          return $true
        }
        # we do not process verb letters great than 2
        # so the verb part should be 1 or 2 letters
        # but we still do further search consecutive letters, so if we input 'pullrequest' we could get all related commands
        return Test-WordToComplete $_ $wordToComplete 1
      }
    } |
    sort -Property Order |
    select -ExpandProperty Name
  } while ($cmds.count -eq 0 -and $retries--)

  return $cmds
}

Export-ModuleMember Test-WordToComplete