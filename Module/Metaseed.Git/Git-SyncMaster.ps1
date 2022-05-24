function Git-SyncMaster {
  [CmdletBinding()]
  param (
    [Parameter()]
    [switch]
    $rebase
  )
  $guard = Git-SaftyGuard 'Git-SyncMaster' -noKeep

  try {
    ## sync with remote
    if (Git-HasRemoteBranch) {
      # the --autostash option just do git stash apply, so the staged and changed would merge into changes(no staged anymore)
      # so we do saftyGuard first
      Write-Execute 'git pull' 
    }

    $branch = git branch --show-current
    if ($branch -ne 'master') {

      $parent = 'master' # Git-Parent
      Write-Host "parent branch of current branch is: $parent" -ForegroundColor Green
      $owner = $branch.split('/')[0]
      if (!$owner -and !$parent.Contains($owner) -and "$parent" -ne 'master') {
        Confirm-Continue "parent branch of current branch is not master or from you($owner)"
      }

      Write-Step 'rebase master with remote'
      Write-Execute 'git checkout master'
      Write-Execute 'git pull --rebase'

      Write-Step 'sync branch with master'
      if ($rebase) {
        # rebase
        if ($parent -ne 'master') {
          # replay one by one, may resolve conflict several times
          # so merge parent to reduce conflicts.
          Write-Execute "git merge $parent -s ort -X ours"
        }
        Write-Execute "git checkout $branch"
        if ($parent -eq 'master') {
          Write-Execute "git rebase $parent -X theirs"
        }
        else {
          Write-Execute "git rebase --onto master $parent -X theirs" #--fork-point"
        }
      }
      else {
        Write-Execute "git checkout $branch"
        ## merge parent branch
        if ($parent -ne 'master') {
          $decision = $Host.UI.PromptForChoice('Question', "do you want to merge $parent into $branch?", @('&Yes', '&No'), 1)
          if ($decision -eq 0) {
            # parent: change do file commit, branch child, revert change, merge into master
            # then child: merge master
            # result: change of the file
            #
            # fix: merge parent before merge master
            Write-Execute "git merge $parent"

          } 
        }
        ##
        # strategy or with option prefer
        # if ours: we bump version and then conflict, then merge master with 'ours', the version in master is not used. 
        # try theirs if have problem, try not using any stragety, and solve conflict manually
        Write-Execute "git merge master -s ort -X theirs"
      }

      # strange although we have pulled at start, if not pull again: Error:
      #  Updates were rejected because the tip of your current branch is behind
      if (Git-HasRemoteBranch) {
        Write-Execute 'git pull' 
      }

      git-push
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