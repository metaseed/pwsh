# # slow
# $paths = ($env:fx -split "`n").trim('"')
# $json = ConvertTo-Json @{
# 	lastSelections = $paths
# 	workingDir = $env:PWD.trim('"')
# }
# $json > $env:temp\lf-onQuit.json
