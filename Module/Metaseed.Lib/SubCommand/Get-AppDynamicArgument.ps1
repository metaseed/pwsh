<#
.NOTES
to trigger the list:
a app -{tab}
#>
function  Get-AppDynamicArgument {
  [CmdletBinding()]
  param (
    [string]$cacheName,
    [string]$app,
    [string]$argsDir
  )

  # [Console]::WriteLine("$app $argsDir ")
  if (!$app) { return }

  # Show-MessageBox "$app $cachename $argsDir"
  $cacheValue = Get-CmdsFromCache $cacheName $argsDir '*_args.ps1'
  $argFile = $cacheValue["${app}_args"]
  if (!$argFile ) {
    $cacheValue = Get-CmdsFromCache $cacheName $argsDir '*_args.ps1' -update
    $argFile = $cacheValue["${app}_args"]
  }
  if (!$argFile ) {
    # Show-MessageBox "$app $cachename $argsDir"
    return
  }

  . $argFile
  # https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_functions_advanced_parameters
  $paramDictionary = [System.Management.Automation.RuntimeDefinedParameterDictionary]::new()

  $args | % {
    $attributeCollection = [System.Collections.ObjectModel.Collection[System.Attribute]]::new()
    $parameterAttribute = [System.Management.Automation.ParameterAttribute]@{
      # ParameterSetName = "ByRegistryPath"
      # Mandatory        = $false
    }
    $attributeCollection.Add($parameterAttribute)

    if ($_.Aliases) {
      $alias = [System.Management.Automation.AliasAttribute]::new($_.Aliases)
      $attributeCollection.Add($alias)
    }

    $param = [System.Management.Automation.RuntimeDefinedParameter]::new(
      $_.Name, $_.Type ?? [string], $attributeCollection
    )

    $paramDictionary.Add($_.Name, $param)
  }
  # Show-messsagebox $paramDictionary.Count
  return $paramDictionary

}