# git -c sequence.editor=notepad rebase --autosquash --interactive head~5
# https://stackoverflow.com/questions/29094595/git-interactive-rebase-without-opening-the-editor
# https://stackoverflow.com/questions/454734/how-can-one-change-the-timestamp-of-an-old-commit-in-git#:~:text=Just%20do%20git%20commit%20%2D%2D,date%20you%20want%20to%20modify.
function Git-ReDate {
  param (
    # commits to modify, not include the head~3
    [Parameter()]
    [Int]
    $commits = 3,
    [Parameter()]
    [switch]
    [Alias('np')]
    $NoPush


  )
  ## old way not finished, which mimic interactive way
  # $git = Find-FromParent .git
  # $rebaseFile = "$git/rebase-merge/git-rebase-todo"
  # # config the rebase command use the sequence.editor notepad, override the one in .gitconfig
  # start-job -scriptblock {git -c sequence.editor=notepad rebase --interactive "head~$commits"} -jobname redate

  # (gc $rebaseFile)|
  # # pick 4ca564e Do something
  # # exec git commit --amend --no-edit --date "1 Oct 2019 12:00:00 PDT"
  # % {$_ -replace 'pick', 'do some replacement here like above'}|
  # set-content $rebaseFile
  # get-process notepad  | ? MainWindowTitle -like 'git-rebase-to*'|% {$_.CloseMainWindow()}
  # Receive-job redate
  ##

  ## this way the date of commits are the same
  # It changes both the committer and author dates.
  # replay commits from Head~'$commits' with additional git command on every commit
  # now, 1 day ago, 1 hour ago, or $(date)
  git rebase HEAD~"$commits" --exec "git commit --amend --no-edit --date 'now'"
  ##

  if (!$NoPush) {
    git push --force
  }

}
