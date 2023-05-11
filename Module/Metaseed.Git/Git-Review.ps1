function Git-Review {
	param (
		[string]$branchName,
		[switch]$ExactLocalBranchName,
		[int]$depth = -1
	)

	if(!(Test-GitRepo)){
		Write-Host "not on a branch"
		return
	}
	Git-SaftyGuard ' Git-Review'

	# https://stackoverflow.com/questions/1783405/how-do-i-check-out-a-remote-git-branch
	# Write-Execute "git fetch origin $branchName"
	# write-execute "git checkout -b "${branchName}-review" FETCH_HEAD"

	# This will fetch the remote branch and create a new local branch (if not exists already) with name local_branch_name and track the remote one in it.
	if(!$ExactLocalBranchName) {
		$newbranchName = "${branchName}-review"
	} else {
		$newbranchName = $branchName
	}
	if($depth -eq -1) {
	Write-Execute "git fetch origin ${branchName}:${newbranchName}"
	} else {
	Write-Execute "git fetch origin ${branchName}:${newbranchName} --depth=$depth"

	}
	Write-Execute "git checkout ${newbranchName}"
	code .
	# call 'git stash apply --index' to recover after 'git checkout master'
}