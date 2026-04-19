function Invoke-Editor {
    param(
        [string]$Command,
        [object]$InputObject
    )
    if (!$InputObject) { $InputObject = '.' }
    else {
        if(test-path $inputObject) {
            $path = Resolve-Path $InputObject
        }
        else {
             $path = zz $InputObject
        }
    }

    & $Command $path
}

function Stop-Editor {
    param(
        [string]$ProcessName,
        [string]$Path
    )
    if (!$Path) {
        $title = Split-Path -Leaf (Get-Location)
    }
    elseif (Test-Path $Path) {
        $title = Split-Path -Leaf (Resolve-Path $Path)
    }
    else {
        $Path = zz $Path
        $title = Split-Path -Leaf $Path
    }

    $matched = Get-Process -Name $ProcessName -ErrorAction SilentlyContinue |
    Where-Object { $_.MainWindowTitle -like "*$title*" }

    if (!$matched) {
        Write-Host "No '$ProcessName' window found matching '$title'" -ForegroundColor Yellow
        return
    }

    $matched | ForEach-Object {
        $_.CloseMainWindow() | Out-Null
        Write-Host "Closed ${ProcessName}: $($_.MainWindowTitle)" -ForegroundColor Green
    }
}

function Open-Code {
    [Alias('oc')]
    param(
        [Parameter(ValueFromPipeline = $true, Position = 0)]
        $Path
    )
    process { Invoke-Editor 'code' $Path }
}

function Open-Cursor {
    [Alias('os')]
    param(
        [Parameter(ValueFromPipeline = $true, Position = 0)]
        $Path
    )
    process { Invoke-Editor 'cursor' $Path }
}

function Close-Code {
    [Alias('cc')]
    param(
        [Parameter(ValueFromPipeline = $true, Position = 0)]
        [string]$Path
    )
    process { Stop-Editor 'code' $Path }
}

function Close-Cursor {
    [Alias('cs')]
    param(
        [Parameter(ValueFromPipeline = $true, Position = 0)]
        [string]$Path
    )
    process { Stop-Editor 'cursor' $Path }
}

Export-ModuleMember -Function @('Open-Cursor', 'Close-Cursor', 'Close-Code')