function get-shellFolders{
	$folders = gci "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\explorer\FolderDescriptions"
	$folders = $folders.Name.replace('HKEY_LOCAL_MACHINE', 'HKLM:')
	$folders = $folders |
	% {
	  $folder = Get-ItemPropertyValue $_ -Name Name;
		$guid = Split-Path $_ -Leaf
	  return @{Name = $folder; Order = 0; Guid = $guid.trim('{','}')}
	}
	return $folders
}

function get-shellFolder($wordToComplete) {
	$folders = get-shellFolders |
	? {
	  Test-WordToComplete $_ $wordToComplete
	} |
	sort -Property Order |
	% {
	  if ($_.Name.contains(' ')) {
		return "'$($_.Name)'"
	  }
	  else {
		return $_.Name
	  }
	}

	return $folders
  }

