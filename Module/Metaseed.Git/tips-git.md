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
see: Git-Review

## fix: another git process seems to be running in this repository
rm -f .git/index.lock
## git reset --hard leave untracked changes
https://stackoverflow.com/questions/61212/how-do-i-remove-local-untracked-files-from-the-current-git-working-tree/64966#64966
git reset --hard
git clean -fdx
-x: remove ignored files
-f: force, If the Git configuration variable clean.requireForce is set to true, git clean will refuse to run unless given -f, -n or -i.
-d: Remove untracked directories in addition to untracked files