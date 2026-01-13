# link to in M:\Script\Pwsh\Module\Metaseed.Git\Git-SetupHooks.ps1
function Git-SetupHooks {
# git init' will not copy the hook if it already exists
    $inRepo = Test-GitRepo
	if(!$inRepo){
		Write-Error "Not in a Git repository"
		Exit 1
	}

	# go to the repo folder which contains .git
 	$git = Find-FromParent .git
	$checkout = "$git\hooks\post-checkout"
	if(test-path $checkout){
		$backup = "$git\hooks\post-checkout_backup$(Get-Date -f FileDateTime)"
		Write-Host "Backing up existing post-checkout hook: $backup"
		copy-item $checkout $backup
	}
	ni -type SymbolicLink -Force -Path "$git\hooks\post-checkout" -Target "M:\Script\Pwsh\Module\Metaseed.Git\_features\parent-branch\resources\.git-templates\hooks\post-checkout"
}