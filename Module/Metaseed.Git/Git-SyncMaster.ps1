function Git-SyncMaster {
  [CmdletBinding()]
  param (
    [Parameter()]
    [switch]
    $rebase,
    [Parameter()]
    [string]
    #('ours', 'theirs','')]
    $strategyOption = ''
  )
  $guard = Git-SaftyGuard 'Git-SyncMaster'
  
  try {
    Write-Step 'sync with remote'
    $hasRemote = Git-HasRemoteBranch
    if ($hasRemote) {
      # the --autostash option just do git stash apply, so the staged and changed would merge into changes(no staged anymore)
      # so we do saftyGuard first
      Write-Execute 'git pull --rebase' 
    }

    $branch = git branch --show-current
    if ($branch -ne 'master') {

      $parent = 'master' # Git-Parent # git-parent has problem
      Write-Attention "parent branch of current branch is: $parent"
      $owner = $branch.split('/')[0]
      if (!$owner -and !$parent.Contains($owner) -and "$parent" -ne 'master') {
        Confirm-Continue "parent branch of current branch is not master or from you($owner)"
      }

      Write-Step 'rebase master with remote'
      Write-Execute 'git checkout master'
      Write-Execute 'git pull --rebase'

      Write-Step "sync branch with master - $($rebase ? 'rebase': 'merge')"
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
        # if ours: we bump version and then conflict found online, then merge master with 'ours', the version in master is not used.
        # if theirs: I modified a file, and other developer submited the change of same location to master, after async, ours is overrided.
        # so we solve conflict manually by default
        if ($strategyOption) {
          Write-Execute "git merge master -s ort -X $strategyOption"
        }
        else {
          Write-Execute "git merge master"
        }
      }

      Write-Step 'push synced changes to remote...'
      # strange although we have pulled at start, if not pull again: Error:
      #  Updates were rejected because the tip of your current branch is behind
      if ($hasRemote) {
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
    # else {
    # we have git status in git-push  
    #   Write-Execute 'git status'
    # }
  }

}