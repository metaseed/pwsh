# Goal
* Create a pwsh function to find out the parent branch of current branch
> parent branch: the branch on which we've created the current branch from with the command: git checkout -b <branch-name> or git switch -c <branch-name>

# Solutions
## Git nature function
> search in AI: why git do not provide a get-parent-branch function?

## Analysis branch graph to find out the parent
> ref: Git-Parent

## Explicitly save info in config of repo
### Design
1. create a post-checkout hook template: in ./resources\.git-templates\hooks\post-checkout
1. in .gitconfig(M:\Script\Pwsh\Module\Metaseed.Git\_resources\git-config\.gitconfig) add init section for hook template for new repo
1. post-checkout hook template will identify new branch creation action when checkout of branches during new branch creation, and then store info of parent branch name in config file of the repo.
1. git-getParent.ps1 and git-SetParent function
1. in posh-git.ps1 we show the parent branch name on command line info
# Notes:
* git do not have hoke for branch creation