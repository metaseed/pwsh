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
	$global:__promptIdleUpgrade = $null

	$usrIcon = $env:IsAdmin ? "`e[93m󰀋`e[0m " : ''
	$dir = $executionContext.SessionState.Path.CurrentLocation.Path
	if ($dir -eq $HOME) {
		$dir = '~'
	}
	Set-PSReadLineOption -ExtraPromptLineCount 0
	"$usrIcon$dir$('>' * ($nestedPromptLevel + 1)) "
}

if ($global:__idlePromptSub) {
	Unregister-Event -SubscriptionId $global:__idlePromptSub.Id -ErrorAction SilentlyContinue
}
# Auto-replace the simple prompt with starship after 5s of no typing.
# OnIdle fires repeatedly (~300-500ms) while user sits at the prompt.
# $global:__promptIdleUpgrade: $null -> start tracking, [DateTime] -> tracking, $true -> upgraded
$global:__idlePromptSub = Register-EngineEvent -SourceIdentifier "PowerShell.OnIdle" -Action {
	$s = $global:__promptIdleUpgrade
	if ($s -eq $true) { return }
	if ($global:_starshipPrompt -and $function:prompt -eq $global:_starshipPrompt) { return }

	$line = $cursor = $null
	[Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref]$line, [ref]$cursor)
	if ($line.Length -gt 0) { $global:__promptIdleUpgrade = $null; return }

	if ($null -eq $s) {
		$global:__promptIdleUpgrade = [DateTime]::UtcNow
		return
	}
	if (([DateTime]::UtcNow - $s).TotalSeconds -ge 5) {
		$global:__promptIdleUpgrade = $true
		if (-not $global:_starshipPrompt) {
			$savedPrompt = $function:prompt
			$loadStarship.Invoke()
			$function:prompt = $savedPrompt
		}
		$function:prompt = $global:_starshipPrompt
		[Microsoft.PowerShell.PSConsoleReadLine]::InvokePrompt()
		$function:prompt = $global:__defaultPrompt
	}
}

function __ToggleStarshipPrompt {
	$global:__promptIdleUpgrade = $null
	if ($function:prompt -eq $global:_starshipPrompt) {
		$function:prompt = $global:__defaultPrompt
	}
	else {
		$loadStarship.Invoke()
		$function:prompt = $global:_starshipPrompt
	}
	[Microsoft.PowerShell.PSConsoleReadLine]::AcceptLine()
}