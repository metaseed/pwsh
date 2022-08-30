* view help online: git <cmd> --help
* git <cmd> -h: show help in console
* view status
gitk --all

## accept conflict changes
git checkout --theirs/ours <file>/.

## reset to remote
git fetch origin
git reset --hard origin/master