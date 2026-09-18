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

function __GetDirStr {
	$dir = $executionContext.SessionState.Path.CurrentLocation.Path
	if ($dir -eq $HOME) {
		$dir = '~'
	}
	return "`e[93m`e[0m$dir"
}

function __PromptStr {
	$LastErrorInfo = "" #"`e[31m!`e[0m"
	$PRE_PROMPT = "┌─ $(($global:__adminIcon ??= __GetAdminIcon)) $(__GetDateStr)$(__GetLunarDateStr)$(__GetSpecialDayStr)$(__GetPSReadLineSessionExeTime)"
	$POST_PROMPT = "`r`n└─$LastErrorInfo "
	# $GIT_INFO = __GetGitStr #slow
	$GIT_INFO = ""
	$DIR_INFO = __GetDirStr
	return "$PRE_PROMPT$GIT_INFO $DIR_INFO$POST_PROMPT"
}

$script:TransientPrompt = $false
$script:DoesUseLists = (Get-PSReadLineOption).PredictionViewStyle -eq 'ListView'

# default prompt
function global:prompt {
	if ($script:TransientPrompt) {
		$script:TransientPrompt = $false
		Set-PSReadLineOption -ExtraPromptLineCount 0
		return __GetDirStr
	}
	Set-PSReadLineOption -ExtraPromptLineCount 1
	return __PromptStr
}

# used in PS_ReadLineHandler of Enter key
function TransientPrompt {
	$line = $cursor = $null
	[Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref]$line, [ref]$cursor)
	# InvokePrompt redraws the command buffer; if cursor is mid-line, only text before
	# the cursor is shown. Move to end only when needed.
	if ($cursor -lt $line.Length) {
		[Microsoft.PowerShell.PSConsoleReadLine]::EndOfLine()
	}
	$script:TransientPrompt = $true
	[Microsoft.PowerShell.PSConsoleReadLine]::InvokePrompt()
	if ($script:DoesUseLists) {
		# Clear residual ListView predictions without breaking PSReadLine buffer state
		$clearLines = [math]::Min($Host.UI.RawUI.WindowSize.Height - $Host.UI.RawUI.CursorPosition.Y - 1, 12)
		[Microsoft.PowerShell.PSConsoleReadLine]::Insert("`n" * $clearLines)
		[Microsoft.PowerShell.PSConsoleReadLine]::Undo()
	}
}
