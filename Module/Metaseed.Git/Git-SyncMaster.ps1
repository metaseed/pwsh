function Git-SyncMaster {
  [CmdletBinding()]
  param (
    [Parameter()]
    [switch]
    $merge
  )
  $guard = Git-SaftyGuard 'Git-SyncMaster' -noKeep

  try {
    ## rebase branch with remote
    if (Git-HasRemoteBranch) {
      # the --autostash option just do git stash apply, so the staged and changed would merge into changes(no staged anymore)
      # so we do saftyGuard first
      Write-Execute 'git pull --rebase' 
    }

    $parent = Git-Parent

    $branch = git branch --show-current
    if ($branch -ne 'master') {
      Write-Step 'rebase master with remote'
      Write-Execute 'git checkout master'
      Write-Execute 'git pull --rebase'

      Write-Step 'sync branch with master'
      if (!$merge) {
        if ($parent -ne 'master') {
          # replay one by one, may resolve conflict several times
          # so merge parent to reduce conflicts.
          Write-Execute "git merge $parent -s ort -X theirs"
        }
        Write-Execute "git checkout $branch"
        Write-Execute "git rebase --onto master $parent" #--fork-point"
      }
      else {
        Write-Execute "git checkout $branch"
        ## merge parent branch
        if ($parent -ne 'master') {
          # parent: change a file, branch child, revert change, merge into master
          # then child: merge master
          # result: change of the file
          #
          # fix: merge parent before merge master
          Write-Execute "git merge $parent"
        }
        ##
        # strategy ort with option prefer ours
        Write-Execute "git merge master -s ort -X ours"
      }
      Write-Execute "git-push"
    }
  }
  catch {
    Write-Error 'Git-RebaseMaster execution error.'
  }
  finally {
    if ($guard -eq [GitSaftyGuard]::Stashed) {
      Write-Execute 'git stash apply --index' 'restore index&tree&untracked' # --index: not merge index into worktree, the same as the state before stash
    }
  }
  Write-Execute 'git status'

}