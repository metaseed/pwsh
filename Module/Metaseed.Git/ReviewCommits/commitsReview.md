## get the commit from which to review together
```
$commitFrom = Git-ParentCommit
```

## get the all the committed changes
```
$currentBranchName = (git branch --show-current)

# keep the branch head commit in the a ref
$tipRef = "refs/heads/${currentBranchName}-mark"
git update-ref $tipRef head
# move the branch head to the first commit
git reset $commitFrom --soft
```

## after modification

```
git reset $tipRef --soft
# commit changes
git-pushAll "message"
```
## Clean up
```
# delete the ref
git update-ref -d $tipRef

```
