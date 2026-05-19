# Local PR-Style Code Review

Replicate an Azure DevOps PR diff locally in VS Code: **Staged Changes** = your feature
changes only (merge commits excluded), **working tree** = branch tip (debuggable/runnable).

## Problem with naive `git reset --soft`

Resetting to the **target branch tip** (e.g. `git reset --soft origin/master`) without
`merge-base` flattens the whole branch — including everything brought in by merge commits —
into the staged index. You cannot tell your feature work from merged upstream changes.

The same flattening happens if you use `git reset --soft` on the wrong commit. The fix is
**not** “avoid `--soft`” — it is **reset to `merge-base`, not to the target tip**.

## Solution: merge-base + `reset --soft`

Azure DevOps PR review shows: `diff(merge-base(target_tip, source_tip), source_tip)`.

After saving the feature tip and moving HEAD to the merge-base:

`git reset --soft $mergeBase`

1. **HEAD** (branch pointer) → merge-base
2. **Index** → stays at feature tip (staged diff = PR diff)
3. **Working tree** → unchanged (feature tip code)

Result: VS Code **Staged Changes** = `diff(merge-base, feature-tip)` = PR diff.  
Your edits during review show in **Changes** (unstaged).

### Why not `read-tree`

`git read-tree $mergeBase` loads the merge-base tree into the index, but new feature files
appear as “deleted” in staged + “untracked” in working tree — confusing in VS Code.

### HEAD is not detached

During review you remain **on your branch** (e.g. `feature`). The branch tip was moved back
to merge-base; the real tip is stored in `{branch}-mark` until review ends.

## How it works

```
A--B---C---D          (master / target branch)
      \         \
       \---E----\---F---Head   (your feature branch)
```

Where **F** merges **D** (master) into your branch.

1. Target = `master` (fetched if it is a local branch)
2. `git merge-base master HEAD` = **D**
3. `git update-ref feature-mark HEAD` — save tip for recovery
4. `git config --local review.commitFrom master` — persist target across terminals
5. `git reset --soft $mergeBase`

**Result:**

- **Staged Changes** = only E + post-merge feature work (not C/D/master-only files)
- **Working tree** = Head — runnable/debuggable
- Files identical at merge-base and tip do not appear in the diff

## Git-native state

| Item | Location |
|------|----------|
| Target branch | `git config --local review.commitFrom` → `.git/config` |
| Feature tip mark | `refs/heads/{currentBranch}-mark` |
| During review | Branch → merge-base; mark → feature tip |

## ReviewDone flow

1. `git reset --mixed {branch}-mark` — branch + index → feature tip; working tree kept
2. Only your **review edits** remain unstaged
3. Optional: prompt for commit message → `git add -A` → `git commit` → `git push`
4. **`-ContinueReview`**: `git fetch` + `merge --ff-only`, update mark, `reset --soft` to merge-base again
5. **Otherwise**: delete `{branch}-mark`, `git config --unset review.commitFrom`

### Avoid `git pull` during review

After `reset --soft`, HEAD is behind the index. `git pull` can fail or behave oddly. The
scripts use `git fetch` + `git merge --ff-only origin/<branch>` instead.

## State diagram

```mermaid
flowchart TD
    A[Git-Review] --> B["Git-Parent or -CommitFrom"]
    B --> C["git merge-base target HEAD"]
    C --> D["update-ref branch-mark + config review.commitFrom"]
    D --> E["git reset --soft mergeBase"]
    E --> F["Review State"]
    F --> |"Staged Changes"| G["PR diff only"]
    F --> |"Working tree"| H["Feature tip code"]
    F --> |"User edits"| I["Unstaged Changes"]
    I --> J[Git-ReviewDone]
    J --> K["git reset --mixed branch-mark"]
    K --> L{"Local changes?"}
    L --> |Yes| M["commit + push"]
    L --> |No| N["Cleanup mark + config"]
    M --> O{"-ContinueReview?"}
    N --> O
    O --> |Yes| P["fetch + ff-merge + reset --soft"]
    O --> |No| Q["Done"]
```

## Usage

### Start review

```powershell
Git-Review
# or:
Git-Review -Branch feature/foo -CommitFrom master
```

### Finish review

```powershell
# commit review fixes and push (prompts for message if omitted)
Git-ReviewDone -CommitMessage "review fixes"

# push then re-enter review mode on latest tip
Git-ReviewDone -ContinueReview
```

## Key commands

| Step | Command | Effect |
|------|---------|--------|
| Find base | `git merge-base $target HEAD` | Common ancestor; excludes merge noise |
| Enter review | `git reset --soft $mergeBase` | HEAD → merge-base; index/WT at feature tip |
| VS Code | Staged Changes | PR diff (feature-only) |
| VS Code | Changes | Your in-review edits (unstaged) |
| Exit review | `git reset --mixed refs/heads/{branch}-mark` | Restore branch; review edits unstaged |
| Commit fixes | `git add -A` + `git commit` + `git push` | After `Git-ReviewDone` confirms |
| Re-enter | `git reset --soft $mergeBase` | With `-ContinueReview` |

## Tests

```powershell
pwsh -File Module/Metaseed.Git/ReviewCommits/_test/Test-Review.ps1
```
