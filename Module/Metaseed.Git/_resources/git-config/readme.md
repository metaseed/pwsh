> edit: global git config:
> git config --global --edit

## new solution:
 Git Config supports includes that allows you to point to a configuration file in another location. That alternate location is then imported and expanded in place as if it was part of .gitconfig file.
https://git-scm.com/docs/git-config#_includes


 So now I just have a single entry in .gitconfig:
```
[include]
   path = c:\\path\\to\\my.config
```
```
git config --global include.path M:\tools\git\.gitconfig
code $home/.gitconfig

// not work git config --global [includeIf "gitdir:**/SLB/**"].path M:\tools\git\.slb.gitconfig
git config --list --show-origin



[include]
	path = M:\\tools\\git\\.gitconfig
[includeIf "gitdir:**/SLB/**"]
 	path=M:\\tool\\git\\.slb.gitconfig
```

> note: the install-git command will do the config after installation.