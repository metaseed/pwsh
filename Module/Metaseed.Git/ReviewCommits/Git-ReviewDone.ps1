<#
.SYNOPSIS
Exits review mode: optionally commits review edits, syncs with origin, and cleans up or continues review.
.DESCRIPTION
Resets branch/index to the feature tip mark ({branch}-mark) via reset --mixed.
In both modes review edits end up as unstaged changes against the restored tip.
When there are changes, prompts for commit message, syncs with origin, commits, and pushes.
-ContinueReview updates the tip mark and re-enters review state (--soft or --mixed).
Re-entry mode comes from review.changesStaged (set by Git-Review) unless -ChangesStaged is passed here.
.PARAMETER CommitMessage
Commit message for review edits. When empty, offers a default derived from HEAD and review.target.
.PARAMETER ContinueReview
After handling changes, sync with origin, advance the tip mark, and reset to merge-base again.
.PARAMETER ChangesStaged
When set, overrides review.changesStaged for -ContinueReview re-entry (PR diff in Staged Changes).
When omitted, uses the mode persisted by Git-Review.
#>
function Git-ReviewDone {
	[CmdletBinding()]
	param (
		[Parameter()]
		[string]
		$CommitMessage = "",

		[Parameter()]
		[switch]
		$ContinueReview,

		# Same meaning as Git-Review -ChangesStaged; overrides review.changesStaged when passed
		[Parameter()]
		[switch]
		$ChangesStaged
	)

	# Resolve tip ref from current branch (git-native; works across terminals)
	$currentBranchName = (git branch --show-current)
	$tipRef = "refs/heads/${currentBranchName}-mark"
	do {
		$tipSha = git rev-parse $tipRef 2>$null
		$tipRefInvalid = ($LASTEXITCODE -ne 0 -or -not $tipSha)
		if ($tipRefInvalid) {
			$tipRef = Read-Host "Could not find tip mark for branch ${currentBranchName}. Please input the branch tip ref/commit to restore to"
		}
	} while ($tipRefInvalid)

	# Use Git-Review config unless this call explicitly passes -ChangesStaged (or -ChangesStaged:$false)
	if ($PSCmdlet.MyInvocation.BoundParameters.ContainsKey('ChangesStaged')) {
		$changesStaged = $ChangesStaged
	}
	else {
		$changesStaged = (git config review.changesStaged) -eq 'true'
	}

	# Reset branch + index to feature tip; keep working tree (review edits become unstaged)
	# Skip when HEAD already advanced past the mark (retry-safe after partial sync/rebase)
	$headSha = git rev-parse HEAD
	if ($headSha -eq $tipSha) {
		git reset --mixed $tipRef
	}
	else {
		# tipSha is ancestor of headSha? (HEAD advanced past tip-mark?) i.e. after manual rebase.
		git merge-base --is-ancestor $tipSha $headSha 2>$null
		if ($LASTEXITCODE -eq 0) {
			Write-Verbose 'Skipping reset --mixed; branch already past review tip mark'
		}
		else { # unexpected state: force reset to tip-mark.
			Write-Warning "HEAD diverged from or is behind tip mark; resetting to $tipRef"
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
		$choiceIndex = $Host.UI.PromptForChoice('Continue?', 'please double check the changes in git!', @('&Yes', '&No'), 1)
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
		# Stay in review mode: sync, bump tip mark, reset to merge-base again
		if (-not (Sync-ReviewBranchWithOrigin $currentBranchName)) {
			Write-Warning 'Could not sync with origin. Review state preserved; fix sync issues and run Git-ReviewDone -ContinueReview again.'
			return
		}

		# update review.changesStaged if -ChangesStaged is passed
		if ($PSCmdlet.MyInvocation.BoundParameters.ContainsKey('ChangesStaged')) {
			git config --local review.changesStaged ($ChangesStaged.ToString().ToLower())
		}

		git update-ref $tipRef HEAD

		$target = git config review.target
		$mergeBase = git merge-base $target HEAD

		if ($changesStaged) {
			git reset --soft $mergeBase
		}
		else {
			git reset --mixed $mergeBase
		}

		Write-Host "Review mode re-entered. merge-base: $mergeBase" -ForegroundColor Green
	}
	else {
		# Exit review mode: remove tip mark and review config
		if ($tipRef) {
			git update-ref -d $tipRef
		}
		git config --unset review.target 2>$null
		git config --unset review.changesStaged 2>$null
		Write-Host "Review complete. Branch restored to tip." -ForegroundColor Green
	}
}
