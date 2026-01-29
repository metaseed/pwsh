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

## change branch by navigate reflog history
`git chechout -` same as `git checkout @{-1}` : switch to last used branch

Key point:
- takes you to whatever you checked out last, whether that's:
A branch name → you'll be on that branch
A commit hash → you'll be in detached HEAD state
A tag → detached HEAD at that tag's commit

> @{-n}: previous n checkout.

> Head@{-n}: is also take count commits, it count every head move.

> ^ and ~
     A---B---C (main)
         \   \
          D---E (feature)
If HEAD is at C (a merge commit):

HEAD^1 or HEAD~1 → B (first parent, the branch you were on)
HEAD^2 → E (second parent, the branch you merged in)
HEAD~2 → A (following first parent lineage)