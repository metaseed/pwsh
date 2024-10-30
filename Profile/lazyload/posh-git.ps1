# https://github.com/dahlbyk/posh-git
# https://github.dev/dahlbyk/posh-git
# compare with: https://ohmyposh.dev/docs/segments/git
# all config variables are in:
# https://github.com/dahlbyk/posh-git/tree/master/src/PoshGitTypes.ps1

# https://www.commandline.ninja/customize-pscmdprompt/


# to install posh-git
# PowerShellGet\Install-Module posh-git -Scope CurrentUser -Force
# to update
# PowerShellGet\Update-Module posh-git

# commandlet just run: setup-poshGit

# the result:
# 05-11 14:31:50 [master ≡ +0 ~5 -0 !] M:\Script\Pwsh
# >
# Import-Module PSProfiler
# Measure-Script {
# module load time about 0.3s
# if(!(git rev-parse --is-inside-work-tree 2>$null)){
#   return
# }
# . $PSScriptRoot/_specialDays.ps1
. $PSScriptRoot/_commandPrompt.ps1
function global:__GetPrefixPrompt {
  return "┌─ $(__GetAdminIcon) $(__GetDateStr)$(__GetLunarDateStr)$(__GetPSReadLineSessionExeTime) "
}

# $ForcePoshGitPrompt to be true
# in vscode, it has defined its own prompt function, so posh-git will not replace it by default.
# we have to pass in the $ForcePoshGitPrompt to be true to force replace it.
Import-Module posh-git -Scope Global -ArgumentList @($true)

# only config when posh-git is installed
if ($?) {
  $global:GitPromptSettings.DefaultPromptPrefix.Text = '$(__GetPrefixPrompt)'
  #$global:GitPromptSettings.DefaultPromptPrefix.ForegroundColor = [ConsoleColor]::Magenta # not use it now, the prefix has color inside
  #  posh-git uses the `[System.Drawing.ColorTranslator]::FromHtml(string colorName)` method to parse a color name as an HTML color.
  $global:GitPromptSettings.DefaultPromptPath.ForegroundColor = 'DarkGray'
  $global:GitPromptSettings.DefaultPromptWriteStatusFirst = $true
  function global:PromptWriteErrorInfo() {
    # While $? also reflects (immediately afterwards) whether an external program reported an exit code of 0 (signaling success, making $? report $true) or a nonzero exit code (typically signaling failure, making $? $false), it is the automatic $LASTEXICODE variable that contains the specific exit code as an integer, and that value is retained until another external program, if any, is called in the same session.
    # $?: true: success, false: failure
    if ($global:GitPromptValues.DollarQuestion) { return }

    # $LASTEXITCODE
    if ($global:GitPromptValues.LastExitCode) {
      # a red exit code
      "`e[31m(" + $global:GitPromptValues.LastExitCode + ")`e[0m"
    }
    else {
      # a red ! is DollarQuestion is false
      "`e[31m!`e[0m"
    }

  }
  # ─→
  $global:GitPromptSettings.DefaultPromptBeforeSuffix.Text = '`n└─$(PromptWriteErrorInfo) '

  $global:GitPromptSettings.DefaultPromptBeforeSuffix.ForegroundColor = [ConsoleColor]::Magenta
  $global:GitPromptSettings.DefaultPromptSuffix = ''
  $global:GitPromptSettings.EnableStashStatus = $true

  if ($env:TERM_NERD_FONT) {
    # https://www.nerdfonts.com/cheat-sheet
    $global:GitPromptSettings.LocalWorkingStatusSymbol = '' # trolley, something in the working dir to add to stage/index
    $global:GitPromptSettings.LocalStagedStatusSymbol = '' # stage, something on stage to commit
    $global:GitPromptSettings.BeforeStatus.Text = '[' # branch
    $global:GitPromptSettings.BeforePath.Text = ''# '' # folder
  }
}


# below logic set the last readline session exectution time, but has problem, when adjust window size
# so set it in prompt starting segments
# function SetStatus {
#   # last readline session running time
#   if ($global:__PSReadLineSessionScope.SessionStartTime) {
#     # 19.3s
#     $s = ([datetime]::now - $global:__PSReadLineSessionScope.SessionStartTime).totalseconds
#     if ($s -ge 0.01) {
#       $x = [Console]::CursorLeft
#       $y = [Console]::CursorTop

#       $time = $s.ToString("#,0.00") + 's'
#       $xNew = [Console]::WindowWidth - $time.Length
#       # if ($y -lt [Console]::WindowHeight - 1) {
#       #   $yNew = $y + 1
#       # }
#       # else {
#       $yNew = $y
#       # }
#       # Write-Host "$xNew $yNew"
#       [Console]::SetCursorPosition($xNew, $yNew)
#       # Write-host $s
#       Write-Host -NoNewline  "${time}"
#       [Console]::SetCursorPosition($x, $y)
#     }
#   }
# }
# # after import posh-git
# if (-not (Test-Path function:\global:PromptBackupForStatus)) {
#   Copy-Item function:\prompt function:\global:PromptBackupForStatus
#   $global:StatusPromptScriptBlock = {
#     PromptBackupForStatus
#     SetStatus
#   }

#   Set-Content -Path function:\prompt -Value $global:StatusPromptScriptBlock -Force
# }

