#  https://github.com/dahlbyk/posh-git
# to install posh-git
# PowerShellGet\Install-Module posh-git -Scope CurrentUser -Force
# to update
# PowerShellGet\Update-Module posh-git

# commandlet just run: setup-poshGgit

# the result:
# 05-11 14:31:50 [master ≡ +0 ~5 -0 !] M:\Script\Pwsh
# >
Import-Module posh-git -ErrorAction SilentlyContinue
# only config when posh-git is installed
if ($?) {
  $GitPromptSettings.DefaultPromptPrefix.Text = '┌─$(Get-Date -f "MM-dd HH:mm:ss") '
  $GitPromptSettings.DefaultPromptPrefix.ForegroundColor = [ConsoleColor]::Magenta
  #  posh-git uses the `[System.Drawing.ColorTranslator]::FromHtml(string colorName)` method to parse a color name as an HTML color.
  $GitPromptSettings.DefaultPromptPath.ForegroundColor = 'Orange'
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
  $GitPromptSettings.DefaultPromptBeforeSuffix.Text = '`n└─$(PromptWriteErrorInfo)'
  
  $GitPromptSettings.DefaultPromptBeforeSuffix.ForegroundColor = [ConsoleColor]::Magenta
  $GitPromptSettings.DefaultPromptSuffix = ''
}