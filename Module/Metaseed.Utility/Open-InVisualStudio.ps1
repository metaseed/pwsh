function Open-InVisualStudio {
    [CmdletBinding()]
    # Takes file, line, column, and an optional solution name as arguments
    param (
        [string]$File,
        [int]$Line = 1,
        [int]$Column = 1,
        [string]$SolutionName = ""
    )

    # In PowerShell 7+, Marshal.GetActiveObject is not always available directly.
    # We compile a C# helper to expose it reliably and to get all running DTE instances.
    Add-Type -TypeDefinition @"
using System;
using System.Collections.Generic;
using System.Runtime.InteropServices;
using System.Runtime.InteropServices.ComTypes;

public static class ComHelper {
    [DllImport("ole32.dll")]
    private static extern int GetRunningObjectTable(int reserved, out IRunningObjectTable prot);

    [DllImport("ole32.dll")]
    private static extern int CreateBindCtx(int reserved, out IBindCtx ppbc);

    // This helper gets a single active COM object.
    public static object GetActiveObject(string progId) {
        IRunningObjectTable rot;
        if (GetRunningObjectTable(0, out rot) != 0) return null;

        IEnumMoniker enumMoniker;
        rot.EnumRunning(out enumMoniker);
        enumMoniker.Reset();

        IMoniker[] monikers = new IMoniker[1];
        while (enumMoniker.Next(1, monikers, IntPtr.Zero) == 0) {
            IBindCtx bindCtx;
            if (CreateBindCtx(0, out bindCtx) != 0) continue;

            string displayName;
            monikers[0].GetDisplayName(bindCtx, null, out displayName);

            if (displayName.StartsWith("!" + progId)) {
                object instance;
                rot.GetObject(monikers[0], out instance);
                return instance;
            }
        }
        return null;
    }

    // This helper gets ALL running Visual Studio DTE instances.
    public static object[] GetAllDteObjects() {
        var dteInstances = new List<object>();
        IRunningObjectTable rot;
        if (GetRunningObjectTable(0, out rot) != 0) return dteInstances.ToArray();

        IEnumMoniker enumMoniker;
        rot.EnumRunning(out enumMoniker);
        enumMoniker.Reset();

        IMoniker[] monikers = new IMoniker[1];
        while (enumMoniker.Next(1, monikers, IntPtr.Zero) == 0) {
            IBindCtx bindCtx;
            if (CreateBindCtx(0, out bindCtx) != 0) continue;

            string displayName;
            monikers[0].GetDisplayName(bindCtx, null, out displayName);

            if (displayName.StartsWith("!VisualStudio.DTE")) {
                object dte;
                rot.GetObject(monikers[0], out dte);
                if (dte != null) {
                    dteInstances.Add(dte);
                }
            }
        }
        return dteInstances.ToArray();
    }
}
"@ -ErrorAction Stop

    $dte = $null

    # --- LOGIC --- #
    if (!(Test-Path $File)) {
        write-error "no such file: $File"
        return
    }

    if ([string]::IsNullOrEmpty($SolutionName)) {
        # --- SCENARIO 1: No solution name provided. Find any VS instance or create one. ---

        # Dynamically find installed Visual Studio DTE ProgIDs
        $vsProgIDs = Get-ChildItem -Path "HKLM:\Software\Classes" |
        Where-Object { $_.PSChildName -match '^VisualStudio\.DTE(\.\d+\.\d+)?$' } |
        Select-Object -ExpandProperty PSChildName |
        Sort-Object -Descending

        if ($vsProgIDs.Count -eq 0) {
            Write-Error "No Visual Studio DTE ProgIDs found in the registry. Is Visual Studio installed?"
            exit 1
        }

        # Try to get any running instance of Visual Studio
        foreach ($progId in $vsProgIDs) {
            try {
                # could use too
                # $dte = Get-ActiveComObject $progId
                $dte = [ComHelper]::GetActiveObject($progId)
                if ($null -ne $dte) { break }
            }
            catch {
                # Ignore errors and continue }
            }
        }
        # If no running instance was found, create a new one
        if ($null -eq $dte) {
            try {
                $dte = New-Object -ComObject $vsProgIDs[0]
                # directly use VisualStudio.DTE will use the latest version installed.
                # $dte = New-Object -ComObject VisualStudio.DTE
                $dte.MainWindow.Visible = $true
            }
            catch {
                Write-Error "Could not create a new instance of Visual Studio with ProgID '$($vsProgIDs[0])'."
                exit 1
            }
        }
    }
    else {
        # --- SCENARIO 2: Solution name IS provided. Find the specific VS instance. ---
        $allDtes = [ComHelper]::GetAllDteObjects()

        foreach ($dteInstance in $allDtes) {
            try {
                $solutionPath = $dteInstance.Solution.FullName
                if (-not [string]::IsNullOrEmpty($solutionPath)) {
                    $baseSolutionName = [System.IO.Path]::GetFileNameWithoutExtension($solutionPath)
                    if ($baseSolutionName -eq $SolutionName) {
                        $dte = $dteInstance
                        break
                    }
                }
            }
            catch {
                # Ignore instances that are in a state where we can't read the solution name
            }
        }

        if ($dte -eq $null) {
            Write-Error "Could not find a running Visual Studio instance with solution '$SolutionName'."
            exit 1 # Exit without creating a new instance
        }
    }

    # --- AUTOMATION --- #
    # At this point, we should have the correct DTE object stored in $dte.

    if ($dte -eq $null) {
        Write-Error "Failed to get a handle on a Visual Studio instance."
        exit 1
    }

    try {
        $dte.MainWindow.Activate()
        $dte.ItemOperations.OpenFile($File) | Out-Null

        if ($Line -gt 0) {
            $dte.ActiveDocument.Selection.GoToLine($Line)
        }
        if ($Column -gt 1) {
            $dte.ActiveDocument.Selection.CharRight($false, $Column - 1)
        }
    }
    catch {
        Write-Error "An error occurred while trying to control Visual Studio: $_"
        exit 1
    }

}

# .\open-in-visualstudio.ps1 -File "C:\Repo\Slb\DrillOpsRig\planck\acquisition-profibus-plugin\open-in-visualstudio.ps1" -Line 5 -Column 10
# .\open-in-visualstudio.ps1 -File "C:\Repo\Slb\DrillOpsRig\planck\acquisition-profibus-plugin\open-in-visualstudio.ps1" -Line 5 -Column 10 -SolutionName Slb.Planck.Acquisition.Profibus.Plugin