function Get-ProcessTree {
    param (
        [Parameter(ValueFromPipeline = $true,Mandatory=$true)]
        [int]$Id
    )

    try {
        # Get the process with the specified ID
        $process = Get-Process -Id $Id -ErrorAction Stop

        # Get process command line using CimInstance
        $processDetails = Get-CimInstance Win32_Process -Filter "ProcessId = $Id" -ErrorAction SilentlyContinue

        # Create a custom object for this process
        $processObject = [PSCustomObject]@{
            ProcessId = $Id
            Name = $process.Name
            CommandLine = $processDetails.CommandLine
            ParentProcessId = $processDetails.ParentProcessId
            StartTime = $process.StartTime
            CPU = $process.CPU
            WorkingSet = $process.WorkingSet64
            Path = $process.Path
            Children = @()
        }

        # Find all child processes
        $childProcesses = Get-CimInstance Win32_Process -Filter "ParentProcessId = $Id" -ErrorAction SilentlyContinue

        # Recursively get children
        foreach ($childProcess in $childProcesses) {
            $childObject = Get-ProcessTree -Id $childProcess.ProcessId
            $processObject.Children += $childObject
        }

        return $processObject
    }
    catch {
        Write-Warning "Could not retrieve process with ID $Id : $_"
        return $null
    }
}

function Show-ProcessTree {
    param (
        [Parameter(ValueFromPipeline = $true,Mandatory=$true)]
        [int]$Id,
        [Parameter(Mandatory=$false)]
        [switch]$Detailed
    )

    try {
        # Get the process tree object
        $processTree = Get-ProcessTree -Id $Id

        if ($processTree) {
            # Display parent information if available
            try {
                $parentId = $processTree.ParentProcessId
                if ($parentId -and $parentId -ne 0) {
                    $parentProcess = Get-Process -Id $parentId -ErrorAction SilentlyContinue
                    $parentName = if ($parentProcess) { $parentProcess.Name } else { "Unknown" }
                    Write-Host "Parent: $parentName (ID: $parentId)" -ForegroundColor Cyan
                }
            }
            catch {
                # Continue even if we can't get parent info
            }

            # Display the tree
            Write-Host "Process Tree for $($processTree.Name) (ID: $($processTree.ProcessId):" -ForegroundColor Green
            Write-ProcessTreeRecursive -ProcessObject $processTree -Indent 0 -Detailed:$Detailed
        }
    }
    catch {
        Write-Error "Could not build process tree: $_"
    }
}

function Write-ProcessTreeRecursive {
    param (
        [Parameter(Mandatory=$true)]
        [PSCustomObject]$ProcessObject,
        [int]$Indent = 0,
        [switch]$Detailed
    )

    $indentString = "    " * $Indent

    # Create basic process info
    $processInfo = "$indentString├─ $($ProcessObject.Name) (ID: $($ProcessObject.ProcessId))"

    # Add command line if available and not in detailed mode
    if (-not $Detailed -and $ProcessObject.CommandLine) {
        $commandLineShort = if ($ProcessObject.CommandLine.Length -gt 80) {
            $ProcessObject.CommandLine.Substring(0, 77) + "..."
        } else {
            $ProcessObject.CommandLine
        }
        $processInfo += " - $commandLineShort"
    }

    Write-Host $processInfo

    # Show detailed information if requested
    if ($Detailed) {
        if ($ProcessObject.CommandLine) {
            Write-Host "$indentString│  Command: $($ProcessObject.CommandLine)"
        }
        Write-Host "$indentString│  Start Time: $($ProcessObject.StartTime)"
        Write-Host "$indentString│  CPU Time: $($ProcessObject.CPU) seconds"
        Write-Host "$indentString│  Memory: $([math]::Round($ProcessObject.WorkingSet / 1MB, 2)) MB"
        if ($ProcessObject.Path) {
            Write-Host "$indentString│  Path: $($ProcessObject.Path)"
        }
    }

    # Process children recursively
    foreach ($child in $ProcessObject.Children) {
        Write-ProcessTreeRecursive -ProcessObject $child -Indent ($Indent + 1) -Detailed:$Detailed
    }
}

# Export the object-oriented function for programmatic use
# Export-ModuleMember @('Show-ProcessTree')

# Example usage:
# Get tree object for programmatic use
# $tree = Get-ProcessTreeObject -Id 1234
# $tree | ConvertTo-Json -Depth 10 > process_tree.json

# Display tree in console
# Show-ProcessTree -Id 52384 -Detailed
# Show-ProcessTree -Id 1234 -Detailed
# Show-ProcessTree -Id $PID
# gps lf|% Id|% {Show-ProcessTree $_}