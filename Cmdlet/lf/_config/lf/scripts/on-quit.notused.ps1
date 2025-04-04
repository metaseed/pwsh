# # slow: the window flash, so we use the 'bat' of cmd"`n"
# $paths = ($env:fx -split ',').trim('"')
# $json = ConvertTo-Json @{
# 	lastSelections = $paths
# 	workingDir = $env:PWD.trim('"')
# }
# $json > $env:temp\lf-onQuit.json
