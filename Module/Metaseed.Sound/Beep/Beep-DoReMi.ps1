function Beep-DoReMi {
  $frequencies = 261.63, 293.66, 329.63, 349.23, 392.00, 440.00, 493.88, 523.25 # 1 -> 1
  foreach($tone in $frequencies){
      [Console]::beep($tone, 480) # tone, duration(if duration is 180, can not play out all sound, in the end)
  }
}

# Beep-DoReMi