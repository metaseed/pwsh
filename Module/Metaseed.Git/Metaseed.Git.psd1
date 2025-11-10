@{
  RootModule    = 'Metaseed.Git.psm1'
  ModuleVersion = '1.0.2'
  AliasesToExport = @('gitb', 'gitp')
  CmdletsToExport = @()
  FunctionsToExport = @('Git-Branch', 'Git-CleanBranches', 'Git-CommitsReview', 'Git-CommitsReviewDone', 'Git-HasLocalChanges', 'Git-HasRemoteBranch', 'Git-IsDirty', 'Git-NewBranch', 'Git-Parent', 'Git-ParentCommit', 'Git-ParentCommitMessage', 'Git-Push', 'Git-PushAll', 'Git-ReDate', 'Git-Review', 'Git-Root', 'Git-Stash', 'Git-StashClean', 'Git-StashPushApply', 'Git-SwitchRemoteBranch', 'Git-SyncParent', 'Test-GitInstalled', 'Test-GitRepo')
}
