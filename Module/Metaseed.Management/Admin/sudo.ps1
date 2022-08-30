
function sudo {
  # add "-NoExit" to the pwsh -ArgmentList and remove -windowStyle Hidden to debug
  Start-Process pwsh -Verb RunAs -WindowStyle Hidden -ArgumentList (@("-Command") + $args)
}

Export-ModuleMember -Function sudo
