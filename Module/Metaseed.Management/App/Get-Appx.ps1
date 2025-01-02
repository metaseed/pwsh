<#
.SYNOPSIS
get appx package from microsoft store and install it locally

.DESCRIPTION
sometime we can not directly access Microsoft Store directly to install an app,
it may be because of some config from IT department. This tool helps to workaround it.

.PARAMETER Uri
the uri to the app in Microsoft Store.

.PARAMETER Path
the path to store the downloaded appx packages.

.EXAMPLE
windbg:
Get-Appx https://www.microsoft.com/en-us/p/windbg/9pgjgd53tn86 c:/temp/windbg-appx

.EXAMPLE
winget:
Get-Appx "https://apps.microsoft.com/store/detail/app-installer/9NBLGGH4NNS1?hl=en-us&gl=US" c:/temp -all
sl c:\temp\app-installer
import-module appx -usewindowspowershell
# need to manully install the xaml appx package
Add-AppPackage .\Microsoft.UI.Xaml.2.7_7.2109.13004.0_x64__8wekyb3d8bbwe.appx
Add-AppPackage .\Microsoft.DesktopAppInstaller_2022.127.2322.0_neutral_~_8wekyb3d8bbwe.msixbundle

.Example
windows terminal:
get-appx "https://apps.microsoft.com/store/detail/windows-terminal/9N0DX20HK701" c:\temp -Verbose -all -Debug -force

.NOTES
to install the package bundles directly, we need to enable Sideloading
steps:
  1. Settings > Update & Security > For Developers, Ensure the setting here is set to either “Sideload apps” or “Developer mode”.
     If it’s set to “Windows Store apps”, you won’t be able to install .Appx or .AppxBundle software from outside the Windows Store.
  2. double click to install or in powershell run `Add-AppxPackage -Path "C:\Path\to\File.Appx"`

  > note: if default download not work, try use the -all switch
  > note: double click to install may not work, try Add-AppxPackage.
  > note: if `import-module appx` not work: https://github.com/PowerShell/PowerShell/issues/13138#issuecomment-677972433
  > try `import-module appx -usewindowspowershell`

.LINK
https://serverfault.com/questions/1018220/how-do-i-install-an-app-from-windows-store-using-powershell

#>
function Get-Appx {
    [CmdletBinding()]
    param (
        [string]$Uri,
        [string]$Path = ".",
        [switch]$all,
        [switch]$force
    )

    process {
        function Download (
            $FilePath,
            $CurrentUrl,
            $Force) {
            if (Test-Path "$FilePath") {
                if ($Force) {
                    Remove-Item "$FilePath"
                }
                else {
                    Write-Host "File already there, skip downing it: $FilePath"
                    return
                }
            }
            Write-Step "Downloading: $FilePath"
            $FileRequest = Invoke-WebRequest -Uri "$CurrentUrl" -UseBasicParsing #-Method Head
            [IO.File]::WriteAllBytes($FilePath, $FileRequest.content)
        }

        $StopWatch = [diagnostics.stopwatch]::startnew()
        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

        #Get Urls to download
        $urlParts = $Uri.Split("/")
        $PackageName = $urlParts[$urlParts.Length - 2]
        Write-Step "Downloading '$PackageName' from $Uri"

        ## make sure the path exists
        $Path = "$Path/$PackageName"
        if (-Not (Test-Path $Path)) {
            Write-Step "Creating directory: $Path"
            New-Item -ItemType Directory -Force -Path $Path | Out-Null
        }
        $Path = (Resolve-Path $Path).Path

        $WebResponse = Invoke-WebRequest -UseBasicParsing -Method 'POST' -Uri 'https://store.rg-adguard.net/api/GetFiles' -Body "type=url&url=$Uri&ring=Retail" -ContentType 'application/x-www-form-urlencoded'
        Write-Verbose "links:"
        # @{outerHTML=<a href="http://dl.delivery.mp.microsoft.com/filestreamingservice/files/f406a6eb-847d-4205-bc09-6bc41ca4d443" rel="noreferrer">Microsoft.UI.Xaml.2.7_7.2203.17001.0_arm64__8wekyb3d8bbwe.BlockMap</a>; tagName=A; href=http://dl.delivery.mp.microsoft.com/filestreamingservice/files/f406a6eb-847d-4205-bc09-6bc41ca4d443; rel=noreferrer}
        # @{outerHTML=<a href="http://tlu.dl.delivery.mp.microsoft.com/filestreamingservice/files/89c97a5d-af5f-4f43-b6a9-a599d7449fbd?P1=1652886783&P2=404&P3=2&P4=nOCQsSkyGFSGwFx4LEvLV9r3%2b1nRiIl4KEkfd5Cix0ErNauQt%2fXdK4MfFum5FpfPBNmOS5JLPCw4y%2f6zhlzoGA%3d%3d" rel="noreferrer">Microsoft.UI.Xaml.2.7_7.2203.17001.0_arm64__8wekyb3d8bbwe.appx</a>; tagName=A; href=http://tlu.dl.delivery.mp.microsoft.com/filestreamingservice/files/89c97a5d-af5f-4f43-b6a9-a599d7449fbd?P1=1652886783&P2=404&P3=2&P4=nOCQsSkyGFSGwFx4LEvLV9r3%2b1nRiIl4KEkfd5Cix0ErNauQt%2fXdK4MfFum5FpfPBNmOS5JLPCw4y%2f6zhlzoGA%3d%3d; rel=noreferrer}
        $WebResponse.Links | foreach {
            Write-Verbose ($_ | select -ExpandProperty outerHTML | Select-String -Pattern '(?<=">).+(?=</a>)').Matches.Value
        }

        if ($all) {
            $Matches_ = $WebResponse.Links
        }
        else {
            $Matches_ = $WebResponse.Links | where { $_ -match '\.appx|\.msixbundle|\.BlockMap' } | where { $_ -like '*_neutral_*' -or $_ -like "*_" + $env:PROCESSOR_ARCHITECTURE.Replace("AMD", "X").Replace("IA", "X") + "_*" } | where { $_ }
        }
        $LinksMatch = ($Matches_ | Select-String -Pattern '(?<=a href=").+(?=" r)').matches.value
        $Files = ($Matches_ | Select-String -Pattern '(?<=noreferrer">).+(?=</a>)').matches.value
        #Create array of links and filenames
        for ($i = 0; $i -lt $LinksMatch.Count; $i++) {
            $Array += , @($LinksMatch[$i], $Files[$i])
        }
        #Sort by filename descending
        $Array = $Array | sort-object @{Expression = { $_[1] }; Descending = $True }
        $LastFile = "temp123"
        Write-Verbose "`n`nLinks To Download:"
        $LastFileIndex = 0
        for ($i = 0; $i -lt $LinksMatch.Count; $i++) {
            $CurrentFile = $Array[$i][1]
            $CurrentUrl = $Array[$i][0]
            Write-Verbose "$CurrentFile :`n     $CurrentUrl`n"
            if ($all) {
                Download "$Path\$CurrentFile" $CurrentUrl $force
                continue
            }
            ## only download the latest version of all files
            #Find first number index of current and last processed filename
            if ($CurrentFile -match "(?<number>_\d+)") {
                $FileIndex = $CurrentFile.indexof($Matches.number)
            }
            if ($LastFile -match "(?<number>_\d+)") {
                $LastFileIndex = $LastFile.indexof($Matches.number)
            }
            #If current filename not equal to last filename
            $CurrentFileName = $CurrentFile.SubString(0, $FileIndex)
            $LastFileName = $LastFile.SubString(0, $LastFileIndex)
            Write-Debug "CurrentFile: $CurrentFile, $CurrentFileName, LastFile: $LastFile, $LastFileName"
            if ($CurrentFileName -ne $LastFileName) {
                #If file not already downloaded, download it
                Download "$Path\$CurrentFile" $CurrentUrl $force
            }
            #Delete file outdated and already exist
            elseif (Test-Path "$Path\$CurrentFile") {
                Write-Host "Removing: $Path\$CurrentFile"
                Remove-Item "$Path\$CurrentFile"
            }
            else {
                Write-Host "File already exist: $Path\$CurrentFile"
            }

            if ($CurrentFile -notlike '*.BlockMap') {
                $LastFile = $CurrentFile
            }
        }
        Write-Host "Time to process: $($StopWatch.ElapsedMilliseconds)ms"
        [Console]::Beep(1000, 1000)
        saps -Path $Path
    }
}

# Get-appx https://apps.microsoft.com/detail/9nmpj99vjbwv