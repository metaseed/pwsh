# https://www.undocumented-features.com/2020/10/23/announcing-the-end-of-a-script-with-a-powershell-music/

function DingDong () {
    '' #Ctr+G
}

function Beep {
    param (
        $frequency = 1000,
        $duration = 1000
    )
    [Console]::Beep($frequency,$duration)
}
# Function ImperialMarch {
#     [console]::beep(440, 500) 
#     [console]::beep(440, 500)
#     [console]::beep(440, 500) 
#     [console]::beep(349, 350) 
#     [console]::beep(523, 150) 
#     [console]::beep(440, 500) 
#     [console]::beep(349, 350) 
#     [console]::beep(523, 150) 
#     [console]::beep(440, 1000)
#     [console]::beep(659, 500) 
#     [console]::beep(659, 500) 
#     [console]::beep(659, 500) 
#     [console]::beep(698, 350) 
#     [console]::beep(523, 150) 
#     [console]::beep(415, 500) 
#     [console]::beep(349, 350) 
#     [console]::beep(523, 150) 
#     [console]::beep(440, 1000)
# }

Function MissionImpossible {
    [console]::beep(784, 150)
    Start-Sleep -m 300
    [console]::beep(784, 150)
    Start-Sleep -m 300
    [console]::beep(932, 150)
    Start-Sleep -m 150
    [console]::beep(1047, 150)
    Start-Sleep -m 150
    [console]::beep(784, 150)
    Start-Sleep -m 300
    [console]::beep(784, 150)
    Start-Sleep -m 300
    [console]::beep(699, 150)
    Start-Sleep -m 150
    [console]::beep(740, 150)
    Start-Sleep -m 150
    [console]::beep(784, 150)
    Start-Sleep -m 300
    [console]::beep(784, 150)
    Start-Sleep -m 300
    [console]::beep(932, 150)
    Start-Sleep -m 150
    [console]::beep(1047, 150)
    Start-Sleep -m 150
    [console]::beep(784, 150)
    Start-Sleep -m 300
    [console]::beep(784, 150)
    Start-Sleep -m 300
    [console]::beep(699, 150)
    Start-Sleep -m 150
    [console]::beep(740, 150)
    Start-Sleep -m 150
    [console]::beep(932, 150)
    [console]::beep(784, 150)
    [console]::beep(587, 1200)
    Start-Sleep -m 75
    [console]::beep(932, 150)
    [console]::beep(784, 150)
    [console]::beep(554, 1200)
    Start-Sleep -m 75
    [console]::beep(932, 150)
    [console]::beep(784, 150)
    [console]::beep(523, 1200)
    Start-Sleep -m 150
    [console]::beep(466, 150)
    [console]::beep(523, 150)
}

function DoReMi {
    $frequencies = 261.63, 293.66, 329.63, 349.23, 392.00, 440.00, 493.88, 523.25
    foreach($tone in $frequencies){
        [Console]::beep($tone, 180)
    }
}

Function Mario {
    [console]::beep(659, 250) ##E
    [console]::beep(659, 250) ##E
    [console]::beep(659, 300) ##E
    [console]::beep(523, 250) ##C
    [console]::beep(659, 250) ##E
    [console]::beep(784, 300) ##G
    [console]::beep(392, 300) ##g
    [console]::beep(523, 275) ## C
    [console]::beep(392, 275) ##g
    [console]::beep(330, 275) ##e
    [console]::beep(440, 250) ##a
    [console]::beep(494, 250) ##b
    [console]::beep(466, 275) ##a#
    [console]::beep(440, 275) ##a
    [console]::beep(392, 275) ##g
    [console]::beep(659, 250) ##E
    [console]::beep(784, 250) ## G
    [console]::beep(880, 275) ## A
    [console]::beep(698, 275) ## F
    [console]::beep(784, 225) ## G
    [console]::beep(659, 250) ## E
    [console]::beep(523, 250) ## C
    [console]::beep(587, 225) ## D
    [console]::beep(494, 225) ## B
}

# Function Tetris {
#     [Console]::Beep(658, 125)
#     [Console]::Beep(1320, 500)
#     [Console]::Beep(990, 250)
#     [Console]::Beep(1056, 250)
#     [Console]::Beep(1188, 250)
#     [Console]::Beep(1320, 125)
#     [Console]::Beep(1188, 125)
#     [Console]::Beep(1056, 250)
#     [Console]::Beep(990, 250)
#     [Console]::Beep(880, 500)
#     [Console]::Beep(880, 250)
#     [Console]::Beep(1056, 250)
#     [Console]::Beep(1320, 500)
#     [Console]::Beep(1188, 250)
#     [Console]::Beep(1056, 250)
#     [Console]::Beep(990, 750)
#     [Console]::Beep(1056, 250)
#     [Console]::Beep(1188, 500)
#     [Console]::Beep(1320, 500)
#     [Console]::Beep(1056, 500)
#     [Console]::Beep(880, 500)
#     [Console]::Beep(880, 500)
#     sleep -m 250 
#     [Console]::Beep(1188, 500)
#     [Console]::Beep(1408, 250)
#     [Console]::Beep(1760, 500)
#     [Console]::Beep(1584, 250)
#     [Console]::Beep(1408, 250)
#     [Console]::Beep(1320, 750)
#     [Console]::Beep(1056, 250)
#     [Console]::Beep(1320, 500)
#     [Console]::Beep(1188, 250)
#     [Console]::Beep(1056, 250)
#     [Console]::Beep(990, 500)
#     [Console]::Beep(990, 250)
#     [Console]::Beep(1056, 250)
#     [Console]::Beep(1188, 500)
#     [Console]::Beep(1320, 500)
#     [Console]::Beep(1056, 500)
#     [Console]::Beep(880, 500)
#     [Console]::Beep(880, 500)
#     sleep -m 500 
#     [Console]::Beep(1320, 500)
#     [Console]::Beep(990, 250)
#     [Console]::Beep(1056, 250)
#     [Console]::Beep(1188, 250)
#     [Console]::Beep(1320, 125)
#     [Console]::Beep(1188, 125)
#     [Console]::Beep(1056, 250)
#     [Console]::Beep(990, 250)
#     [Console]::Beep(880, 500)
#     [Console]::Beep(880, 250)
#     [Console]::Beep(1056, 250)
#     [Console]::Beep(1320, 500)
#     [Console]::Beep(1188, 250)
#     [Console]::Beep(1056, 250)
#     [Console]::Beep(990, 750)
#     [Console]::Beep(1056, 250)
#     [Console]::Beep(1188, 500)
#     [Console]::Beep(1320, 500)
#     [Console]::Beep(1056, 500)
#     [Console]::Beep(880, 500)
#     [Console]::Beep(880, 500)
#     sleep -m 250 
#     [Console]::Beep(1188, 500)
#     [Console]::Beep(1408, 250)
#     [Console]::Beep(1760, 500)
#     [Console]::Beep(1584, 250)
#     [Console]::Beep(1408, 250)
#     [Console]::Beep(1320, 750)
#     [Console]::Beep(1056, 250)
#     [Console]::Beep(1320, 500)
#     [Console]::Beep(1188, 250)
#     [Console]::Beep(1056, 250)
#     [Console]::Beep(990, 500)
#     [Console]::Beep(990, 250)
#     [Console]::Beep(1056, 250)
#     [Console]::Beep(1188, 500)
#     [Console]::Beep(1320, 500)
#     [Console]::Beep(1056, 500)
#     [Console]::Beep(880, 500)
#     [Console]::Beep(880, 500)
#     sleep -m 500 
#     [Console]::Beep(660, 1000)
#     [Console]::Beep(528, 1000)
#     [Console]::Beep(594, 1000)
#     [Console]::Beep(495, 1000)
#     [Console]::Beep(528, 1000)
#     [Console]::Beep(440, 1000)
#     [Console]::Beep(419, 1000)
#     [Console]::Beep(495, 1000)
#     [Console]::Beep(660, 1000)
#     [Console]::Beep(528, 1000)
#     [Console]::Beep(594, 1000)
#     [Console]::Beep(495, 1000)
#     [Console]::Beep(528, 500)
#     [Console]::Beep(660, 500)
#     [Console]::Beep(880, 1000)
#     [Console]::Beep(838, 2000)
#     [Console]::Beep(660, 1000)
#     [Console]::Beep(528, 1000)
#     [Console]::Beep(594, 1000)
#     [Console]::Beep(495, 1000)
#     [Console]::Beep(528, 1000)
#     [Console]::Beep(440, 1000)
#     [Console]::Beep(419, 1000)
#     [Console]::Beep(495, 1000)
#     [Console]::Beep(660, 1000)
#     [Console]::Beep(528, 1000)
#     [Console]::Beep(594, 1000)
#     [Console]::Beep(495, 1000)
#     [Console]::Beep(528, 500)
#     [Console]::Beep(660, 500)
#     [Console]::Beep(880, 1000)
#     [Console]::Beep(838, 2000)
# }

