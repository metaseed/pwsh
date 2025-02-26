function Git-CommitsReview {
	[CmdletBinding()]
	param (
		[Parameter()]
		[string]
		$Branch = "",

		# from which to review all the commits, not include this commit
		[Parameter()]
		[string]
		$CommitFrom = ""
	)
	git pull

	$currentBranchName = (git branch --show-current)
	if ($LASTEXITCODE -ne 0) { throw 'not in a repo' }

	if([string]::IsNullOrEmpty($Branch)) {
		$choiceIndex = $Host.UI.PromptForChoice("The branch to review: ?", "$currentBranchName", @('&Yes', '&No'), 0)
		if ($choiceIndex -ne 0) {
			do {
				Write-Host ""
				$currentBranchName = Read-Host "please input the BRANCH name to switch to for reviewing"
				git checkout $currentBranchName
			}while ($LASTEXITCODE -ne 0);
		}
	} else {
		git checkout $Branch
		if ($LASTEXITCODE -ne 0) {
			return
		}
	}

	if ([string]::IsNullOrEmpty($CommitFrom)) {
		$CommitFrom = Git-ParentCommit
		$needChange = $false
		if([string]::IsNullOrEmpty($CommitFrom)){
			$needChange = $true
		} else {
			$choiceIndex = $Host.UI.PromptForChoice('Do you want to review from this commit(not include)?', "Parent Commit: $CommitFrom", @('&Yes', '&No'), 0)
			if ($choiceIndex -ne 0) {
				$needChange = $true
			}
		}

		if($needChange) {
			do {
				Write-Host ""
				$CommitFrom = Read-Host "please input the branch name (the commit not include in review) or commit id(include in review) to review from"
				git show -s --format="%h %s" "$CommitFrom"
			}while ($LASTEXITCODE -ne 0)
		}

		# Confirm-Continue "we are going to review from this commit(not include): $CommitFrom"
	}

	git rev-parse --verify "refs/heads/$CommitFrom" 2>$null
	if (!$?){ # is commit
		$CommitFrom = "$CommitFrom~1" # previous one
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

# sl C:\repos\SLB\_planck\planck\acquisition-opcua-plugin
# git-commitsReview dev/rcalligrafi/activation