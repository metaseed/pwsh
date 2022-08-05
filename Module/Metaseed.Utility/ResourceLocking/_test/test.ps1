"test resurce locking" > $env:temp/locking.txt
[System.IO.File]::Open("$env:temp/locking.txt", Append) # in another pwsh [System.IO.FileMode]::

rm $env:temp/locking.txt
Find-LockingProcess $env:temp/locking.txt
Stop-LockingProcess $env:temp/locking.txt
rm $env:temp/locking.txt