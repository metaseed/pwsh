$webKeys = $webs.keys
$notMatched = [Collections.ArrayList]::new($webKeys)
# add keys start with the keyword
$webKey = @($webKeys |
? { $_.StartsWith($wordToComplete) } |
% { $notMatched.remove($_); $_ })

# add keys contains the keyword
$webKeys = @($notMatched)
$webKey += $webKeys |
? {
  $_ -like "*${wordToComplete}*"
} |
% {
  $notMatched.remove($_)
  return $_
}

# add keys contains the chars sequence of the keyword
$webKeys = @($notMatched)
$word = ($wordToComplete -split '' -join '*')
$webKey += $webKeys | ? {
  $_ -like "${word}"
}

return $webKey