<#
.SYNOPSIS
   update process path env from machine_env and user_env, the temp vars are kept. (i.e. just in $env:path, not in [Environment]::GetEnvironmentVariable('Path', $_))
.DESCRIPTION
   if: it's path and contains ';' => all value from Machine and User, then uniqued then appended .
   else => value override from Manchine and then from User(if has same key name)
#>
function Update-Path {
	@("Machine", "User")  |
	% {
		$pathEnv = [Environment]::GetEnvironmentVariable('Path', $_)
		$updatedPahtEnv = ("${pathEnv};${env:Path}" -split ';' | select -Unique) -join ';'
		if ($env:Path -ne $updatedPahtEnv) {
			$env:Path = $updatedPahtEnv
			Write-Verbose "Path environment variables updated from scope '$_'!"
		}
		else {
			Write-Information 'no need to update the path environment variable!'
		}
	}

}
