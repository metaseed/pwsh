function Split-RemainParameters {
	[CmdletBinding()]
	param (
		[Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
		[AllowEmptyCollection()]
		[object[]]$InputParameters
	)

	begin {
		$PositionalParams = @()
		$NamedParams = @{}
	}

	process {
		# Process the arguments
		for ($i = 0; $i -lt $InputParameters.Count; $i++) {
			$current = $InputParameters[$i]

			# Check if it's a parameter name (starts with - or has an = sign)
			if ($current -is [string] -and ($current -match "^-" -or $current -match "=")) {
				# It's a named parameter
				if ($current -match "^-(\w+)=(.*)$") {
					# Handle -param=value format
					$NamedParams[$matches[1]] = $matches[2]
				}
				elseif ($current -match "^-(\w+)$" -and ($i + 1) -lt $InputParameters.Count -and
					   !($InputParameters[$i + 1] -is [string] -and $InputParameters[$i + 1] -match "^-")) {
					# Handle -param value format
					$NamedParams[$matches[1]] = $InputParameters[$i + 1]
					$i++ # Skip the next item as we've used it as a value
				}
				else {
					# It's a switch parameter
					$paramName = $current.TrimStart('-')
					$NamedParams[$paramName] = $true
				}
			}
			else {
				# It's a positional parameter
				$PositionalParams += $current
			}
		}
	}

	end {
		return $PositionalParams,$NamedParams
	}
  }

<#
[CmdletBinding()]
param (
  [Parameter(DontShow, ValueFromRemainingArguments)]$Remaining
)

# ipmo Metaseed.Management -Force
# ipmo Metaseed.Utils -Force
$positional, $named= Split-RemainParameters $Remaining
# Note: it can not override local set named values
Install-FromGithub https://github.com/torakiki/pdfsam '-windows\.zip$' -versionType stable @positional @named

## tt.ps1
& "$PSScriptRoot\..\install-PdfSam.ps1" 'bb' -versionType preview
#>