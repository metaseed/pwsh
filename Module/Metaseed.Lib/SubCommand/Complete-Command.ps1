function Complete-Command {
  param($commandFolder, $wordToComplete)
  $cmds = Get-AllPwshFiles $commandFolder | % { $_.BaseName } | ? {
    $dashIndex = $_.IndexOf('-');
    if ($dashIndex -eq -1) {
      $like = ($wordToComplete -split '' -join '*').Substring(1);
      return $_ -like $like
    }
    
    if ($wordToComplete.length -eq 1) {
      return $_.StartsWith($wordToComplete, [StringComparison]::InvariantCultureIgnoreCase)
    }
    elseif ($wordToComplete.length -eq 2) {
      $verb = $_.Substring(0, $dashIndex);
      $noun = $_.Substring($dashIndex + 1);
      return $verb.StartsWith($wordToComplete[0], [StringComparison]::InvariantCultureIgnoreCase) -and ($noun.StartsWith($wordToComplete[1], [StringComparison]::InvariantCultureIgnoreCase))
    }
    else {
      $verb = $_.Substring(0, $dashIndex);
      $noun = $_.Substring($dashIndex + 1);
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
        return $true
      }
      # we do not process verb letters great than 2
      # so the verb part should be 1 or 2 letters
      # but we still do further search consecutive letters, so if we input 'pullrequest' we could get all related commands
      if ($_ -like "*$wordToComplete*") {
        return $true
      }
      return $false
    }
  }
  return $cmds 
}