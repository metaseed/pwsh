function  Get-AppDynamicArgument{
  [CmdletBinding()]
  param (
    [string]$app,
    [string]$argsDir
  )

  # [Console]::WriteLine("`n eeeaaa $app  aaa")
  if (!$app) { return }

  $cacheValue = Get-CmdsFromCacheAutoUpdate 'app_args' $argsDir '*_args.ps1'

  $argFile = $cacheValue["${app}_args"]
  if (!$argFile ) {
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

    $param = [System.Management.Automation.RuntimeDefinedParameter]::new(
      $_.Name, $_.Type ?? [string], $attributeCollection
    )

    $paramDictionary.Add($_.Name, $param)
  }
  return $paramDictionary

}