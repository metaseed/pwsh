function Git-SwitchRemoteBranch {
    [CmdletBinding()]
    param (
        [Parameter()]
        [string]
        $remoteBranchName
    )

    git fetch origin $remoteBranchName : $remoteBranchName
    git switch $remoteBranchName
}