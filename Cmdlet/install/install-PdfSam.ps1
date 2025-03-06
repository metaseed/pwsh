[CmdletBinding()]
param (
  [Parameter(DontShow, ValueFromRemainingArguments)]$Remaining
)

# to reload and debug after modification of lib functions
# ipmo Metaseed.Management -Force
function Split-Parameters {
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
      # Return a custom object with both parameter collections
      return [PSCustomObject]@{
          PositionalParameters = $PositionalParams
          NamedParameters = $NamedParams
      }
  }
}

$param = Split-Parameters $Remaining
$pos =$param.PositionalParameters
$nam = $param.NamedParameters
Install-FromGithub https://github.com/torakiki/pdfsam '-windows\.zip$'  @pos @nam