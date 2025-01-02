function Git-CommitsReview {
	[CmdletBinding()]
	param (
		# from which to review all the commits, not include this commit
		[Parameter()]
		[string]
		$CommitFrom = ""
	)

	$currentBranchName = (git branch --show-current)
	if ($LASTEXITCODE -ne 0) { throw 'not on a branch' }

	$choiceIndex = $Host.UI.PromptForChoice("The branch to review: ?", "$currentBranchName", @('&Yes', '&No'), 0)
	if ($choiceIndex -ne 0) {
		do {
			Write-Host ""
			$currentBranchName = Read-Host "please input the BRANCH name to switch to for reviewing"
			git checkout $currentBranchName
		}while ($LASTEXITCODE -ne 0);
	}

	git pull

	if ([string]::IsNullOrEmpty($CommitFrom)) {
		$CommitFrom = Git-ParentCommit
		$choiceIndex = $Host.UI.PromptForChoice('Do you want to review from this commit(not include)?', "$CommitFrom", @('&Yes', '&No'), 0)
		if ($choiceIndex -ne 0) {
			do {
				Write-Host ""
				$CommitFrom = Read-Host "please input the commit(branch name or commit id) to review from"
				git show -s --format="%h %s" "$CommitFrom"
			}while ($LASTEXITCODE -ne 0) ;
		}
		# Confirm-Continue "we are going to review from this commit(not include): $CommitFrom"
	}

	# keep the current branch head commit in the a ref
	$tipRef = "refs/heads/${currentBranchName}-mark"

	$global:__git_commits_reivew_branch_tip_mark = $tipRef
	# this will create a file in the folder .git/refs/heads/ as ${currentBranchName}-mark
	# or it will add a row in the .git/packed-refs
	git update-ref $tipRef head
	# move the branch head to the first commit
	git reset $commitFrom --soft
	Write-Notice "let's do the code rewiew now!"
	Write-Notice "the original tip: $tipRef"
}

