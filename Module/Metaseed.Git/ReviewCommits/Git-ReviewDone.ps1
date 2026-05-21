<#
.SYNOPSIS
Exits review mode: optionally commits review edits, syncs with origin, and cleans up or continues review.
.DESCRIPTION
Resets branch/index to the feature tip mark ({branch}-mark), leaving review edits unstaged.
When there are changes, prompts for commit message, syncs with origin, commits, and pushes.
-ContinueReview updates the tip mark and re-enters soft-reset review state.
Otherwise removes the tip mark and review.target config.
.PARAMETER CommitMessage
Commit message for review edits. When empty, offers a default derived from HEAD and review.target.
.PARAMETER ContinueReview
After handling changes, sync with origin, advance the tip mark, and git reset --soft to merge-base again.
#>
function Git-ReviewDone {

	param (
		[Parameter()]
		[string]
		$CommitMessage = "",

		[Parameter()]
		[switch]
		$ContinueReview
	)

	# Resolve tip ref from current branch (git-native; works across terminals)
	$currentBranchName = (git branch --show-current)
	$tipRef = "refs/heads/${currentBranchName}-mark"
	$tipSha = git rev-parse $tipRef 2>$null
	if ($LASTEXITCODE -ne 0 -or -not $tipSha) {
		$tipRef = Read-Host "Could not find tip mark for branch ${currentBranchName}. Please input the branch tip ref/commit to restore to"
		$tipSha = git rev-parse $tipRef 2>$null
	}

	# Reset branch + index to feature tip; keep working tree (review edits stay unstaged)
	# Skip when HEAD already advanced past the mark (retry-safe after partial sync/rebase)
	$headSha = git rev-parse HEAD
	if ($headSha -eq $tipSha) {
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

	# Detect unstaged review edits, untracked files, or branch ahead/diverged from remote
	$status = git status
	$hasChanges = $status -match 'modified:|Untracked files:|Your branch is ahead of| have diverged|deleted:'

	if ($hasChanges) {
		# Build or confirm commit message for review fixes
		if ([string]::IsNullOrEmpty($CommitMessage)) {
			$currentCommitInfo = git log -1 --format="%h %s"
			$target = git config review.target
			$CommitMessage = "review-changes on '$currentCommitInfo' (against $target)"
			$choiceIndex = $Host.UI.PromptForChoice('Use this as commit message?', "$CommitMessage", @('&Yes', '&No'), 0)
			if ($choiceIndex -ne 0) {
				$CommitMessage = Read-Host 'please input commit message'
			}
		}

		# User confirms diff before commit/push
		$choiceIndex = $Host.UI.PromptForChoice('Confirm', 'please double check the changes in git!', @('&Yes', '&No'), 1)
		if ($choiceIndex -ne 0) { return }

		# Integrate origin/<branch> before publishing review commit
		if (-not (Sync-ReviewBranchWithOrigin $currentBranchName)) {
			return
		}
		git add -A
		git commit -m "$CommitMessage"
		git push
	}

	if ($ContinueReview) {
		# Stay in review mode: sync, bump tip mark, soft-reset to merge-base again
		if (-not (Sync-ReviewBranchWithOrigin $currentBranchName)) {
			Write-Warning 'Could not sync with origin. Review state preserved; fix sync issues and run Git-ReviewDone -ContinueReview again.'
			return
		}

		git update-ref $tipRef HEAD

		$target = git config review.target
		$mergeBase = git merge-base $target HEAD

		git reset --soft $mergeBase

		Write-Host "Review mode re-entered. merge-base: $mergeBase" -ForegroundColor Green
	}
	else {
		# Exit review mode: remove tip mark and review.target config
		if ($tipRef) {
			git update-ref -d $tipRef
		}
		git config --unset review.target 2>$null
		Write-Host "Review complete. Branch restored to tip." -ForegroundColor Green
	}
}
