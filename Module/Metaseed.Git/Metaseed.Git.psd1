@{
  RootModule    = 'Metaseed.Git.psm1'
  ModuleVersion = '1.0.2'
  AliasesToExport = @('gitb', 'gitp')
  CmdletsToExport = @()
  FunctionsToExport = @('Git-Branch', 'Git-BranchFromLatestParent', 'Git-CleanBranches', 'Git-HasLocalChanges', 'Git-HasRemoteBranch', 'Git-IsDirty', 'Git-Parent', 'Git-Push', 'Git-PushAll', 'Git-ReDate', 'Git-Review', 'Git-Root', 'Git-SaftyGuard', 'Git-StashClear', 'Git-SwitchRemoteBranch', 'Git-SyncParent', 'Test-GitInstalled', 'Test-GitRepo')
}
