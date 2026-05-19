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

	# Reset --mixed back to feature tip unless HEAD already advanced past the mark (retry-safe)
	$tipSha = git rev-parse $tipRef 2>$null
	$headSha = git rev-parse HEAD
	if ($LASTEXITCODE -ne 0 -or -not $tipSha) {
		Write-Warning "Could not resolve tip ref: $tipRef"
		return
	}
	if ($headSha -eq $tipSha) {
		# moves branch pointer + index to tip; keeps working tree (review edits unstaged)
		git reset --mixed $tipRef
	}
	else {
		git merge-base --is-ancestor $tipSha $headSha 2>$null
		if ($LASTEXITCODE -eq 0) {
			Write-Verbose 'Skipping reset --mixed; branch already past review tip mark'
		}
		else {
			Write-Warning "HEAD is not at or ahead of tip mark; resetting to $tipRef"
			git reset --mixed $tipRef
		}
	}

	$status = git status
	$hasChanges = $status -match 'modified:|Untracked files:|Your branch is ahead of| have diverged|deleted:'

	if ($hasChanges) {
		if ([string]::IsNullOrEmpty($CommitMessage)) {
			$currentCommitInfo = git log -1 --format="%h %s"
			$target = git config review.target
			$CommitMessage = "review-changes on '$currentCommitInfo' (against $target)"
			$choiceIndex = $Host.UI.PromptForChoice('Use this as commit message?', "$CommitMessage", @('&Yes', '&No'), 0)
			if ($choiceIndex -ne 0) {
				$CommitMessage = Read-Host 'please input commit message'
			}
		}

		$choiceIndex = $Host.UI.PromptForChoice('Confirm', 'please double check the changes in git!', @('&Yes', '&No'), 1)
		if ($choiceIndex -ne 0) { return }

		if (-not (Sync-ReviewBranchWithOrigin $currentBranchName)) {
			return
		}
		git add -A
		git commit -m "$CommitMessage"
		git push
	}

	if ($ContinueReview) {
		if (-not (Sync-ReviewBranchWithOrigin $currentBranchName)) {
			Write-Warning 'Could not sync with origin. Review state preserved; fix sync issues and run Git-ReviewDone -ContinueReview again.'
			return
		}

		# update tip mark to latest
		git update-ref $tipRef HEAD

		$target = git config review.target
		$mergeBase = git merge-base $target HEAD

		git reset --soft $mergeBase

		Write-Host "Review mode re-entered. merge-base: $mergeBase" -ForegroundColor Green
	}
	else {
		# clean up git-native review state
		if ($tipRef) {
			git update-ref -d $tipRef
		}
		git config --unset review.target 2>$null
		Write-Host "Review complete. Branch restored to tip." -ForegroundColor Green
	}
}
