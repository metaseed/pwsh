<#
note: to show the char: [char]0xE392
#>
function Get-UnicodeOfChar {
	param (
		[string]
		$Char = "👍"
	)
	$utf32bytes = [System.Text.Encoding]::UTF32.GetBytes( $Char )
	$codePoint = [System.BitConverter]::ToUint32( $utf32bytes )
	return "0x{0:X}" -f $codePoint
}
