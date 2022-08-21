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


Start-ThreadJob -ScriptBlock {
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
        # replace ansi color chars
        $textWithoutAnsi = $text -Replace "`e\[\d+m",""
        [Console]::CursorLeft = [Console]::WindowWidth - ($offset ? $offset : $textWithoutAnsi.Length)
        [Console]::Write($text)
        # write-host and out, not work in thread-job
        # Write-Host $text -NoNewline

        [Console]::SetCursorPosition($x, $y)
    }
    $Global:__showCpuMem = $true

    $totalRam = (Get-CimInstance Win32_PhysicalMemory -Property capacity | Measure-Object -Property capacity -Sum).Sum
    while ($Global:__showCpuMem) {
        $usedMem = (((Get-Ciminstance Win32_OperatingSystem).TotalVisibleMemorySize * 1kb) - ((Get-Counter -Counter "\Memory\Available Bytes").CounterSamples.CookedValue)) / 1Mb
        
        $cpuTime = (Get-Counter '\Processor(_Total)\% Processor Time').CounterSamples.CookedValue
        $cpuPer = "$($cpuTime.ToString("#,0.0"))".PadLeft(3) + '%'
        # $availMem = (Get-Counter '\Memory\Available MBytes').CounterSamples.CookedValue
        $memPer = (104857600 * $usedMem / $totalRam).ToString("#,0.0").PadLeft(3) + '%'

        $cpu = "CPU: `e[94m$cpuPer`e[0m"
        $mem = "Mem: `e[32m$memPer`e[0m($(($usedMem / 1KB).ToString("#,0.0"))GB)"
        $str = "$cpu | $mem"
        $maxLen = [Math]::Max($lastLen, $str.Length)
        $lastLen = $str.Length
        Write-OnBottom  $str.PadLeft($maxLen)
        sleep 1
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