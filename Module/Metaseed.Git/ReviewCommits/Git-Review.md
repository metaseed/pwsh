# Local PR-Style Code Review

Replicate an Azure DevOps PR diff locally in VS Code. **Working tree** = branch tip (debuggable/runnable).

By default the PR diff appears in **Changes** (local/unstaged). Pass `-ChangesStaged` to
show it in **Staged Changes** instead.

## `-ChangesStaged` switch

| Mode | Reset | PR diff appears in | Review edits go to |
|------|-------|--------------------|--------------------|
| Default (`$false`) | `--mixed` | **Changes** (unstaged) | Same as PR diff until `Git-ReviewDone` isolates them |
| `-ChangesStaged` | `--soft` | **Staged Changes** | **Changes** (unstaged) |

`Git-Review` persists the mode in `git config --local review.changesStaged`.
`Git-ReviewDone -ContinueReview` uses that config by default; pass `-ChangesStaged` (or
`-ChangesStaged:$false`) on `Git-ReviewDone` to override for that re-entry.

## Problem with naive reset

Resetting to the **current branch's creation point on target branch** (e.g. `git reset --soft <commit Sha or master>`), but not to the `merge-base`, flattens the whole branch — including everything brought in by merge commits into the staged index. You cannot tell your feature work from merged upstream changes.

> The fix is **not** “avoid `--soft`” — it is **reset to `merge-base`, not to the target tip**.

## Solution: merge-base + reset

Azure DevOps PR review shows: `diff(merge-base(target_tip, source_tip), source_tip)`.

After saving the feature tip and moving HEAD to the merge-base:

### Default mode (`--mixed`)

`git reset --mixed $mergeBase`

1. **HEAD** (branch pointer) → merge-base
2. **Index** → merge-base
3. **Working tree** → unchanged (feature tip code)

Result: VS Code **Changes** (unstaged) = `diff(merge-base, feature-tip)` = PR diff.
Stage your review edits to separate them into **Staged Changes**.

### `-ChangesStaged` mode (`--soft`)

`git reset --soft $mergeBase`

1. **HEAD** (branch pointer) → merge-base
2. **Index** → stays at feature tip (staged diff = PR diff)
3. **Working tree** → unchanged (feature tip code)

Result: VS Code **Staged Changes** = `diff(merge-base, feature-tip)` = PR diff.
Your edits during review show in **Changes** (unstaged).

### Why not `read-tree`

`git read-tree $mergeBase` loads the merge-base tree into the index, but new feature files
appear as “deleted” in staged + “untracked” in working tree — confusing in VS Code.

i.e. in below diagram, we have added new file1 in commit F, the file1 appears as deleted in staged(compare with branch head), and new file in working tree(compare with index)
### HEAD is not detached

During review you remain **on your branch** (e.g. `feature`). The branch tip was moved back
to merge-base; the real tip is stored in `{branch}-mark` until review ends.

## How it works

```
A--B--C-------D          (master / target branch)
       \       \
        \---E---\---F---Head   (your feature branch)
```

Where **F** merges **D** (master) into your branch.

1. Target = `master` (fetched if it is a local branch)
2. `git merge-base master HEAD` = **D**
3. `git update-ref feature-mark HEAD` — save tip for recovery
4. `git config --local review.target master` — persist target across terminals
5. `git config --local review.changesStaged` — persist mode across terminals
6. `git reset --mixed $mergeBase` (default) or `git reset --soft $mergeBase` (`-ChangesStaged`)

**Result (default `--mixed`):**

- **Changes** (unstaged) = only E + post-merge feature work (F, not C/D/master-only files)
- **Working tree** = Head — runnable/debuggable
- Files identical at merge-base and tip do not appear in the diff
- Stage your review edits to separate them

**Result (`-ChangesStaged`):**

- **Staged Changes** = only E + post-merge feature work
- **Working tree** = Head — runnable/debuggable
- Review edits appear in **Changes** (unstaged)

## Git-native state

| Item | Location |
|------|----------|
| Target branch | `git config --local review.target` → `.git/config` |
| Review mode | `git config --local review.changesStaged` → `.git/config` |
| Feature tip mark | `refs/heads/{currentBranch}-mark` |
| During review | Branch → merge-base; mark → feature tip |

## ReviewDone flow

1. **Conditional** `git reset --mixed {branch}-mark` — branch + index → feature tip unless `HEAD` is already past the mark (retry-safe after a partial sync)
2. Only your **review edits** remain unstaged
3. Optional: prompt for commit message → **sync with origin** (see below) → `git add -A` → `git commit` → `git push`
4. **`-ContinueReview`**: sync with origin, update mark, reset to merge-base again (same mode as original review)
5. **Otherwise**: delete `{branch}-mark`, `git config --unset review.target`, `git config --unset review.changesStaged`

### Sync with origin (`Sync-ReviewBranchWithOrigin`)

Before commit/push (and before `-ContinueReview`), `Git-ReviewDone` integrates `origin/<branch>`:

1. `git fetch origin`
2. `git merge --ff-only origin/<branch>` — succeeds when local is strictly behind remote
3. On failure: **stash** review edits → retry ff-only → **rebase** onto `origin/<branch>` if still diverged
4. **Stash pop** to restore review edits on top of the synced branch

Rebase is used on divergence (same preference as `Git-Push` / `Git-SyncParent`).

### Retry after failure

If sync or commit fails, `{branch}-mark` and `review.target` are preserved. Run `Git-ReviewDone` again:

- When `HEAD` is already **at or ahead of** the tip mark (e.g. you finished a rebase manually), `reset --mixed` is **skipped** so sync progress is not undone.
- When `HEAD` is still at the tip mark, `reset --mixed` runs as on the first attempt.

### Failure recovery

| Failure | State left | What to do |
|---------|------------|------------|
| Rebase conflict | Rebase aborted; review edits in stash | Fix upstream, `git rebase origin/<branch>`, `git stash pop`, run `Git-ReviewDone` again |
| Stash pop conflict | Branch synced; stash entry kept | Resolve working tree conflicts, then `Git-ReviewDone` again or `git stash pop` |
| Fetch / no remote ref | No sync | Fix remote/branch name, run `Git-ReviewDone` again |

### Avoid `git pull` during review

After reset, HEAD is behind the working tree (and the index in `--soft` mode). `git pull`
can fail or behave oddly. The scripts use `git fetch` + sync helper (`merge --ff-only`,
then rebase if needed) instead.

## State diagram

```mermaid
flowchart TD
    A[Git-Review] --> B["Git-Parent or -Target (commit sha or branch name)"]
    B --> C["git merge-base target HEAD"]
    C --> D["update-ref branch-mark + config review.target + review.changesStaged"]
    D --> Mode{"-ChangesStaged?"}
    Mode --> |No| E1["git reset --mixed mergeBase"]
    Mode --> |Yes| E2["git reset --soft mergeBase"]
    E1 --> F["Review State"]
    E2 --> F
    F --> |"Default: Changes = PR diff"| F1["stage review edits to separate"]
    F --> |"-ChangesStaged: Staged = PR diff"| F2["edits appear unstaged"]
    F --> |"Working tree"| H["Feature tip code"]
    F1 --> J[Git-ReviewDone]
    F2 --> J
    J --> K{"HEAD at tip mark?"}
    K --> |yes| K2["reset --mixed branch-mark"]
    K --> |"no, past mark(i.e. after manual rebase)"| K3[skip reset]
    K2 --> L{"Local changes?"}
    K3 --> L
    L --> |Yes| M["sync: fetch, ff-only, stash, rebase, stash pop"]
    M --> M2["commit + push"]
    M2 --> O{"-ContinueReview?"}
    L --> |No| O
    O --> |Yes| P["sync + update mark + reset to mergeBase using same mode"]
    O --> |No| N["Cleanup mark + config"]
    N --> Q["Done"]
    P --> F
```

## Usage

### Start review

```powershell
# default: PR diff in "Changes" (unstaged)
Git-Review

# PR diff in "Staged Changes" instead
Git-Review -ChangesStaged

# specify branch and target
Git-Review -Branch feature/foo -Target master
```

### Finish review

```powershell
# commit review fixes and push (prompts for message if omitted)
Git-ReviewDone -CommitMessage "review fixes"

# push then re-enter review mode on latest tip (same mode as Git-Review)
Git-ReviewDone -ContinueReview

# re-enter with PR diff in Staged Changes even if review started in default mode
Git-ReviewDone -ContinueReview -ChangesStaged
```

## Key commands

| Step | Command | Effect |
|------|---------|--------|
| Find base | `git merge-base $target HEAD` | Common ancestor; excludes merge noise |
| Enter review (default) | `git reset --mixed $mergeBase` | HEAD+index → merge-base; WT at feature tip |
| Enter review (`-ChangesStaged`) | `git reset --soft $mergeBase` | HEAD → merge-base; index+WT at feature tip |
| VS Code (default) | Changes (unstaged) | PR diff + review edits; `Git-ReviewDone` leaves only review edits |
| VS Code (`-ChangesStaged`) | Staged Changes | PR diff; edits appear unstaged |
| Exit review | `git reset --mixed refs/heads/{branch}-mark` (skipped if HEAD past mark) | Restore branch; review edits unstaged |
| Commit fixes | Sync helper + `git add -A` + `git commit` + `git push` | After `Git-ReviewDone` confirms |
| Re-enter | reset to `$mergeBase` (same mode) | With `-ContinueReview` |

## Tests

```powershell
pwsh -File Module/Metaseed.Git/ReviewCommits/_test/Test-Review.ps1
```
