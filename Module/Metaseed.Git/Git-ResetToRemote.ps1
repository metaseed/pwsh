function Git-ResetToRemote {
	param (
		[Parameter()]
		[string]
		$BranchName,
		[Parameter()]
		[switch]
		$ResetIgnoredFiles
	)
	$currentBranchName = (git branch --show-current)
	if ($LASTEXITCODE -ne 0) { throw 'not in a repo' }

	if (-not $BranchName) {
		$BranchName = $currentBranchName
	}

	git fetch origin
	git reset --hard "origin/$BranchName"
	if ($ResetIgnoredFiles) {
		git clean -fdx
	}
	else {
		git clean -fd
	}
}