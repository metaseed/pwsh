<#
 Command
├──  Automation
│   ├──  Toru
│   │   ├── Add-Stand
│   │   ├── auth
│   │   ├── sync-depth
│   │   ├── toru-makeConnection
│   │   └── toru
│   ├──  Web
│   │   └──  npm
│   │       ├── npm-auth
│   │       └── npm-i
│   ├── grant-driller
│   ├── Init-CGOpcua
│   ├── restart-Symphony
...
└── update
#>

function buildTree($item,
  [string[]]$ItemFilters,
  [string[]]$Containerfilters,
  [switch]$KeepEmptyContainer
) {
  Write-Verbose "container: $($item.location)"
  if ($item.location.PSIsContainer) {
    foreach ($filter in $Containerfilters) {
      if ($item.parent -and $item.location.NameString -notmatch $filter) {
        Write-Verbose "container: $($item.location.NameString) -notmatch $filter"
        return
      }
    }
  }
  else {
    foreach ($filter in $ItemFilters) {
      if ($item.location.NameString -notmatch $filter) {
        return
      }
    }
  }
  # # omit folder or file starts with '_'
  # if ($item.location.basename -match '^_') { return }
  # # omit none '.ps1' file
  # if (!($item.location.PSIsContainer) -and ($item.location.Extension -ne '.ps1')) {
  #   return
  # }

  if ($item.location.PSIsContainer) {
    $children = Get-ChildItem $item.location
    for ($i = 0; $i -lt $children.count; $i++) {
      $child = @{location = $children[$i]; parent = $item; children = @(); }
      $c = buildTree $child $ItemFilters $Containerfilters
      # removed items are not added

      if ($c) {
        Write-Verbose "add item $($c.location)"
        $item.children += $c
      }
    }

    if (!$KeepEmptyContainer) {
      # remove $item
      if ($item.children.count -eq 0) {
        Write-Verbose "remove item: $($item.location)"
        $item.isRemoved = $true
        return
      }
    }
  }

  return $item
}

function showTree($item) {
  if ($item.isRemoved) { return }
  $parent = $item.parent

  # build parent-chain
  $parents = @()
  $p = $parent
  while ($p) {
    $parents += $p
    $p = $p.parent
  }

  # draw grand parents' links that cross this line
  # reverse parse the parent-chain: 0, 1, 2, 3
  # (3,2) (2,1) (1,0)
  for ($i = $parents.count - 1; $i -gt 0; $i--) {
    $pp = $parents[$i]
    $p = $parents[$i - 1]

    $index = $pp.children.IndexOf($p)
    if ($index -lt ($pp.children.count - 1)) {
      # not last child, a line to next child
      Write-Host -NoNewline "│   "
    }
    else {
      # last child of the parent, no line to next child.
      Write-Host -NoNewline "    "
    }
  }

  # draw parent child link
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

  # draw item name
  if ($item.location.PSIsContainer) {
    if ($env:WT_SESSION) {
      # with folder icon
      write-Host " $($item.location.basename)"
    }
    else {
      write-Host "$($item.location.basename)\"
    }
    $children = $item.children
    for ($i = 0; $i -lt $children.count; $i++) {
      showTree $children[$i]
    }

  }
  else {
    write-Host "$($item.location.basename)" -ForegroundColor Green -NoNewline
    # slow so remove
    # $Synopsis = (Get-Help $item.location.FullName).Synopsis.TrimEnd("`n")
    # if ($Synopsis.startswith("$($item.location.BaseName).ps1")) {
    #   $Synopsis = $Synopsis.Substring("$($item.location.BaseName).ps1".Length).trim()
    # }
    if ($synopsis) {
      write-Host ":$synopsis"
    }
    else {
      write-Host ""
    }
  }
}

function Write-FileTree {
  [CmdletBinding()]
  param (
    [Parameter()]
    [string]$ParentContainer,
    [string[]]$ItemFilters,
    [string[]]$Containerfilters
  )

  $t = buildTree @{location = (gi $ParentContainer); children = @(); } $ItemFilters $Containerfilters
  showTree($t)
}