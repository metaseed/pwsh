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
1.
# Notes:
