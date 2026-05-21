<#
.SYNOPSIS
Integrates origin/<branch> into the local review branch before commit or continue.
.DESCRIPTION
Fetches origin, then fast-forwards when possible. If local and remote diverged,
stashes review edits, rebases onto origin/<branch>, and restores the stash.
Returns $true when the branch is synced; $false on fetch, rebase, or stash-pop failure.
#>
function Sync-ReviewBranchWithOrigin {
	param (
		[Parameter(Mandatory)]
		[string]
		$BranchName
	)

	$remoteRef = "origin/$BranchName"
	$stashMsg = 'Git-ReviewDone: review edits'

	# Fetch latest remote refs so origin/<branch> is current
	git fetch origin
	if ($LASTEXITCODE -ne 0) {
		Write-Warning 'git fetch origin failed.'
		return $false
	}

	# Ensure the tracking ref exists after fetch
	git rev-parse --verify $remoteRef 2>$null | Out-Null
	if ($LASTEXITCODE -ne 0) {
		Write-Warning "Remote ref $remoteRef not found after fetch."
		return $false
	}

	# Fast-forward only when local is strictly behind remote (no stash needed)
	if (Test-ReviewFfOnlyMerge $remoteRef) {
		return $true
	}

	# Diverged or ahead: stash review edits so merge/rebase can run on a clean tree
	$stashOut = git stash push -u -m $stashMsg 2>&1 | Out-String
	$stashed = $LASTEXITCODE -eq 0 -and $stashOut -notmatch 'No local changes to save'

	# Stash may have removed the only divergence; retry ff-only before rebase
	if (Test-ReviewFfOnlyMerge $remoteRef) {
		if ($stashed) {
			if (-not (Restore-ReviewStash)) { return $false }
		}
		return $true
	}

	# Still diverged: replay local commits on top of origin/<branch>
	git rebase $remoteRef 2>&1 | Out-Null
	if ($LASTEXITCODE -ne 0) {
		# Leave repo in a clean state; user resolves rebase manually
		if ((Test-Path .git/rebase-merge) -or (Test-Path .git/rebase-apply)) {
			git rebase --abort 2>$null
		}
		if ($stashed) {
			Write-Warning @"
Rebase stopped with conflicts and was aborted. Review edits are in stash (message: $stashMsg).
To fix: git rebase $remoteRef, git stash pop, then Git-ReviewDone again.
"@
		}
		else {
			Write-Warning "Rebase onto $remoteRef failed. Resolve with 'git rebase $remoteRef', then run Git-ReviewDone again."
		}
		return $false
	}

	# Rebase succeeded: put review edits back on the synced branch
	if ($stashed) {
		if (-not (Restore-ReviewStash)) { return $false }
	}
	return $true
}

<#
.SYNOPSIS
Attempts a fast-forward merge from a remote ref without creating a merge commit.
#>
function Test-ReviewFfOnlyMerge {
	param ([string]$RemoteRef)
	git merge --ff-only $RemoteRef 2>$null
	return $LASTEXITCODE -eq 0
}

<#
.SYNOPSIS
Restores the review-edits stash after a successful sync.
#>
function Restore-ReviewStash {
	git stash pop 2>&1 | Out-Null
	if ($LASTEXITCODE -ne 0) {
		Write-Warning @"
Remote synced, but review edits conflict with upstream. Resolve working tree, then run Git-ReviewDone again (or 'git stash pop' manually).
Stash entries:
"@
		git stash list
		return $false
	}
	return $true
}
