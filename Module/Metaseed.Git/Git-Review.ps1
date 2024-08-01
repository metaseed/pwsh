<#
This will fetch the remote branch and create a new local branch (if not exists already)
with name ${branchName}-review and track the remote one in it.

note: if want to continue contributing on the branch, we should not give a depth, i.e. when use --depth 1, we then do git pull, there will be a lot obj to merge.
#>
function Git-Review {
	param (
		[string]$branchName,
		[switch]$appendReviewToLocalBranchName,
		# default to get all commit history
		[int]$depth = -1
	)

	if (!(Test-GitRepo)) {
		Write-Host "not on a branch"
		return
	}
	Git-SaftyGuard ' Git-Review'

	# https://stackoverflow.com/questions/1783405/how-do-i-check-out-a-remote-git-branch
	# Write-Execute "git fetch origin $branchName"
	# write-execute "git checkout -b "${branchName}-review" FETCH_HEAD"

	if ($appendReviewToLocalBranchName) {
		$newbranchName = "${branchName}-review"
	}
	else {
		 $newbranchName = $branchName
	}

	if ($depth -eq -1) {
		Write-Execute "git fetch origin ${branchName}:${newbranchName}"
	}
	else {
		Write-Execute "git fetch origin ${branchName}:${newbranchName} --depth=$depth"
	}

	# note: fail when no the same as remote name
	# we can do experiment and try: --set-upstream and --track
	# https://www.git-scm.com/docs/git-branch/2.13.7#Documentation/git-branch.txt---track
	Write-Execute "git branch ${newbranchName} --set-upstream-to=${branchName}"
	Write-Execute "git checkout ${newbranchName}"
	# Explicitly setup up the upstream to track the right remote branch
	# Write-Execute "git push --set-upstream origin ${branchName}"

	code .
	# call 'git stash apply --index' to recover after 'git checkout master'
}

# to clone a remote branch:
# this will create a folder in current directory
# git clone -b release/24.04 https://slb1-swt.visualstudio.com/Planck/_git/planck --depth 1

## reason analysis: https://stackoverflow.com/questions/1783405/how-do-i-check-out-a-remote-git-branch/78816857#answer-76785562
# git config --get remote.origin.fetch
#
# it is stored in the local repo root folder's .git/config file
# [remote "origin"]
# 	url = https://slb1-swt.visualstudio.com/Planck/_git/planck
# 	fetch = +refs/heads/master:refs/remotes/origin/master
#
# will return: +refs/heads/master:refs/remotes/origin/master
# which happens when clone the repo with the --single-branch
# we need to change it with:
# git config remote.origin.fetch "+refs/heads/*:refs/remotes/origin/*"
# then we can do it simply:
# git fetch
# git checkout branchName

