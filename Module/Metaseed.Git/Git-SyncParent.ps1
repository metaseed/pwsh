function Git-SyncParent {
  [CmdletBinding()]
  param (
    [Parameter(Mandatory = $false)]
    [string]
    $parent,
    [Parameter()]
    [switch]
    $merge,
    [Parameter()]
    [string]
    #('ours', 'theirs','')]
    $strategyOption = ''
  )
  $guard = Git-StashPushApply {
    Write-Step 'sync with remote'
    $hasRemote = Git-HasRemoteBranch
    if ($hasRemote) {
      # the --autostash option of pull just do git stash apply, so the staged and changed would merge into changes(no staged anymore)
      # so we do saftyGuard first

      Write-Execute 'git pull --rebase'
    }

    $branch = git branch --show-current
    if (!$parent) {
      $parent = git-parent;
      ## now we can trust the git-parent result
      # $choiceIndex = $Host.UI.PromptForChoice('Confirm the parent branch to sync from', "parent branch of is: $parent, use it?(current branch: $branch)", @('&Yes', '&No'), 0)
      # if ($choiceIndex -eq 1) {
      #   $parent = Read-Host "Please enter the parent branch name to sync from."
      #   Confirm-Continue "parent branch of current branch is: $parent"
      # }
      write-Notice "detected parent branch: $parent"
    }


    $owner = $branch.split('/')[0]

    $msg = ""
    if (!$owner -and !$parent.Contains($owner)) {
      $msg += "by the branch names, the parent branch($parent) of current branch is not created by you($owner). "
    }
    if ("$parent" -ne 'master') {
      $msg += "The parent branch is not master."
    }

    if ($msg) {
      Confirm-Continue $msg
    }


    Write-Step "rebase '$parent' with remote"
    Write-Execute "git checkout $parent"
    Write-Execute 'git pull --rebase'

    Write-Step "sync branch with '$parent' - $($merge ? 'merge': 'rebase')"
    if (!$merge) {
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
        $decision = $Host.UI.PromptForChoice('Question', "do you want to merge $parent into ${branch}?", @('&Yes', '&No'), 0)
        if ($decision -eq 0) {
          # parent: change do file commit, branch child, revert change, merge into parent
          # then child: merge parent
          # result: change of the file
          #
          # fix: merge parent before merge parent
          Write-Execute "git merge $parent"

        }
      }
      else {
        ## master
        # strategy or with option prefer
        # if ours: we bump version and then conflict found online, then merge master with 'ours', the version in master is not used.
        # if theirs: I modified a file, and other developer submitted the change of same location to master, after async, ours is overridden.
        # so we solve conflict manually by default
        if ($strategyOption) {
          Write-Execute "git merge master -s ort -X $strategyOption"
        }
        else {
          # noThrow: eitherwise the 'git stash apply' would applied and include the changes in stash.
          Write-Execute "git merge master" -noThrow -noStop
          $mergeError = 0 -ne $LASTEXITCODE
          if ($mergeError) {
            # not apply stash if merge error, otherwise the stash will be applied and the changes to be pushed
            Write-Attention "merge error($LASTEXITCODE), please resolve conflict manually.`nyou local changes are stored on stash, you could do 'git stash apply --index' to restore the changes."
            return
          }
        }
      }
      # Write-Notice "don't forget to push synced changes to remote..."
      Confirm-Continue "do you want to push the merge?"
      Write-Execute "git push"

    }

    # strange although we have pulled   at start, if not pull again: Error:
    #  Updates were rejected because the tip of your current branch is behind
    if ($hasRemote) {
      Write-Execute 'git pull'
    }


  }

}