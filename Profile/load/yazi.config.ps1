function f {
	[CmdletBinding()]
	param (
		[Parameter()]
		[switch]
		$web
	)
	if($web){
		sa https://yazi-rs.github.io/docs/quick-start/
		return
	}
	$tmp = (New-TemporaryFile).FullName
	C:\App\yazi\yazi.exe $args --cwd-file="$tmp"
	$cwd = Get-Content -Path $tmp -Encoding UTF8
	if ($cwd -and $cwd -ne $PWD.Path -and (Test-Path -LiteralPath $cwd -PathType Container)) {
		Set-Location -LiteralPath (Resolve-Path -LiteralPath $cwd).Path
	}
	Remove-Item -Path $tmp
}