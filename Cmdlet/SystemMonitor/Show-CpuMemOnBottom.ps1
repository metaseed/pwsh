# static void WriteOnBottomLine(string text)
# {
#     int x = Console.CursorLeft;
#     int y = Console.CursorTop;
#     Console.CursorTop = Console.WindowTop + Console.WindowHeight - 1;
#     Console.Write(text);
#     // Restore previous position
#     Console.SetCursorPosition(x, y);
# }
# enum StartPosition {
#     Left
#     Middle
#     Right
# }
Start-ThreadJob -StreamingHost $host  -ScriptBlock {
    ## move cursor and write content, the text could contain ansi text, i.e.
    ## $cpu ="CPU: `e[94m$cpuPer`e[0m"
    ## $mem = "Mem: `e[32m$memPer`e[0m($(($usedMem / 1KB).ToString("#,0.0"))GB)"
    function Write-OnBottom {
        param (
            [string]$text,
            # [StartPosition]$StartPosition = [StartPosition]::Right
            [int]$offset = 0
        )
        $x = [Console]::CursorLeft
        $y = [Console]::CursorTop
        # last line
        [Console]::CursorTop = [Console]::WindowTop + [Console]::WindowHeight - 1
        # replace ansi color chars `e[\d+m, to get the right string length
        $textWithoutAnsi = $text -Replace "`e\[\d+m", ""
        [Console]::CursorLeft = [Console]::WindowWidth - ($offset ? $offset : $textWithoutAnsi.Length)
        # env var is string
        if ($env:__ShowCpuMemOnBtm -eq 'True') {
            #write-host "$([Console]::CursorTop), $([System.Console]::CursorLeft)"
            [Console]::Write($text)
        }

        [Console]::SetCursorPosition($x, $y)
    }

    # experient fail: it can not accept ansi char
    # function Write-OnBottom {
    #     param (
    #         [string]$text,
    #         # [StartPosition]$StartPosition = [StartPosition]::Right
    #         [int]$offset = 0
    #     )
    #     $UI = $Host.UI.RawUI

    #     $Position = $UI.WindowPosition
    #     # last line
    #     $Position.Y += [Console]::WindowHeight - 1
    #     # replace ansi color chars `e[\d+m, to get the right string length
    #     $textWithoutAnsi = $text #-Replace "`e\[\d+m", ""
    #     $Position.X = [Console]::WindowWidth - ($offset ? $offset : $textWithoutAnsi.Length)
    #     # $Rectangle =  [System.Management.Automation.Host.Rectangle]::new($Position.X , $Position.Y, [Console]::WindowWidth, $Top)
    #     # env var is string
    #     if ($env:__ShowCpuMemOnBtm -eq 'True') {
    #         $LineBuffer = $UI.NewBufferCellArray(
    #             @($text),
    #             [Console]::ForegroundColor,
    #             [Console]::BackgroundColor
    #         )
    #         $t = [string]::Join("", ($LineBuffer | .{process{$_.Character}}))
    #         # Write-Host "$($Position.X), $($Position.Y), $t,,,"
    #         $UI.SetBufferContents($Position, $LineBuffer)
    #     }
    # }

    $env:__ShowCpuMemOnBtm = $true

    $totalRam = (Get-CimInstance Win32_PhysicalMemory -Property capacity | Measure-Object -Property capacity -Sum).Sum
    # env var is string
    while ($env:__ShowCpuMemOnBtm -eq 'True') {
        $cpuTime = (Get-Counter '\Processor(_Total)\% Processor Time' -SampleInterval 1).CounterSamples.CookedValue
        $cpuPer = "$($cpuTime.ToString("#,0.0"))".PadLeft(4) + '%'

        # $availMem = (Get-Counter '\Memory\Available MBytes').CounterSamples.CookedValue
        $usedMem = (((Get-Ciminstance Win32_OperatingSystem).TotalVisibleMemorySize * 1kb) - ((Get-Counter -Counter "\Memory\Available Bytes").CounterSamples.CookedValue)) / 1Mb
        $memPer = (104857600 * $usedMem / $totalRam).ToString("#,0.0").PadLeft(3) + '%'

        $cpu ="CPU: `e[94m$cpuPer`e[0m" # "CPU: $cpuPer"
        $mem = "Mem: `e[32m$memPer`e[0m($(($usedMem / 1KB).ToString("#,0.0"))GB)" #  "Mem: $memPer ($(($usedMem / 1KB).ToString("#,0.0"))GB"
        $str = "$cpu | $mem"

        # override with spaces if text length shrinked
        $maxLen = [Math]::Max($lastLen, $str.Length)
        $lastLen = $str.Length
        Write-OnBottom  $str.PadLeft($maxLen)
        sleep -Seconds .5
        # write-host ($env:__ShowCpuMemOnBtm)
    }
} > $null

# $totalRam = (Get-CimInstance Win32_PhysicalMemory | Measure-Object -Property capacity -Sum).Sum
# while ($true) {
#     $date = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
#     $cpuTime = (Get-Counter '\Processor(_Total)\% Processor Time').CounterSamples.CookedValue
#     $availMem = (Get-Counter '\Memory\Available MBytes').CounterSamples.CookedValue
#     $date + ' > CPU: ' + $cpuTime.ToString("#,0.000") + '%, Avail. Mem.: ' + $availMem.ToString("N0") + 'MB (' + (104857600 * $availMem / $totalRam).ToString("#,0.0") + '%)'
#     Start-Sleep -s 2
# }