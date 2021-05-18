$path = $args[0]

Add-Type -AssemblyName PresentationFramework
[System.Windows.MessageBox]::Show("Hello $path")  