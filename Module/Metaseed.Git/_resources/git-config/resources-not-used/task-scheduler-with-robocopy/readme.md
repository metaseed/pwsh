- `mklink /H C:\Users\jsong12\.gitconfig M:\Tools\git\.gitconfig` not work, because Hardlink require source and target on the same volume, although Junction link is a kind of soft link of different volume, but it only for directories (not for file).
// https://superuser.com/questions/67870/what-is-the-difference-between-ntfs-hard-links-and-directory-junctions#:~:text=Symbolic%20link%3A%20A%20link%20to,hard%20link%20(file%27s%20name).
1. so we have to using taskScheduler with robocopy (it could monitor file change and then copy):
   robocopy C:\Users\jsong12 M:\Tools\git .gitconfig /MOT:2 /save:"m:\tools\git\gitconfigBackup.rcj"

1. next we would set up a taskScheduler and run when user login
   > note: have to use _system account_ to prevent the console window showing up
