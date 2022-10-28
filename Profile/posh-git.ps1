#  https://github.com/dahlbyk/posh-git
# compare with: https://ohmyposh.dev/docs/segments/git
# all config variables are in:
# https://github.com/dahlbyk/posh-git/tree/master/src/PoshGitTypes.ps1

# https://www.commandline.ninja/customize-pscmdprompt/


# to install posh-git
# PowerShellGet\Install-Module posh-git -Scope CurrentUser -Force
# to update
# PowerShellGet\Update-Module posh-git

# commandlet just run: setup-poshGgit

# the result:
# 05-11 14:31:50 [master ≡ +0 ~5 -0 !] M:\Script\Pwsh
# >
# Import-Module PSProfiler
# Measure-Script {
# module load time about 0.3s
# if(!(git rev-parse --is-inside-work-tree 2>$null)){
#   return
# }

Import-Module posh-git -ErrorAction Ignore
# only config when posh-git is installed
if ($?) {
  $GitPromptSettings.DefaultPromptPrefix.Text = '┌─ $(Get-Date -f "MM-dd HH:mm:ss")$(GetPSReadLineSessionExeTime) $(GetAdminIcon) '
  $GitPromptSettings.DefaultPromptPrefix.ForegroundColor = [ConsoleColor]::Magenta
  #  posh-git uses the `[System.Drawing.ColorTranslator]::FromHtml(string colorName)` method to parse a color name as an HTML color.
  $GitPromptSettings.DefaultPromptPath.ForegroundColor = 'DarkGray'
  $GitPromptSettings.DefaultPromptWriteStatusFirst = $true
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
  $GitPromptSettings.DefaultPromptBeforeSuffix.Text = '`n└─$(PromptWriteErrorInfo) '

  $GitPromptSettings.DefaultPromptBeforeSuffix.ForegroundColor = [ConsoleColor]::Magenta
  $GitPromptSettings.DefaultPromptSuffix = ''
  $GitPromptSettings.EnableStashStatus = $true

  if ($env:WT_SESSION) {
    # https://www.nerdfonts.com/cheat-sheet
    $GitPromptSettings.LocalWorkingStatusSymbol = '' # something in the working dir to add to stage/index
    $GitPromptSettings.LocalStagedStatusSymbol = '' # something on stage to commit
    $GitPromptSettings.BeforeStatus.Text = '[ '
    $GitPromptSettings.BeforePath.Text = ' '
  }
}

function GetAdminIcon {
  $IsAdmin = ([System.Security.Principal.WindowsPrincipal] [System.Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([System.Security.Principal.WindowsBuiltInRole] "Administrator")
  if ($IsAdmin) {
    "`e[93m`e[0m"
  }
  else {
    ''
  }
}

function GetPSReadLineSessionExeTime {
  if ($global:__PSReadLineSessionScope.SessionStartTime) {
    # 19.3s
    $s = ([datetime]::now - $global:__PSReadLineSessionScope.SessionStartTime).totalseconds
    if ($s -lt 1) {
      $color = "`e[32m" #green
    }
    elseif ($s -lt 3) {
      $color = "`e[33m" # yellow
    }
    else {
      $color = "`e[31m" # red
    }
    if ($s -ge 0.01) {
      # clock
      return "${color}祥" + $s.ToString("#,0.00") + "s`e[0m"
    }
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

