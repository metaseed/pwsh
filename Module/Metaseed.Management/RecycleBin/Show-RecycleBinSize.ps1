
$fldpath = $null
# https://jdhitsolutions.com/blog/powershell/7024/managing-the-recycle-bin-with-powershell/

# note when try to get size of larger file in recyclebin the size is not right. i.e. the vhdx file in a folder inside the bin
Function ParseItem {
    [cmdletbinding()]
    Param(
        [Parameter(Mandatory, ValueFromPipeline)]
        [object]$Item
    )
    #this function relies variables set in a parent scope
    Process {
        Write-Verbose "[$((Get-Date).TimeofDay) PROCESS] Processing $($item.path)"

        # uncomment for troubleshooting
        # $global:raw += $item
        if ($item.IsFolder -AND ($item.type -notmatch "ZIP")) {
            Write-Verbose "Enumerating $($item.name)"
            Try {
                #track the path name through each child object
                if ($fldpath) {
                    $fldpath = Join-Path -Path $fldPath -ChildPath $item.GetFolder.Title
                }
                else {
                    $fldPath = $item.GetFolder.Title
                }
                #recurse through child items
                $item.GetFolder().Items() | ParseItem
                Remove-Variable -Name fldpath
            }
            Catch {
                # Uncomment for troubleshooting
                # $global:rbwarn += $item
                Write-Warning ($item | Out-String)
                Write-Warning $_.exception.message
            }
        }
        else {
            #sometimes the original location is stored in an extended property
            $data = $item.ExtendedProperty("infotip").split("`n") | Where-Object { $_ -match "Original location" }
            if ($data) {
                Write-Verbose "infotip: $data"
                $origPath = $data.split(":", 2)[1].trim()
                $full = Join-Path -path $origPath -ChildPath $item.name -ErrorAction stop
                Remove-Variable -Name data
            }
            else {
                #no extended property so use this code to attemp to rebuild the original location
                if ($item.parent.title -match "^[C-Zc-z]:\\") {
                    $origPath = $item.parent.title
                }
                elseif ($fldpath) {
                    $origPath = $fldPath
                }
                else {
                    $test = $item.parent
                    Write-Verbose "searching for parent on $($test.self.path)"
                    do { $test = $test.parentfolder; $save = $test.title } until ($test.title -match "^[C-Zc-z]:\\" -OR $test.title -eq $save)
                    $origPath = $test.title
                }

                $full = Join-Path -path $origPath -ChildPath $item.name -ErrorAction stop
            }


            $obj = [pscustomobject]@{
                PSTypename       = "DeletedItem"
                Name             = $item.name
                Path             = $item.Path
                Modified         = $item.ModifyDate
                OriginalPath     = $origPath
                OriginalFullName = $full
                Size             = $item.Size
                IsFolder         = $item.IsFolder
                Type             = $item.Type
            }
            Write-Verbose "item: $($obj)"
            return $obj
        }
    } #process
}

function Show-RecycleBinSize {
    [cmdletbinding()]
    [alias('shrs')]
    Param()
    $shell = New-Object -com shell.application
    $rb = $shell.Namespace(10)
    $bin = $rb.items() | ParseItem

    $o = $bin | Measure-Object -Property size -sum | Select-Object Count, Sum
    Write-Host "Tocal Count: $($o.Count) TotalSize: $([math]::Round($o.Sum/1GB, 3))G"

    $all = $bin |
    # disk symbol
    group-object -Property { $_.path.substring(0, 2) } |
    Select-Object -Property Name, Count, @{
        Name = "SizeMB"; Expression = { [Math]::Round(($_.group | measure-object -Property size -sum).sum / 1MB, 3) }
    }

    $all
}
