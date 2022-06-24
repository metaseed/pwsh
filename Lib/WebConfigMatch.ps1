
$webKeys = $webs.keys
$notMatched = [Collections.ArrayList]::new($webKeys)
$webKey = @($webKeys |
? { $_.StartsWith($wordToComplete) } |
% { $notMatched.remove($_); $_ })

$webKeys = @($notMatched)
$webKey += $webKeys | 
? {
  $_ -like "*${wordToComplete}*"
} |
% {
  $notMatched.remove($_)
  return $_
}
$webKeys = @($notMatched)
$word = ($wordToComplete -split '' -join '*')
$webKey += $webKeys | ? {
  $_ -like "${word}"
}
return $webKey