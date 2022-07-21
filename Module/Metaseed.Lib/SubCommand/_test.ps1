<#
bootstrap/
├── css/
│   ├── bootstrap.css
│   ├── bootstrap.min.css
│   ├── bootstrap-theme.css
│   └── bootstrap-theme.min.css
├── js/
│   ├── bootstrap.js
│   └── bootstrap.min.js
└── fonts/
    ├── glyphicons-halflings-regular.eot
    ├── glyphicons-halflings-regular.svg
    ├── glyphicons-halflings-regular.ttf
    └── glyphicons-halflings-regular.woff
#>
function showTree($item, $isLast) {

  if (!( # item to omit
  (($item.location.Attributes -ne 'Directory') -and ($item.location.Extension -ne '.ps1')) || ($item.location.basename -match '^_')
    )) {
    return
  }

  $parent = $item.parent
  $parent.children += $item

  $parents = @()
  $p = $parent
  while ($p) {
    $parents += $p
    $p = $p.parent
  }

  for ($i = $parents.count - 1; $i -gt 0; $i--) {
    $pp = $parents[$i]
    $p = $parents[$i - 1]

    $index = $pp.children.IndexOf($p)
    if ($index -lt ($pp.count - 1)) {
      Write-Host -NoNewline "│   "
    }
    else {
      Write-Host -NoNewline "    "
    }
  }

  if ($parent) {
    if (!$isLast) {
      write-Host "├── " -NoNewline
    }
    else {
      write-Host "└── " -NoNewline
    }
  }

  if ($item.location.Attributes -eq "Directory") {
    write-Host "$($item.location.basename)\"
    $children = Get-ChildItem $item.location
    for ($i = 0; $i -lt $children.count; $i++) {
      $child = @{location = $children[$i]; parent = $item; children = @() }
      $last = $i -eq $children.count - 1
      showTree($child, $last)
    }

  }
  else {
    write-Host "$($item.location.basename)"
  }
}
$commandFolder = "M:\Work\SLB\Presto\drilldev\command"
showTree( @{location = (gi $commandFolder); children = @(); } )
