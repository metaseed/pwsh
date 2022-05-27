function Beep {
  param (
      $frequency = 1000,
      $duration = 1000
  )
  [Console]::Beep($frequency,$duration)
}