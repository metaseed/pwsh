function Sync-ReviewBranchWithOrigin {
	param (
		[Parameter(Mandatory)]
		[string]
		$BranchName
	)

	$remoteRef = "origin/$BranchName"
	$stashMsg = 'Git-ReviewDone: review edits'

	git fetch origin
	if ($LASTEXITCODE -ne 0) {
		Write-Warning 'git fetch origin failed.'
		return $false
	}

	git rev-parse --verify $remoteRef 2>$null | Out-Null
	if ($LASTEXITCODE -ne 0) {
		Write-Warning "Remote ref $remoteRef not found after fetch."
		return $false
	}

	if (Test-ReviewFfOnlyMerge $remoteRef) {
		return $true
	}

	$stashOut = git stash push -u -m $stashMsg 2>&1 | Out-String
	$stashed = $LASTEXITCODE -eq 0 -and $stashOut -notmatch 'No local changes to save'

	if (Test-ReviewFfOnlyMerge $remoteRef) {
		if ($stashed) {
			if (-not (Restore-ReviewStash)) { return $false }
		}
		return $true
	}

	git rebase $remoteRef 2>&1 | Out-Null
	if ($LASTEXITCODE -ne 0) {
		if ((Test-Path .git/rebase-merge) -or (Test-Path .git/rebase-apply)) {
			git rebase --abort 2>$null
		}
		if ($stashed) {
			Write-Warning @"
Rebase stopped with conflicts. Fix files, run 'git rebase --continue', then run Git-ReviewDone again.
Review edits are in stash (message: $stashMsg):
"@
			git stash list
		}
		else {
			Write-Warning "Rebase onto $remoteRef failed. Resolve with 'git rebase --continue' or abort, then run Git-ReviewDone again."
		}
		return $false
	}

	if ($stashed) {
		if (-not (Restore-ReviewStash)) { return $false }
	}
	return $true
}

function Test-ReviewFfOnlyMerge {
	param ([string]$RemoteRef)
	git merge --ff-only $RemoteRef 2>$null
	return $LASTEXITCODE -eq 0
}

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
