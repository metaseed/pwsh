# Based on:
#   https://github.com/ahrm/dotfiles/blob/main/lf-windows/lf_scripts/lf_preview.py

function Get-MimeType {
	param(
		[string]$FilePath
	)
	$leaf = Split-Path $FilePath -Leaf
	if ($leaf -like '*.tar*') { return 'zip/tar' }

	$extension = [System.IO.Path]::GetExtension($FilePath).ToLower()
	switch ($extension) {
		'.txt' { return 'text/plain' }
		'.jpg' { return 'image/jpeg' }
		'.jpeg' { return 'image/jpeg' }
		'.png' { return 'image/png' }
		'.gif' { return 'image/gif' }
		'.pdf' { return 'application/pdf' }
		'.zip' { return 'zip/zip' }
		'.7z' { return 'zip/7z' }
		'.rar' { return 'zip/rar' }
		Default { return 'none' }
	}
}

function Show-Text {
	param(
		[string]$FilePath
	)
	# $content = Get-Content -Path $FilePath
	# Write-Output $content
	bat --color=always --theme=base16 $FilePath
}

function Write-Divider {
	Write-Output ('-' * 24)
}

function Show-Image {
	param(
		[string]$FilePath,
		[int]$PreviewerWidth,
		[int]$PreviewerHeight
	)
	Add-Type -AssemblyName System.Drawing
	$resolvedPath = (Resolve-Path -Path $FilePath).Path
	$img = [Drawing.Image]::FromFile($resolvedPath)

	Write-Output "Image Size: $($img.Width)x$($img.Height)"
	try {
		chafa $resolvedPath --view-size=$PreviewerWidth"x"$PreviewerHeight -c full --color-space rgb
	}
	catch {
		Write-Output "chara must be installed to preview the image."
	}
}

function Format-FileSize {
	param(
		[int64]$size_in_bytes
	)
	if ($size_in_bytes -lt 1KB) {
		return "${size_in_bytes} B"
	}
	elseif ($size_in_bytes -lt 1MB) {
		return "{0:F2} KB" -f ($size_in_bytes / 1KB)
	}
	elseif ($size_in_bytes -lt 1GB) {
		return "{0:F2} MB" -f ($size_in_bytes / 1MB)
	}
	else {
		return "{0:F2} GB" -f ($size_in_bytes / 1GB)
	}
}

function Format-Text {
	param(
		[string]$text,
		[int]$width = 80
	)

	$words = $text -split "\s+"
	$col = 0
	foreach ( $word in $words ) {
		$col += $word.Length + 1
		if ( $col -gt $width ) {
			Write-Host ""
			$col = $word.Length + 1
		}
		Write-Host -NoNewline "$word "
	}
	Write-Host ""
}

# (1) current file name, (2) width, (3) height, (4) horizontal position, and (5) vertical position of preview pane
# SIGPIPE signal is sent when enough lines are read. If the previewer returns a non-zero exit code,
# then the preview cache for the given file is disabled. This means that if the file is selected in the future,
# the previewer is called once again. Preview filtering is disabled and files are displayed as they are when the value of this option is left empty.

$file_path = $args[1]
$previewer_width = $args[2]
$previewer_height = $args[3]
$mimeType = Get-MimeType $file_path
try {
	$fileInfo = Get-Item -LiteralPath $file_path
	$size = $fileInfo.Length
	# Write-Output $(Format-Text "File Name: $($fileInfo.Name)" $previewer_width)
	Write-Output "File Size: $(Format-FileSize $size)"
	Write-Output "Modify Time: $($fileInfo.LastWriteTime)"

	if ($mimeType -eq 'none') {
		if ($size -lt 100KB) {
			#Write-Divider
			Show-Text $file_path
		}
	}
	elseif ($mimeType -eq 'text/plain') {
		#Write-Divider
		Show-Text $file_path

	}
	elseif ($mimeType -match 'image/') {
		Write-Divider
		Show-Image $file_path $previewer_width $previewer_height
	}
	elseif($mimeType -match 'zip/tar'){
		Write-Divider
		# bsdtar is in 'C:\msys64\usr\bin\bsdtar.exe'
		bsdtar tf $file_path
	}
	elseif ($mimeType -match 'zip/') {
		Write-Divider
		$content = 7z l $file_path | Select-Object -Skip 13
		#    bat $content --color=always
		write-output $content
	}

}
catch {
	Write-Output $_.Exception.Message
}