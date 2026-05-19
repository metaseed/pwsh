function Git-Review {
	[CmdletBinding()]
	param (
		[Parameter()]
		[string]
		$Branch = "",

		# the target branch (or commit) to diff against
		[Parameter()]
		[string]
		$CommitFrom = ""
	)
	$currentBranchName = (git branch --show-current)
	if ($LASTEXITCODE -ne 0) { throw 'not in a repo' }

	# NOTE: avoid `git pull` — it fails silently after `git reset --soft` leaves HEAD behind the index
	git fetch origin
	git merge --ff-only "origin/$currentBranchName" 2>$null

	# checkout the branch to review
	if ([string]::IsNullOrEmpty($Branch)) {
		$choiceIndex = $Host.UI.PromptForChoice("The branch to review: ?", "$currentBranchName", @('&Yes', '&No'), 0)
		if ($choiceIndex -ne 0) {
			do {
				Write-Host ""
				$currentBranchName = Read-Host "please input the BRANCH name to switch to for reviewing"
				git checkout $currentBranchName
			} while ($LASTEXITCODE -ne 0);
		}
	}
	else {
		git checkout $Branch
		if ($LASTEXITCODE -ne 0) { return }
		$currentBranchName = $Branch
	}
	# NOTE: avoid `git pull` — it fails silently after `git reset --soft` leaves HEAD behind the index
	git fetch origin
	git merge --ff-only "origin/$currentBranchName" 2>$null

	if ([string]::IsNullOrEmpty($CommitFrom)) {
		$CommitFrom = Git-Parent
		$needChange = $false
		if ([string]::IsNullOrEmpty($CommitFrom)) {
			$needChange = $true
		}
		else {
			$choiceIndex = $Host.UI.PromptForChoice('Review against this target branch?', "Target: $CommitFrom", @('&Yes', '&No'), 0)
			if ($choiceIndex -ne 0) {
				$needChange = $true
			}
		}

		if ($needChange) {
			do {
				Write-Host ""
				$CommitFrom = Read-Host "please input the TARGET branch name (e.g. master, main) to diff against"
				git rev-parse --verify "$CommitFrom" 2>$null
			} while ($LASTEXITCODE -ne 0)
		}
	}

	# ensure we have the latest target branch for accurate merge-base
	$targetIsLocalBranch = git rev-parse --verify "refs/heads/$CommitFrom" 2>$null
	if ($targetIsLocalBranch) { # if $CommitFrom is a SHA, it will not be a local branch
		# updates that local branch from origin/$CommitFrom.
		# merge-base uses whatever commit $CommitFrom currently points to. If local main is behind origin/main, you get the wrong common ancestor
		git fetch origin "${CommitFrom}:${CommitFrom}" 2>$null
	}

	# find the merge-base: the common ancestor that excludes merge noise
	# A----C------D (master / target branch)
	#       \       \
	#        \---E---\---F---Head   (your feature branch)
	# merge-base(master, Head) = D, so diff shows only E + F's unique changes
	$mergeBase = git merge-base $CommitFrom HEAD
	if ($LASTEXITCODE -ne 0) {
		Write-Error "Could not find merge-base between '$CommitFrom' and HEAD"
		return
	}

	# persist review state in git-native storage (works across terminals)
	git config --local review.commitFrom $CommitFrom

	# keep the current branch tip in a ref for recovery
	$tipRef = "refs/heads/${currentBranchName}-mark"
	git update-ref $tipRef HEAD

	# --soft moves HEAD to merge-base but keeps index+working tree at feature tip.
	# Result: "Staged Changes" = PR diff, user edits appear in "Changes" (unstaged)
	git reset --soft $mergeBase

	Write-Host ""
	Write-Host "PR-style review is ready!" -ForegroundColor Green
	Write-Host "  'Staged Changes' in VS Code = your PR diff (only feature changes, merges excluded)" -ForegroundColor Cyan
	Write-Host "  Your edits during review will appear in 'Changes' (unstaged)" -ForegroundColor Cyan
	Write-Host "  Working tree = branch tip code (debuggable, runnable)" -ForegroundColor Cyan
	Write-Host ""
	Write-Host "  merge-base: $mergeBase" -ForegroundColor DarkGray
	Write-Host "  target:     $CommitFrom" -ForegroundColor DarkGray
	Write-Host "  tip mark:   $tipRef" -ForegroundColor DarkGray
	Write-Host ""
	Write-Host "When done, run: " -ForegroundColor Yellow -NoNewline
	Write-Host "Git-ReviewDone" -ForegroundColor White
}
