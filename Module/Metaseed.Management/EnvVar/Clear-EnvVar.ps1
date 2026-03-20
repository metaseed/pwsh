<# clean path like env var
1. remove duplication from the user scope.
2. remove duplication from the machine scope.
3. interactively remove duplication between user and machine scope.
#>
function Clear-EnvVar {
    [CmdletBinding()]
    param(
        [Parameter()]
        $Var = 'Path'
    )
    $IsAdmin = Test-Admin
    if (!$IsAdmin) {
        Write-Notice "please run in admin mode"
        return
    }

    $UserVar = Remove-EnvVarDuplicateValues $Var 'User'
    $MachineVar = Remove-EnvVarDuplicateValues $Var 'Machine'

    foreach($machineV  in $MachineVar.Clone()) {
        foreach($userV in $UserVar.Clone()) {
            $uTest = [Path]::GetFullPath($userV)
            $mTest = [Path]::GetFullPath($machineV)
            if($uTest -eq $mTest) {
                $choice = $Host.UI.PromptForChoice("Find duplication $uTest", "would you like to remove it from the &User,&Machine or &Skip this removing?",@('&User', '&Machine', '&Skip'), 0)
                if($choice -eq 0) {
                    $UserVar.Remove($userV)
                    Write-Notice "Removing from user: $userV"
                } elseif($choice -eq 1) {
                    $MachineVar.Remove($machineV)
                    Write-Notice "Removing from machine: $machineV"

                } else {
                    Write-Notice "Skip removing $userV"
                }
            }
        }
    }
}