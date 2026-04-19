function f {
	[CmdletBinding()]
	param (
		[Parameter(ValueFromRemainingArguments)]
		[string[]]
		$allArgs,
		[Parameter()]
		[switch]
		$web
	)
	if ($web) {
		sa https://yazi-rs.github.io/docs/quick-start/
		return
	}
	$tmp = (New-TemporaryFile).FullName

	if ($null -ne $allArgs) {
		$positional, $named = Split-RemainParameters $allArgs
		$paths = @($positional | % {
				if(Test-Path $_) {
					return (Resolve-Path -LiteralPath $_).Path
				}
				return zz $_
			})
	}
	C:\App\yazi\yazi.exe @paths @named --cwd-file="$tmp"
	$cwd = Get-Content -Path $tmp -Encoding UTF8
	if ($cwd -and $cwd -ne $PWD.Path -and (Test-Path -LiteralPath $cwd -PathType Container)) {
		Set-Location -LiteralPath (Resolve-Path -LiteralPath $cwd).Path
	}
	Remove-Item -Path $tmp
}

# f opcua