function Git-CommitsReviewDone {
	param (
		# commit message
		[Parameter()]
		[string]
		$CommitMessage = ""
	)

	# get tipRef
	$tipRef = $global:__git_commits_reivew_branch_tip_mark
	$inputRefCommit = $true
	if (!$tipRef) {
		$currentBranchName = (git branch --show-current)
		$tipRefTest = "refs/heads/${currentBranchName}-mark"
		git show -s --format="%h %s" "$tipRefTest"
		if ($LASTEXITCODE -eq 0) {
			$choiceIndex = $Host.UI.PromptForChoice('Move Current Branch Head', "Move the branch Head to the commit: ${tipRefTest}?", @('&Yes', '&No'), 0)
			if ($choiceIndex -eq 0) {
				$tipRef = $tipRefTest
				$inputRefCommit = $false
			}
		}
	} else {
		$inputRefCommit = $false
	}

	if ($inputRefCommit) {
		$tipRef = Read-host 'please input the branch tip commit which we will move the current branch head to'
	}

	# commit changes
	$currentCommitInfo = git log -1 --format="%h %s" # hash and string message

	git reset $tipRef --soft

	$hasLocalChanges = Git-HasLocalChanges

	if ($hasLocalChanges) {
		if ([string]::IsNullOrEmpty($CommitMessage)) {
			# we need to get the current commit info before 'git reset --soft'
			$tipCommitInfo = git show -s --format="%h %s" "$tipRef"
			$CommitMessage = "code-review-changes from '$currentCommitInfo' to '$tipCommitInfo'"
			$choiceIndex = $Host.UI.PromptForChoice('Do you want to use this as commit message', "$CommitMessage", @('&Yes', '&No'), 0)
			if ($choiceIndex -ne 0) {
				$CommitMessage = Read-Host 'please input commit message'
			}
		}

		Confirm-Continue "please double check the changes in git!"

		git-pushAll "$CommitMessage"
	}

	# delete the ref
	git update-ref -d $tipRef
}