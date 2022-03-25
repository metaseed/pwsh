# git -c sequence.editor=notepad rebase --autosquash --interactive head~5
# https://stackoverflow.com/questions/29094595/git-interactive-rebase-without-opening-the-editor
# https://stackoverflow.com/questions/454734/how-can-one-change-the-timestamp-of-an-old-commit-in-git#:~:text=Just%20do%20git%20commit%20%2D%2D,date%20you%20want%20to%20modify.
function Git-ReDate {
  param (
    # commits to modify
    [Parameter()]
    [Int]
    $commits = 3,

    [Parameter()]
    [switch]
    [Alias('np')]
    $NoPush,
    # every commit 1 hour adead of its previous
    [string]
    [ValidateSet('now', 'oneHourAhead', 'oneHourAheadWithRandomMinSec')]
    $date = 'oneHourAheadWithRandomMinSec'
  )
  $guard = Git-SaftyGuard -noKeep 'Git-ReDate'
  try {
    if ($date -eq 'now') {
      ### this way the date of commits are the same
      # It changes both the committer and author dates.
      # replay commits from Head~'$commits' with additional git command on every commit
      # date could be: now, 1 day ago, 1 hour ago, 2 hours ago or $(date)
      git rebase HEAD~"$commits" --exec "git commit --amend --no-edit --date 'now'"
      ###
    }
    else {
      ### mimic interactive way, could modify every commit's author/commit date
      # config the rebase command use the sequence.editor notepad, override the one in .gitconfig
      start-job -scriptblock { 
        git -c sequence.editor=notepad rebase --interactive "head~$using:commits"
      } -name redate

      $git = Find-FromParent .git
      $rebaseFile = "$git/rebase-merge/git-rebase-todo"
      while (!(Test-Path $rebaseFile)) {
        Start-Sleep 1
        Receive-job redate
      }

      ## modify fit-rebase-todo file
      $line = +0;
  (gc $rebaseFile) | # with the parenthesis, return string[]; without, return string to pipe line
      # pick 4ca564e Do something
      # exec git commit --amend --no-edit --date "1 Oct 2019 12:00:00 PDT"
      % {
        $dateTime = (Get-date).AddHours($line - $commits)
        if ($date -eq 'oneHourAheadWithRandomMinSec') {
          $dateTime = $dateTime.AddMinutes($(get-random -Minimum 0 -Maximum 59)).AddSeconds($(get-random -Minimum 0 -Maximum 59))
        }

        $line++
        $_ -replace '(?<pick>^pick.*$)', ('${pick}' + "`nexec git commit --amend --no-edit --date `"$dateTime`"")
      } |
      set-content $rebaseFile
      # code $rebaseFile
      ## close editor to continue the git rebase
      get-process notepad  | ? MainWindowTitle -like 'git-rebase-to*' | % { $_.CloseMainWindow() }
      ## output results
      Receive-job redate -Wait
      ###
    }


    if (!$NoPush) {
      git push --force
    }
  }
  catch {
    Write-Error 'Git-BranchFromLatestMaster execution error.'
  }
  finally {
    Write-Host "-------$guard----"
    if ($guard -eq [GitSaftyGuard]::Stashed) {
      Write-Execute 'git stash apply --index' 'restore index&tree&untracked' # --index: not merge index into worktree, the same as the state before stash
    }
  }

}
