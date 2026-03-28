. $PSScriptRoot/promptPrefix.ps1
$loadStarship = {
	$global:__defaultPrompt = $function:prompt
	. $PSScriptRoot/promptLunarDate.ps1
	. $PSScriptRoot/specialDays.ps1
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
# default prompt
function global:prompt {
	$global:__promptIdleState.Value = $null
	$global:__promptIdleState.LastTick = $null

	$dir = $executionContext.SessionState.Path.CurrentLocation.Path
	if ($dir -eq $HOME) {
		$dir = '~'
	}
	Set-PSReadLineOption -ExtraPromptLineCount 0
	"$(($global:__adminIcon ??= __GetAdminIcon)) $(__GetDateStr) $dir$('>' * ($nestedPromptLevel + 1)) "
	# "$dir$('>' * ($nestedPromptLevel + 1)) "
}

# Unregister previous subscription on profile reload
$null = Unregister-Event -SourceIdentifier "PowerShell.OnIdle" -ErrorAction Ignore

# Hashtable shared via closure — OnIdle can't persist $global: writes
# .Value : $null → [DateTime](tracking) → $true(upgraded)
# .LastTick: previous OnIdle time — gap > 1s means user was typing
$global:__promptIdleState = @{ Value = $null; LastTick = $null }
$idleState = $global:__promptIdleState

# Auto-upgrade to starship after idle delay. OnIdle stops during typing,
# so a tick gap is used to detect and reset after keyboard activity.
# Skip in VS Code — its host runs OnIdle actions inside an existing pipeline, causing crashes.
if ($host.Name -ne 'Visual Studio Code Host') {
	$null = Register-EngineEvent -SourceIdentifier "PowerShell.OnIdle" -Action {
		$state = $idleState.Value
		# already upgraded
		if ($state -eq $true) { return }

		# already in starship prompt
		if ($function:prompt -eq $global:_starshipPrompt) { return }
		$now = [DateTime]::UtcNow

		# new prompt
		if ($null -eq $state) {
			$idleState.Value = $now
			return
		}

		# gap in OnIdle ticks → user was typing → reset the timer
		# user has input something, which paused the idle event when not debugging in vscode,
		# when triggered again.(i.e. remove the input), in this case we assume the pause interval is > 1s
		$onInputGap = $idleState.LastTick -and ($now - $idleState.LastTick).TotalMilliseconds -gt 1000
		$idleState.LastTick = $now
		if ($onInputGap) {
			$idleState.Value = $now
			return
		}

		# the delay
		if (($now - $state).TotalMilliseconds -le 3000) {
			return
		}

		# in vscode debug console, after reload the profile even the buffer has something, if not further input, the handler still trigger
		$line = $cursor = $null
		[Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref]$line, [ref]$cursor)
		if ($line.Length -gt 0) {
			$idleState.Value = $now
			return
		}

		if (!$global:_starshipPrompt) { $loadStarship.Invoke() }
		$idleState.Value = $true
		$function:prompt = $global:_starshipPrompt
		[Microsoft.PowerShell.PSConsoleReadLine]::InvokePrompt()
		$function:prompt = $global:__defaultPrompt

	}
}
$script:DoesUseLists = (Get-PSReadLineOption).PredictionViewStyle -eq 'ListView'

function TransientPrompt {
	$savedPrompt = $function:prompt
	$function:prompt = $global:__defaultPrompt
	[Microsoft.PowerShell.PSConsoleReadLine]::InvokePrompt()
	if ($Script:DoesUseLists) {
		[Console]::Write("`e[J") # clear residual ListView predictions below the prompt
	}
	$function:prompt = $savedPrompt
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