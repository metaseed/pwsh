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

function buildTree($item) {
  if ($item.location.basename -match '^_') { return }

  if (($item.location.Attributes -ne 'Directory') -and ($item.location.Extension -ne '.ps1')) {
    return
  }

  if ($item.location.Attributes -eq "Directory") {
    $children = Get-ChildItem $item.location
    for ($i = 0; $i -lt $children.count; $i++) {
      $child = @{location = $children[$i]; parent = $item; children = @(); }
      $c = buildTree $child
      if ($c) { $item.children += $c }
    }
  }

  return $item
}

function showTree($item) {

  $parent = $item.parent

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
    if ($index -lt ($pp.children.count - 1)) {
      Write-Host -NoNewline "│   "
    }
    else {
      Write-Host -NoNewline "    "
    }
  }

  if ($parent) {
    $i = $parent.children.IndexOf($item)
    $isLast = $i -eq ($parent.children.count - 1)
    if (!$isLast) {
      write-Host "├── " -NoNewline
    }
    else {
      write-Host "└── " -NoNewline
    }
  }

  if ($item.location.Attributes -eq "Directory") {
    write-Host "$($item.location.basename)\"
    $children = $item.children
    for ($i = 0; $i -lt $children.count; $i++) {
      showTree $children[$i]
    }

  }
  else {
    # slow so remove
    # $Synopsis = (Get-Help $item.location.FullName).Synopsis.TrimEnd("`n")
    # if ($Synopsis.startswith("$($item.location.BaseName).ps1")) {
    #   $Synopsis = $Synopsis.Substring("$($item.location.BaseName).ps1".Length).trim()
    # }
    write-Host "$($item.location.basename)" -ForegroundColor Green -NoNewline
    if ($Synopsis) {
      write-Host ":$Synopsis"
    }
    else {
      write-Host ""
    }
  }
}

function Write-AllSubCommands {
  param($commandFolder)
  Write-Host "You could run these commands:"

  $t = buildTree( @{location = (gi $commandFolder); children = @(); } )
  showTree($t)
}