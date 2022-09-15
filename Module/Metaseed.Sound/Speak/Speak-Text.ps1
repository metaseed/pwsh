<#
.SYNOPSIS
	Speaks text in configured language, English by default
.DESCRIPTION
	This PowerShell scripts speaks the given text with an text-to-speech (TTS) voice.
.EXAMPLE
	speak Hello
	speak 你好 -language Chinese
	# blocking-speak
	speak 你好 -language Chinese -sync
.NOTES
https://github.com/fleschutz/PowerShell/
#>

function Speak-Text {
	[cmdletBinding()]
	[alias('speak')]
	param([string]$text = "", [string]$language = 'English', [switch]$sync)

	try {
		if ($text -eq "") { $text = "Enter the text to speak" }

		$TTSVoice = New-Object -ComObject SAPI.SPVoice
		foreach ($Voice in $TTSVoice.GetVoices()) {
			if ($Voice.GetDescription() -like "*- $language*") {
				$TTSVoice.Voice = $Voice
				$usedVoice = $Voice
				# flag: https://docs.microsoft.com/en-us/previous-versions/windows/desktop/ms720892(v=vs.85)
				if ($sync) {
					$flag = 0
				}
				else {
					$flag = 1
				}
				#Speak method: https://docs.microsoft.com/en-us/previous-versions/windows/desktop/ms723609(v=vs.85)
				[void]$TTSVoice.Speak($text, $flag)
				break
			}
		}

		if (!$usedVoice) {
			throw "No text-to-speech voice for '$language' found - please install one."
		}
	}
	catch {
		"⚠️ Error in line $($_.InvocationInfo.ScriptLineNumber): $($Error[0])"
	}
}
