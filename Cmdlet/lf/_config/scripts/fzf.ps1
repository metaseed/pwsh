fzf --preview 'bat --style=numbers --color=always {}'|
%{
	$select = $_
	$dir = $env:pwd.trim('"')
	$path = "`"$([IO.Path]::Join($dir, $select))`"".Replace('\', '/')
	$cmdName = (Test-path $path -PathType Container) ? 'cd':'select'
	$id = $env:id

	$remoteCmd = "send $id $cmdName $path"
	write-host $remoteCmd
	c:\app\lf.exe -remote $remoteCmd
}