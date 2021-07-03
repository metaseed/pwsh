$info = Get-Content "$PSScriptRoot\info.json" | ConvertFrom-Json
$msg = "release $($info.version)"
git commit -am $msg
git tag -a $info.version -m $msg
git push --tags