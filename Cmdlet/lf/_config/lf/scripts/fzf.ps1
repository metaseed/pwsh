# note the `invoke-fzf` can find directory but `fzf` can only used to find files,
# but fzf is faster (--preview)
invoke-fzf -preview 'bat --style=numbers --color=always {}'|
%{
	$select = $_
	#$dir = $env:pwd.trim('"')
	#$path = "$([IO.Path]::Join($dir, $select))".Replace('\', '/')
	# when use invoke-fzf, it will return the full path, not partial after the pwd
	$path = "$select".Replace('\', '/')
	$cmdName = (Test-path $path -PathType Container) ? 'cd':'select'
	$id = $env:id

	$remoteCmd = "send $id $cmdName `"$path`""
	# write-host $remoteCmd
	c:\app\lf.exe -remote $remoteCmd
}