<#
.SYNOPSIS
   update process_env Path from machine_env and user_env

#>
function Update-ProcessEnvVarPath {
	@("Machine", "User")  |
	% {
		$pathEnv = [Environment]::GetEnvironmentVariable('Path', $_)
		$updatedPathEnv = ("${pathEnv};${env:Path}" -split ';' |?{$_}<#filter out empties i.e.: ;;#>| select -Unique) -join ';'

		if ($env:Path -ne $updatedPathEnv) {
			$env:Path = $updatedPathEnv
			Write-Verbose "Path environment variables updated from scope '$_'!"
		}
		else {
			Write-Information 'no need to update the path environment variable!'
		}
	}

}
