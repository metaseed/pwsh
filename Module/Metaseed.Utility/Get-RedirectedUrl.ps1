function Get-RedirectedUrl {
  [CmdletBinding()]
  Param (
      [Parameter(Mandatory=$true)]
      [String]$URL
  )

  $request = [Net.WebRequest]::Create($url)
  $request.AllowAutoRedirect=$false
  $response=$request.GetResponse()

  If ($response.StatusCode -eq "Found")
  {
      $response.GetResponseHeader("Location")
  }
}