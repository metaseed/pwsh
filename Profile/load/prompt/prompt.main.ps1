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
	$global:__promptIdleState.Value = $null
	$global:__promptIdleState.LastTick = $null

	$usrIcon = $env:IsAdmin ? "`e[93m󰀋`e[0m " : ''
	$dir = $executionContext.SessionState.Path.CurrentLocation.Path
	if ($dir -eq $HOME) {
		$dir = '~'
	}
	Set-PSReadLineOption -ExtraPromptLineCount 0
	"$usrIcon$dir$('>' * ($nestedPromptLevel + 1)) "
}

# Unregister previous subscription on profile reload
if ($global:__idlePromptSub) {
	Unregister-Event -SubscriptionId $global:__idlePromptSub.Id -ErrorAction SilentlyContinue
}

# Hashtable shared via closure — OnIdle can't persist $global: writes
# .Value : $null → [DateTime](tracking) → $true(upgraded)
# .LastTick: previous OnIdle time — gap > 1s means user was typing
$global:__promptIdleState = @{ Value = $null; LastTick = $null }
$idleState = $global:__promptIdleState

# Auto-upgrade to starship after idle delay. OnIdle stops during typing,
# so a tick gap is used to detect and reset after keyboard activity.
$global:__idlePromptSub = Register-EngineEvent -SourceIdentifier "PowerShell.OnIdle" -Action {
	$state = $idleState.Value
	# already upgraded
	if ($state -eq $true) { return }
	# already in starship prompt
	if ($function:prompt -eq $global:_starshipPrompt) { return }

	# gap in OnIdle ticks → user was typing → reset the timer
	$now = [DateTime]::UtcNow
	$gap = $idleState.LastTick -and ($now - $idleState.LastTick).TotalMilliseconds -gt 1000
	$idleState.LastTick = $now
	if ($gap -or $null -eq $state) {
		$idleState.Value = $now
		return
	}

	if (($now - $state).TotalMilliseconds -ge 3000) {
		$idleState.Value = $true
		if (!$global:_starshipPrompt) { $loadStarship.Invoke() }
		$function:prompt = $global:_starshipPrompt
		[Microsoft.PowerShell.PSConsoleReadLine]::InvokePrompt()
		$function:prompt = $global:__defaultPrompt
	}
}

function __ToggleStarshipPrompt {
	$global:__promptIdleState.Value = $null
	$global:__promptIdleState.LastTick = $null
	if ($function:prompt -eq $global:_starshipPrompt) {
		$function:prompt = $global:__defaultPrompt
	}
	else {
		if (!$global:_starshipPrompt) {
			$loadStarship.Invoke()
		}
		$function:prompt = $global:_starshipPrompt
	}
	[Microsoft.PowerShell.PSConsoleReadLine]::InvokePrompt()
	# [Microsoft.PowerShell.PSConsoleReadLine]::AcceptLine() # not inplace replace the prompt
}