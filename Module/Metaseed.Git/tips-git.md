* view help online: git <cmd> --help
* git <cmd> -h: show help in console
* view status
gitk --all

## accept conflict changes
git checkout --theirs/ours <file>/.

## reset to remote
git fetch origin
git reset --hard origin/master

## checkout a remote branch
https://stackoverflow.com/questions/1783405/how-do-i-check-out-a-remote-git-branch

this works for me
git fetch origin branch-name
git checkout -b branch-name FETCH_HEAD