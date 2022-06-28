# https://docs.microsoft.com/en-us/windows/configuration/configure-windows-10-taskbar
# https://superuser.com/questions/1617185/how-to-pin-lnk-files-to-taskbar-in-powershell
<#
#>
function Pin-TaskBar {
  [CmdletBinding()]
  param(
    [parameter(Mandatory)]
    # [ValidateScript({
    #   write-host $shortcut.gettype()
    #     shortcutPath | % { if (!(Test-Path -path $_)) { return $false } }
    #     return $true
    #   })]
    [string[]]$shortcutPath
  )

  Assert-Admin

  $template = [xml] @"
<?xml version="1.0" encoding="utf-8"?>
<LayoutModificationTemplate
    xmlns="http://schemas.microsoft.com/Start/2014/LayoutModification"
    xmlns:defaultlayout="http://schemas.microsoft.com/Start/2014/FullDefaultLayout"
    xmlns:start="http://schemas.microsoft.com/Start/2014/StartLayout"
    xmlns:taskbar="http://schemas.microsoft.com/Start/2014/TaskbarLayout"
    Version="1">
  <CustomTaskbarLayoutCollection>
    <defaultlayout:TaskbarLayout>
      <taskbar:TaskbarPinList>
      </taskbar:TaskbarPinList>
    </defaultlayout:TaskbarLayout>
  </CustomTaskbarLayoutCollection>
</LayoutModificationTemplate>
"@

  $template = $template | % { $_; if ($_ -match "<taskbar:taskbarpinlist>") { $pinnedshortcuts } }

  # the way to selet-xml with namescpace:
  $n = $template.CreateNavigator()
  $n.MoveToFollowing([xml.xpath.XPathNodeType]::Element)
  $ns = $n.GetNamespacesInScope([xml.xmlnamespacescope]::all)
  $pinList = Select-xml -xml $template -xpath "//taskbar:TaskbarPinList" -Namespace $ns

  # $pinList = $template.LayoutModificationTemplate.CustomTaskbarLayoutCollection.TaskbarLayout.TaskbarPinList
  $shortcutPath | % {
    $e = $template.CreateElement("taskbar:DesktopApp", 'http://schemas.microsoft.com/Start/2014/TaskbarLayout')
    $e.SetAttribute("DesktopApplicationLinkPath", $_)
    $pinList.Node.AppendChild($e)
  }
  $layout = "$env:TEMP\layout.xml"
  $template.Save($layout)
  # code $layout

  import-startlayout    -layoutpath $layout -mountpath c:\
  get-process           -name "explorer" | stop-process & explorer.exe
}

# Pin-TaskBar 'M:\Script\Pwsh\Cmdlet\Terminal\Windows Terminal.lnk'