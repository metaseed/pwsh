function Git-StashPushApply {
	param (
		[Parameter(Mandatory = $true)]
		[scriptblock]$Code
	)

	try {
		$parentFunc = ""
		$callStack = Get-PSCallStack
		if ($callStack.Count -ge 2) {
			$parentFunc += "$($callStack[1].Command)"
		}
		$guard = & Git-Stash -message "callFrom Func:$parentFunc"
		Write-Verbose "Running main code..."
		# with &, can use var outside, but can not modify, if needed can be changed to .
		& $Code
	}
	catch {
		Write-Error "${parentFunc}: Error during execution: $_"
		throw
	}
	finally {
		Write-Verbose "Running git post-execution..."
		if ($guard -eq [GitSaftyGuard]::Stashed) {
			# --index: not merge index into worktree, the same as the state before stash
			Write-Execute 'git stash apply --index' 'restore index&tree&untracked'
		}
		else {
			Write-Execute 'git status'

		}
	}

}