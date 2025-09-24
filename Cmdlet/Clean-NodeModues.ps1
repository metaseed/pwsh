$dir = 'node_modules';
$allNodeModules = Get-ChildItem -Path M: -Directory -Recurse | Where-Object { $_.Name -eq $dir -and $_.Parent.FullName -notmatch $dir } | ForEach-Object { $_.FullName }
$allNodeModules
$yes = Read-Host "y to delete all?"
if ($yes -eq 'y') {
	$allNodeModules | % {
		"remove: $_"
		Remove-Item $_ -Recurse -Force
	}
}

Get-ChildItem -Path M: -Directory -Recurse | Where-Object { $_.Name -match '^[[0-9a-fA-F\d]+$' -and $_.FullName -notmatch '.git' } | ForEach-Object { $_.FullName }
"bin", "obj" | % {
	$pFolder = $_
	"debug", "release" | % {
		$folder = $_
		$allNodeModules = Get-ChildItem -Path M: -Directory -Recurse | Where-Object { $_.FullName -match "$pFolder\\$folder$" } | ForEach-Object { $_.FullName }
		$allNodeModules | % {
			"remove: $_"
			Remove-Item $_ -Recurse -Force
		}
	}
}