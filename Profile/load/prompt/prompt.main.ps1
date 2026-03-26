$loadStarship = {
	$global:__defaultPrompt = $function:prompt

	. $PSScriptRoot/specialDays.ps1
	. $PSScriptRoot/promptPrefix.ps1
	# used by starship prompt
	function global:Invoke-Starship-PreCommand {
		$isGitRepo = Test-GitRepo
		$env:PRE_PROMPT = __GetPrefixPrompt $isGitRepo
		$env:GIT_INFO = "$(ParentGitBranch $isGitRepo)`e[93m$($isGitRepo ? "":"")`e[0m"

	}
	. $PSScriptRoot/starship/starship.main.ps1

	$global:_starshipPrompt = $function:prompt

	function global:__GetPrefixPrompt($isGitRepo) {
		$start = $isGitRepo ? "`e[93m[`e[0m": ''
		return "┌─ $(($global:__adminIcon ??= __GetAdminIcon)) $(__GetDateStr)$(__GetLunarDateStr)$(__GetSpecialDayStr)$(__GetPSReadLineSessionExeTime) $start"
	}

	function global:ParentGitBranch($isGitRepo) {
		if (!$isGitRepo) {
			return ""
		}
		$parent = Git-Parent
		$end = "`e[93m]`e[0m"
		if (!$parent) { return $end }
		return "`e[90m$parent$end"
	}

}
function global:prompt {
    $usrIcon = $env:IsAdmin ? "`e[93m󰀋`e[0m " : ''
    $dir = $executionContext.SessionState.Path.CurrentLocation.Path
    if($dir -eq $HOME) {
        $dir = '~'
    }
    "$usrIcon$dir$('>' * ($nestedPromptLevel + 1)) "
}

function __ToggleStarshipPrompt {
	if ($function:prompt -eq $global:_starshipPrompt) {
		$function:prompt = $global:__defaultPrompt
	}
	else {
		# The .Invoke() method runs the scriptblock in the SessionState where it was originally created, not in the current function scope. so we can lazy load the starship prompt at global scope. which make the profile load faster.(from 2.5s to 1.2s)
		$loadStarship.Invoke()
		$function:prompt = $global:_starshipPrompt
	}
	[Microsoft.PowerShell.PSConsoleReadLine]::AcceptLine()
}
