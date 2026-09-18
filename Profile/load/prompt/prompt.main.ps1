. $PSScriptRoot/promptPrefix.ps1
. $PSScriptRoot/promptLunarDate.ps1
. $PSScriptRoot/specialDays.ps1

# too slow
function __ParentGitBranch($isGitRepo) {
	if (!$isGitRepo) {
		return ""
	}
	$parent = Git-Parent # too slow
	$end = "`e[93m]`e[0m"
	if (!$parent) { return $end }
	return "`e[90m$parent$end"
}

function __GetGitStr {
	$isGitRepo = Test-GitRepo
	$start = $isGitRepo ? "`e[93m[`e[0m": '' # yellow '['
	$gitInfo = ""
	$gitParent = __ParentGitBranch $isGitRepo
	$end = $isGitRepo ? "`e[93m]`e[0m" : '' # yellow ']'
	$folderIcon = "`e[93m$($isGitRepo ? "":"")`e[0m"
	return "$start$gitInfo$gitParent$end$folderIcon"
}

function __PromptStr {
	$dir = $executionContext.SessionState.Path.CurrentLocation.Path
	if ($dir -eq $HOME) {
		$dir = '~'
	}

	$LastErrorInfo = "" #"`e[31m!`e[0m"
	$PRE_PROMPT = "┌─ $(($global:__adminIcon ??= __GetAdminIcon)) $(__GetDateStr)$(__GetLunarDateStr)$(__GetSpecialDayStr)$(__GetPSReadLineSessionExeTime)"
	$POST_PROMPT = "`r`n└─$LastErrorInfo "
	# $GIT_INFO = __GetGitStr #slow
	$DIR_INFO = "$dir"
	return "$PRE_PROMPT$GIT_INFO$DIR_INFO$POST_PROMPT"
}

# default prompt
function global:prompt {
	Set-PSReadLineOption -ExtraPromptLineCount 0
	# "$(($global:__adminIcon ??= __GetAdminIcon)) $(__GetDateStr) $dir$('>' * ($nestedPromptLevel + 1)) "
	# "$dir$('>' * ($nestedPromptLevel + 1)) "
	return __PromptStr
}

$script:DoesUseLists = (Get-PSReadLineOption).PredictionViewStyle -eq 'ListView'

# used in PS_ReadLineHandler of Enter key
function TransientPrompt {
	if ($null -eq $global:__defaultPrompt) { return } # no need to do Transient

	$savedPrompt = $function:prompt
	$function:prompt = $global:__defaultPrompt
	[Microsoft.PowerShell.PSConsoleReadLine]::EndOfLine() # when cursor is not at the end, and user `enter` to execute the cmd, it will cut off the remaining content and just show partial of the last executed cmd. So move to end to avoid the problem.
	# InvokePrompt: 1. erase the full prompt; 2. re-run prompt function to draw the shorter transient version prompt; 3. redraw the command line buffer(problem here when cursor is in middle);
	[Microsoft.PowerShell.PSConsoleReadLine]::InvokePrompt()
	if ($Script:DoesUseLists) {
		[Console]::Write("`e[J") # clear residual ListView predictions below the prompt
	}
	$function:prompt = $savedPrompt
}
