enum ForegroundColorAnsi {
    Black = 30 # 0x1E 0b0001 1110
    Red = 31
    Green = 32
    Yellow = 33
    Blue = 34
    Magenta = 35
    Cyan = 36
    LightGray = 37
    #38: forground for 8 or 256bits

    DarkGray = 90 # 0x5A 0b0101 1010
    LightRed = 91
    LightGreen = 92
    LightYellow = 93
    LightBlue = 94
    LightMagenta = 95
    LightCyan = 96
    White = 97
}

# for 16colors
enum BackgroundColorAnsi {
    Black = 40 # 0x28 0b0010 1000
    Red = 41 # 0x29 0b0010 1001
    Green = 42
    Yellow = 43
    Blue = 44
    Magenta = 45
    Cyan = 46
    LightGray = 47
    #48: backround for 8 or 256bits;folowwing parameters give details; 2: 256bits; 5: 8bits;

    DarkGray = 100 # 0x64 0b0110 1000
    LightRed = 101 # 0x65 0b0110 1001
    LightGreen = 102
    LightYellow = 103
    LightBlue = 104
    LightMagenta = 105
    LightCyan = 106
    White = 107
}
function Get-AnsiColor {
    param($Name, $IsBg = $false)

    if ($IsBg) {
        return [int][BackgroundColorAnsi]$Name
    }
    else {
        return [int][ForegroundColorAnsi]$Name
    }
}