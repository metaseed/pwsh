* view help online: git <cmd> --help
* git <cmd> -h: show help in console
* view status
// Show all refs (branches, tags, etc.).
gitk --all


## accept conflict changes
git checkout --theirs/ours <file>/.

## reset to remote
git fetch origin
git reset --hard origin/master

## checkout a remote branch to review
see: Git-Review

## fix: another git process seems to be running in this repository
rm -f .git/index.lock

## git reset --hard leave untracked changes
https://stackoverflow.com/questions/61212/how-do-i-remove-local-untracked-files-from-the-current-git-working-tree/64966#64966
`git reset --hard` // working directory and index synchronize with history
git clean -fdx
-x: remove ignored files
-f: force, If the Git configuration variable clean.requireForce is set to true, git clean will refuse to run unless given -f, -n or -i.
-d: Remove untracked directories in addition to untracked files

> # to ignore node_modules: not use -x
> git reset --hard; git clean -fd


## remove unstaged local changes
https://stackoverflow.com/questions/52704/how-do-i-discard-unstaged-changes-in-git/12184274#12184274
#Note: empty folder will be there
git clean -df
// For all unstaged files in current working directory
git checkout -- .

## git discard local changes to sync with index
`git checkout .` // working directory sync with index
`git reset` // index sync with history
`git clean -fxd` // x: ignored fils; d: untracked dir; f: force

## amend last commit
`git commit --amend -m "new message"`
`git commit --amend -a --no-edit`

