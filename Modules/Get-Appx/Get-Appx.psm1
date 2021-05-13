# https://serverfault.com/questions/1018220/how-do-i-install-an-app-from-windows-store-using-powershell
# param (
#     [string]$Uri = "https://www.microsoft.com/p/snip-sketch/9mz95kl8mr0l",
#     [string]$Path = "."
# )
# Get-Appx $Uri $Path
#Add-AppPackage -Path 
function Get-Appx {
    [CmdletBinding()]
    param (
        [string]$Uri,
        [string]$Path = "."
    )
    process {
        Write-Output ""
        $StopWatch = [diagnostics.stopwatch]::startnew()

        if (-Not (Test-Path $Path)) {
            Write-Host -ForegroundColor Green "Creating directory: $Path"
            New-Item -ItemType Directory -Force -Path $Path
        }
        $Path = (Resolve-Path $Path).Path
        #Get Urls to download
        $urlParts = $Uri.Split("\")
        $PackageName = $urlParts[$urlParts.Length-2]
        Write-Host -ForegroundColor Yellow "Downloading $PackageName from $Uri"
        $WebResponse = Invoke-WebRequest -UseBasicParsing -Method 'POST' -Uri 'https://store.rg-adguard.net/api/GetFiles' -Body "type=url&url=$Uri&ring=Retail" -ContentType 'application/x-www-form-urlencoded'
        $LinksMatch = ($WebResponse.Links | where { $_ -like '*.appx*' } | where { $_ -like '*_neutral_*' -or $_ -like "*_" + $env:PROCESSOR_ARCHITECTURE.Replace("AMD", "X").Replace("IA", "X") + "_*" } | Select-String -Pattern '(?<=a href=").+(?=" r)').matches.value
        $Files = ($WebResponse.Links | where { $_ -like '*.appx*' } | where { $_ -like '*_neutral_*' -or $_ -like "*_" + $env:PROCESSOR_ARCHITECTURE.Replace("AMD", "X").Replace("IA", "X") + "_*" } | where { $_ } | Select-String -Pattern '(?<=noreferrer">).+(?=</a>)').matches.value
        #Create array of links and filenames
        for ($i = 0; $i -lt $LinksMatch.Count; $i++) {
            $Array += , @($LinksMatch[$i], $Files[$i])
        }
        #Sort by filename descending
        $Array = $Array | sort-object @{Expression = { $_[1] }; Descending = $True }
        $LastFile = "temp123"
        for ($i = 0; $i -lt $LinksMatch.Count; $i++) {
            $CurrentFile = $Array[$i][1]
            $CurrentUrl = $Array[$i][0]
            #Find first number index of current and last processed filename
            if ($CurrentFile -match "(?<number>\d)") {}
            $FileIndex = $CurrentFile.indexof($Matches.number)
            if ($LastFile -match "(?<number>\d)") {}
            $LastFileIndex = $LastFile.indexof($Matches.number)
    
            #If current filename product not equal to last filename product
            if (($CurrentFile.SubString(0, $FileIndex - 1)) -ne ($LastFile.SubString(0, $LastFileIndex - 1))) {
                #If file not already downloaded, add to the download queue
                if (-Not (Test-Path "$Path\$CurrentFile")) {
                    "Downloading $Path\$CurrentFile"
                    $FilePath = "$Path\$CurrentFile"
                    $FileRequest = Invoke-WebRequest -Uri $CurrentUrl -UseBasicParsing #-Method Head
                    [System.IO.File]::WriteAllBytes($FilePath, $FileRequest.content)
                }
            }
            #Delete file outdated and already exist
            elseif ((Test-Path "$Path\$CurrentFile")) {
                Remove-Item "$Path\$CurrentFile"
                "Removing $Path\$CurrentFile"
            }
            $LastFile = $CurrentFile
        }
        "Time to process: " + $StopWatch.ElapsedMilliseconds
    }
}
