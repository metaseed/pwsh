@{
  RootModule    = 'Metaseed.Git.psm1'
  ModuleVersion = '1.0.2'
  FunctionsToExport = @('Git-Branch','Git-BranchFromLatestMaster','Git-DeleteBranches','Git-HasLocalChanges','Git-HasRemoteBranch','Git-Parent','Git-Push','Git-PushAll','Git-ReDate','Git-Root','Git-SaftyGuard','Git-StashClear','Git-SwitchRemoteBranch','Git-SyncMaster','Test-GitInstalled','Test-GitRepo')
}

