function Git-ReviewDone {
	param (
		[Parameter()]
		[string]
		$CommitMessage = "",

		[Parameter()]
		[switch]
		$ContinueReview
	)

	# Discover tip ref from current branch name (git-native, works across terminals)
	$currentBranchName = (git branch --show-current)
	$tipRef = "refs/heads/${currentBranchName}-mark"
	git rev-parse --verify $tipRef 2>$null | Out-Null
	if ($LASTEXITCODE -ne 0) {
		$tipRef = Read-Host 'Could not find tip mark. Please input the branch tip ref/commit to restore to'
	}

	# Reset --mixed back to feature tip: moves branch pointer + index to tip, keeps working tree
	# After this, only the user's review edits remain as unstaged changes
	git reset --mixed $tipRef

	$hasChanges = Git-HasLocalChanges

	if ($hasChanges) {
		if ([string]::IsNullOrEmpty($CommitMessage)) {
			$currentCommitInfo = git log -1 --format="%h %s"
			$commitFrom = git config review.commitFrom
			$CommitMessage = "review-changes on '$currentCommitInfo' (against $commitFrom)"
			$choiceIndex = $Host.UI.PromptForChoice('Use this as commit message?', "$CommitMessage", @('&Yes', '&No'), 0)
			if ($choiceIndex -ne 0) {
				$CommitMessage = Read-Host 'please input commit message'
			}
		}

		$choiceIndex = $Host.UI.PromptForChoice('Confirm', 'please double check the changes in git!', @('&Yes', '&No'), 1)
		if ($choiceIndex -ne 0) { return }

		$CommitMessage = $CommitMessage -replace '-', ' '
		git add -A
		git commit -m "$CommitMessage"
		git push
	}

	if ($ContinueReview) {
		# NOTE: avoid `git pull` — it fails silently after `git reset --soft` leaves HEAD behind the index
		git fetch origin
		git merge --ff-only "origin/$currentBranchName" 2>$null

		# update tip mark to latest
		git update-ref $tipRef HEAD

		$commitFrom = git config review.commitFrom
		$mergeBase = git merge-base $commitFrom HEAD

		git reset --soft $mergeBase

		Write-Host "Review mode re-entered. merge-base: $mergeBase" -ForegroundColor Green
	}
	else {
		# clean up git-native review state
		if ($tipRef) {
			git update-ref -d $tipRef
		}
		git config --unset review.commitFrom 2>$null
		Write-Host "Review complete. Branch restored to tip." -ForegroundColor Green
	}
}
