function test-word {
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
  if ($null -eq $wordToComplete -or $wordToComplete -eq "") {
    return $false
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
  elseif ($wordToComplete.length -le 1) {
    return $false
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
    $commandFolder, 
    $wordToComplete,
    [string]$filter = '*.ps1'
  )

  $commands = Get-AllCmdFiles $commandFolder $filter

  if (!$wordToComplete) {
    # all commands
    return $commands.BaseName
  }

  $cmds = $commands |
  % { return @{Name = $_.BaseName; Order = 0 } } | 
  ? {
    $dashIndex = $_.Name.IndexOf('-');
    # command name do not has '-'
    if ($dashIndex -eq -1) {
      return test-word $_ $wordToComplete 1
    }

    # command name has '-'
    if ($wordToComplete.length -eq 1) {
      return test-word $_ $wordToComplete
    }
    elseif ($wordToComplete.length -eq 2) {
      $verb = $_.Name.Substring(0, $dashIndex);
      $noun = $_.Name.Substring($dashIndex + 1);
      $r = $verb.StartsWith($wordToComplete[0], [StringComparison]::InvariantCultureIgnoreCase) -and ($noun.StartsWith($wordToComplete[1], [StringComparison]::InvariantCultureIgnoreCase))
      if ($r) {
        return $r
      }
      else {
        return test-word $_ $wordToComplete 1
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
      return test-word $_ $wordToComplete 1
    }
  } |
  sort -Property Order |
  select -ExpandProperty Name
  return $cmds
}