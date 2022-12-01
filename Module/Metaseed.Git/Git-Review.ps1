function Git-Review {
	param (
		[string]$branchName
	)

	if(!(Test-GitRepo)){
		Write-Host "not on a branch"
		return
	}
	$guard = Git-SaftyGuard 'Git-SyncMaster'

	# https://stackoverflow.com/questions/1783405/how-do-i-check-out-a-remote-git-branch
	Write-Execute "git fetch origin $branchName"
	write-execute "git checkout -b $branchName FETCH_HEAD"
	write-execute "git checkout -b '$branchName/review'"
	code .
}