# Test script for Git-Review and Git-ReviewDone
# Covers: new files, modified files, deleted files, merge commits
# Verifies that only feature changes appear and merged master changes are excluded

$ErrorActionPreference = 'Stop'
$testsPassed = 0
$testsFailed = 0

# Empty hooks dir so global post-checkout hooks do not slow tests (core.hooksPath '' is unreliable on Windows)
$script:TestNoHooksDir = Join-Path $env:TEMP 'git-review-no-hooks'
if (-not (Test-Path $script:TestNoHooksDir)) {
    New-Item -ItemType Directory -Path $script:TestNoHooksDir -Force | Out-Null
}

function Set-TestGitHooksOff {
    git config core.hooksPath $script:TestNoHooksDir
}

function Assert-Equal($Expected, $Actual, $Message) {
    if ($Expected -ne $Actual) {
        Write-Host "  FAIL: $Message" -ForegroundColor Red
        Write-Host "    Expected: $Expected" -ForegroundColor Red
        Write-Host "    Actual:   $Actual" -ForegroundColor Red
        $script:testsFailed++
        return $false
    }
    Write-Host "  PASS: $Message" -ForegroundColor Green
    $script:testsPassed++
    return $true
}

function Assert-Contains($List, $Item, $Message) {
    if ($List -notcontains $Item) {
        Write-Host "  FAIL: $Message" -ForegroundColor Red
        Write-Host "    '$Item' not found in: $($List -join ', ')" -ForegroundColor Red
        $script:testsFailed++
        return $false
    }
    Write-Host "  PASS: $Message" -ForegroundColor Green
    $script:testsPassed++
    return $true
}

function Assert-NotContains($List, $Item, $Message) {
    if ($List -contains $Item) {
        Write-Host "  FAIL: $Message" -ForegroundColor Red
        Write-Host "    '$Item' should NOT be in: $($List -join ', ')" -ForegroundColor Red
        $script:testsFailed++
        return $false
    }
    Write-Host "  PASS: $Message" -ForegroundColor Green
    $script:testsPassed++
    return $true
}

function Assert-Match($Pattern, $Text, $Message) {
    if ($Text -notmatch $Pattern) {
        Write-Host "  FAIL: $Message" -ForegroundColor Red
        Write-Host "    Pattern '$Pattern' not found in: $Text" -ForegroundColor Red
        $script:testsFailed++
        return $false
    }
    Write-Host "  PASS: $Message" -ForegroundColor Green
    $script:testsPassed++
    return $true
}

function Setup-TestRepo {
    $testDir = "$env:TEMP\git-review-test-$(Get-Random)"
    New-Item -ItemType Directory -Path $testDir -Force | Out-Null
    Set-Location $testDir

    git init -q
    git config user.email "test@test.com"
    git config user.name "Test"
    Set-TestGitHooksOff

    # A: initial commit with files that feature will later delete
    "initial" | Set-Content file-a.txt
    "will-be-deleted-1" | Set-Content file-del1.txt
    "will-be-deleted-2" | Set-Content file-del2.txt
    "shared content" | Set-Content file-shared.txt
    git add -A; git commit -q -m "A: initial"

    # B: master adds a file
    "master base" | Set-Content file-master-base.txt
    git add -A; git commit -q -m "B: master base"

    # Create feature branch
    git checkout -q -b feature

    # E: feature work - modify, delete, add
    "modified by feature" | Set-Content file-shared.txt
    Remove-Item file-del1.txt
    Remove-Item file-del2.txt
    "new feature file" | Set-Content file-new1.txt
    "another new file" | Set-Content file-new2.txt
    git add -A; git commit -q -m "E: feature changes"

    # Back to master: C and D
    git checkout -q master
    "master change C" | Set-Content file-master-c.txt
    "master modifies shared" | Set-Content file-shared.txt
    git add -A; git commit -q -m "C: master change"
    "master change D" | Set-Content file-master-d.txt
    git add -A; git commit -q -m "D: master change"

    # Merge master into feature (creates merge commit F)
    git checkout -q feature
    git merge master -q -m "F: merge master into feature"

    # G: more feature work after merge
    "post-merge feature work" | Set-Content file-post-merge.txt
    git add -A; git commit -q -m "G: post-merge feature work"

    return $testDir
}

function Cleanup-TestRepo($path) {
    Set-Location $env:TEMP
    Remove-Item $path -Recurse -Force -ErrorAction SilentlyContinue
}

# ============================================================
# Helper to simulate core logic of Git-Review (non-interactive)
function Enter-ReviewMode {
    param(
        [string]$Target = 'master',
        [switch]$ChangesStaged
    )
    $mergeBase = git merge-base $Target HEAD
    $featureTip = git rev-parse HEAD
    git config --local review.target $Target
    git config --local review.changesStaged ($ChangesStaged.IsPresent.ToString().ToLower())
    git update-ref refs/heads/feature-mark $featureTip
    if ($ChangesStaged) {
        git reset --soft $mergeBase 2>$null
    }
    else {
        git reset --mixed $mergeBase 2>$null
    }
    return @{ MergeBase = $mergeBase; FeatureTip = $featureTip; ChangesStaged = $ChangesStaged.IsPresent }
}

# VS Code "Changes" in default (--mixed) mode: tracked unstaged diff + untracked new files
function Get-ReviewLocalChanges {
    $names = [System.Collections.Generic.HashSet[string]]::new([StringComparer]::OrdinalIgnoreCase)
    foreach ($n in (git diff --name-only)) { [void]$names.Add($n) }
    foreach ($n in (git ls-files --others --exclude-standard)) { [void]$names.Add($n) }
    return @($names)
}

# Helper: Git-ReviewDone -ContinueReview re-entry (config or -ChangesStaged override)
function Continue-ReviewMode {
    [CmdletBinding()]
    param(
        [string]$Target = 'master',
        [switch]$ChangesStaged
    )
    if ($PSCmdlet.MyInvocation.BoundParameters.ContainsKey('ChangesStaged')) {
        $useStaged = $ChangesStaged
        git config --local review.changesStaged ($ChangesStaged.ToString().ToLower())
    }
    else {
        $useStaged = (git config review.changesStaged) -eq 'true'
    }
    git update-ref refs/heads/feature-mark HEAD
    $mergeBase = git merge-base $Target HEAD
    if ($useStaged) {
        git reset --soft $mergeBase 2>$null
    }
    else {
        git reset --mixed $mergeBase 2>$null
    }
    return @{ MergeBase = $mergeBase; ChangesStaged = $useStaged }
}

# Helper to simulate core logic of Git-ReviewDone (non-interactive)
function Exit-ReviewMode {
    $tipRef = "refs/heads/feature-mark"
    git reset --mixed $tipRef 2>$null
}

# Helper: skip-reset logic from Git-ReviewDone (retry-safe)
function Reset-ReviewDoneMixed {
    param([string]$TipRef)
    $tipSha = git rev-parse $TipRef
    $headSha = git rev-parse HEAD
    if ($headSha -eq $tipSha) {
        git reset --mixed $TipRef 2>$null
        return 'reset'
    }
    git merge-base --is-ancestor $tipSha $headSha 2>$null
    if ($LASTEXITCODE -eq 0) {
        return 'skipped'
    }
    git reset --mixed $TipRef 2>$null
    return 'forced-reset'
}

# Load private sync helper (not exported from module)
$syncHelper = Join-Path $PSScriptRoot '../../Private/Sync-ReviewBranchWithOrigin.ps1'
. $syncHelper

function Setup-TestRepoWithOrigin {
    $testDir = "$env:TEMP\git-review-sync-$(Get-Random)"
    $bareDir = "$env:TEMP\git-review-sync-bare-$(Get-Random)"
    New-Item -ItemType Directory -Path $testDir -Force | Out-Null
    git init --bare -q $bareDir

    Set-Location $testDir
    git init -q
    git config user.email "test@test.com"
    git config user.name "Test"
    Set-TestGitHooksOff
    git remote add origin $bareDir

    "initial" | Set-Content file-a.txt
    "shared" | Set-Content file-shared.txt
    git add -A; git commit -q -m "A: initial"
    git push -u origin master 2>$null

    git checkout -q -b feature
    "feature v1" | Set-Content file-shared.txt
    "feature file" | Set-Content file-f.txt
    git add -A; git commit -q -m "B: feature"
    git push -u origin feature 2>$null

    return @{ WorkDir = $testDir; BareDir = $bareDir }
}

# ============================================================
Write-Host "`n==== TEST 1: -ChangesStaged mode - PR diff in STAGED, excludes master merge ====" -ForegroundColor Cyan

$testDir = Setup-TestRepo
$info = Enter-ReviewMode -Target master -ChangesStaged

# Check: all PR changes are STAGED (-ChangesStaged / --soft)
$staged = git diff --cached --name-only
Assert-Contains $staged "file-shared.txt" "file-shared.txt (modified) in staged"
Assert-Contains $staged "file-new1.txt" "file-new1.txt (new) in staged"
Assert-Contains $staged "file-new2.txt" "file-new2.txt (new) in staged"
Assert-Contains $staged "file-post-merge.txt" "file-post-merge.txt (new) in staged"
Assert-Contains $staged "file-del1.txt" "file-del1.txt (deleted) in staged"
Assert-Contains $staged "file-del2.txt" "file-del2.txt (deleted) in staged"

# Check: master-only files NOT in staged
Assert-NotContains $staged "file-master-c.txt" "file-master-c.txt (master) NOT in staged"
Assert-NotContains $staged "file-master-d.txt" "file-master-d.txt (master) NOT in staged"
Assert-NotContains $staged "file-master-base.txt" "file-master-base.txt (master) NOT in staged"
Assert-NotContains $staged "file-a.txt" "file-a.txt (unchanged) NOT in staged"

# Check: nothing unstaged
$unstagedCount = (git diff --name-only | Measure-Object -Line).Lines
Assert-Equal 0 $unstagedCount "No unstaged changes in -ChangesStaged mode"

Cleanup-TestRepo $testDir

# ============================================================
Write-Host "`n==== TEST 2: Default mode - PR diff in CHANGES (unstaged), -ChangesStaged off ====" -ForegroundColor Cyan

$testDir = Setup-TestRepo
$info = Enter-ReviewMode -Target master

$staged = git diff --cached --name-only
$local = Get-ReviewLocalChanges

Assert-Equal 0 ($staged | Measure-Object -Line).Lines "No staged PR diff in default (--mixed) mode"
Assert-Contains $local "file-shared.txt" "file-shared.txt (modified) in Changes"
Assert-Contains $local "file-new1.txt" "file-new1.txt (new) in Changes"
Assert-Contains $local "file-new2.txt" "file-new2.txt (new) in Changes"
Assert-Contains $local "file-del1.txt" "file-del1.txt (deleted) in Changes"
Assert-NotContains $local "file-master-c.txt" "file-master-c.txt (master) NOT in Changes"
Assert-Equal 'false' (git config review.changesStaged) "review.changesStaged is false in default mode"

Cleanup-TestRepo $testDir

# ============================================================
Write-Host "`n==== TEST 3: Working tree is at feature tip (debuggable) ====" -ForegroundColor Cyan

$testDir = Setup-TestRepo
$info = Enter-ReviewMode -Target master -ChangesStaged

# Working tree should have feature files
Assert-Equal $true (Test-Path "file-new1.txt") "file-new1.txt exists in working tree"
Assert-Equal $true (Test-Path "file-new2.txt") "file-new2.txt exists in working tree"
Assert-Equal $true (Test-Path "file-post-merge.txt") "file-post-merge.txt exists in working tree"
Assert-Equal $true (Test-Path "file-master-c.txt") "file-master-c.txt exists (from merge)"
Assert-Equal $true (Test-Path "file-master-d.txt") "file-master-d.txt exists (from merge)"
Assert-Equal $false (Test-Path "file-del1.txt") "file-del1.txt NOT in working tree (deleted by feature)"
Assert-Equal $false (Test-Path "file-del2.txt") "file-del2.txt NOT in working tree (deleted by feature)"

Cleanup-TestRepo $testDir

# ============================================================
Write-Host "`n==== TEST 4: ReviewDone (-ChangesStaged) isolates review edits ====" -ForegroundColor Cyan

$testDir = Setup-TestRepo
$info = Enter-ReviewMode -Target master -ChangesStaged

"fixed in review" | Set-Content file-shared.txt
Exit-ReviewMode

$headAfter = git rev-parse HEAD
Assert-Equal $info.FeatureTip $headAfter "HEAD restored to feature tip"
Assert-Equal "feature" (git branch --show-current) "Still on feature branch"

$changedFiles = git diff --name-only
Assert-Equal 1 ($changedFiles | Measure-Object -Line).Lines "Only 1 file changed after ReviewDone"
Assert-Contains $changedFiles "file-shared.txt" "file-shared.txt is the review edit"
Assert-Equal 0 (git diff --cached --name-only | Measure-Object -Line).Lines "No staged changes after ReviewDone"

Cleanup-TestRepo $testDir

# ============================================================
Write-Host "`n==== TEST 4b: ReviewDone (default) - PR diff + edits in Changes, then only review edits ====" -ForegroundColor Cyan

$testDir = Setup-TestRepo
$info = Enter-ReviewMode -Target master

$localBefore = Get-ReviewLocalChanges
Assert-Contains $localBefore "file-new1.txt" "During review: PR diff includes file-new1.txt in Changes"
Assert-Contains $localBefore "file-shared.txt" "During review: PR diff includes file-shared.txt in Changes"

"fixed default mode" | Set-Content file-shared.txt
$localWithEdit = Get-ReviewLocalChanges
Assert-Contains $localWithEdit "file-shared.txt" "During review: review edit still in Changes with PR diff"

Exit-ReviewMode

Assert-Equal $info.FeatureTip (git rev-parse HEAD) "HEAD restored to feature tip (default mode)"
$changedAfter = git diff --name-only
Assert-Equal 1 ($changedAfter | Measure-Object -Line).Lines "After ReviewDone: only review edit in Changes"
Assert-Contains $changedAfter "file-shared.txt" "After ReviewDone: file-shared.txt is the review edit"
Assert-NotContains $changedAfter "file-new1.txt" "After ReviewDone: PR diff file-new1.txt NOT in Changes"
Assert-Equal 0 (git diff --cached --name-only | Measure-Object -Line).Lines "After ReviewDone: staged area matches tip (empty staged diff)"

Cleanup-TestRepo $testDir

# ============================================================
Write-Host "`n==== TEST 5: ReviewDone with no edits leaves clean state ====" -ForegroundColor Cyan

$testDir = Setup-TestRepo
$info = Enter-ReviewMode -Target master -ChangesStaged

# No edits — just exit review
Exit-ReviewMode

$headAfter = git rev-parse HEAD
Assert-Equal $info.FeatureTip $headAfter "HEAD restored to feature tip"

$statusClean = git status --porcelain
Assert-Equal "" "$statusClean" "Working tree is clean after ReviewDone with no edits"

Cleanup-TestRepo $testDir

# ============================================================
Write-Host "`n==== TEST 6: Branch without merge commits (simple case) ====" -ForegroundColor Cyan

$testDir = "$env:TEMP\git-review-test-simple-$(Get-Random)"
New-Item -ItemType Directory -Path $testDir -Force | Out-Null
Set-Location $testDir

git init -q
git config user.email "test@test.com"
git config user.name "Test"
Set-TestGitHooksOff

"initial" | Set-Content file-a.txt
git add -A; git commit -q -m "A: initial"

"master stuff" | Set-Content file-m.txt
git add -A; git commit -q -m "B: master"

git checkout -q -b feature
"feature work" | Set-Content file-f.txt
"modified" | Set-Content file-a.txt
git add -A; git commit -q -m "C: feature"

# No merge — simple divergence
git checkout -q master
"more master" | Set-Content file-m2.txt
git add -A; git commit -q -m "D: more master"
git checkout -q feature

$info = Enter-ReviewMode -Target master

# Default mode: PR diff in Changes (tracked + untracked new files)
$local = Get-ReviewLocalChanges
Assert-Contains $local "file-f.txt" "file-f.txt (new) in Changes"
Assert-Contains $local "file-a.txt" "file-a.txt (modified) in Changes"
Assert-NotContains $local "file-m.txt" "file-m.txt (master) NOT in Changes"
Assert-NotContains $local "file-m2.txt" "file-m2.txt (master) NOT in Changes"

$stagedCount = (git diff --cached --name-only | Measure-Object -Line).Lines
Assert-Equal 0 $stagedCount "No staged PR diff (simple branch, default mode)"

Cleanup-TestRepo $testDir

# ============================================================
Write-Host "`n==== TEST 7: ContinueReview re-enters -ChangesStaged mode (PR diff staged) ====" -ForegroundColor Cyan

$testDir = Setup-TestRepo
$info = Enter-ReviewMode -Target master -ChangesStaged

"fixed" | Set-Content file-shared.txt
Exit-ReviewMode
Continue-ReviewMode -Target master

$staged = git diff --cached --name-only
Assert-Contains $staged "file-shared.txt" "file-shared.txt in staged (PR diff)"
Assert-Contains $staged "file-new1.txt" "file-new1.txt in staged"
Assert-NotContains $staged "file-master-c.txt" "file-master-c.txt still excluded"

$unstaged = git diff --name-only
Assert-Contains $unstaged "file-shared.txt" "Review edit to file-shared.txt visible as unstaged"
Assert-Equal 'true' (git config review.changesStaged) "review.changesStaged still true after ContinueReview"

Cleanup-TestRepo $testDir

# ============================================================
Write-Host "`n==== TEST 7b: ContinueReview re-enters default mode (PR diff unstaged) ====" -ForegroundColor Cyan

$testDir = Setup-TestRepo
Enter-ReviewMode -Target master

"fixed default" | Set-Content file-shared.txt
Exit-ReviewMode
Continue-ReviewMode -Target master

$stagedCount = (git diff --cached --name-only | Measure-Object -Line).Lines
Assert-Equal 0 $stagedCount "No staged PR diff after ContinueReview in default mode"

$local = Get-ReviewLocalChanges
Assert-Contains $local "file-new1.txt" "file-new1.txt in Changes (PR diff restored)"
Assert-Contains $local "file-shared.txt" "Review edit in Changes with PR diff"
Assert-Equal 'false' (git config review.changesStaged) "review.changesStaged still false after ContinueReview"

Cleanup-TestRepo $testDir

# ============================================================
Write-Host "`n==== TEST 7c: Git-ReviewDone -ChangesStaged overrides default config on ContinueReview ====" -ForegroundColor Cyan

$testDir = Setup-TestRepo
Enter-ReviewMode -Target master

"override edit" | Set-Content file-shared.txt
Exit-ReviewMode
Continue-ReviewMode -Target master -ChangesStaged

$staged = git diff --cached --name-only
Assert-Contains $staged "file-new1.txt" "Override: PR diff in staged after -ChangesStaged ContinueReview"
Assert-Equal 'true' (git config review.changesStaged) "Override: review.changesStaged updated to true"

Cleanup-TestRepo $testDir

# ============================================================
Write-Host "`n==== TEST 7d: Git-ReviewDone -ChangesStaged:`$false overrides -ChangesStaged config ====" -ForegroundColor Cyan

$testDir = Setup-TestRepo
Enter-ReviewMode -Target master -ChangesStaged

"staged mode edit" | Set-Content file-shared.txt
Exit-ReviewMode
Continue-ReviewMode -Target master -ChangesStaged:$false

$stagedCount = (git diff --cached --name-only | Measure-Object -Line).Lines
Assert-Equal 0 $stagedCount "Override: no staged PR diff when -ChangesStaged:`$false"
$local = Get-ReviewLocalChanges
Assert-Contains $local "file-new1.txt" "Override: PR diff back in Changes (default mode)"
Assert-Equal 'false' (git config review.changesStaged) "Override: review.changesStaged updated to false"

Cleanup-TestRepo $testDir

# ============================================================
Write-Host "`n==== TEST 8: User edit during review appears as unstaged (default staged mode) ====" -ForegroundColor Cyan

$testDir = Setup-TestRepo
$info = Enter-ReviewMode -Target master -ChangesStaged

# At this point PR diff is staged, unstaged is empty
$unstagedBefore = (git diff --name-only | Measure-Object -Line).Lines
Assert-Equal 0 $unstagedBefore "Unstaged is empty before user edit"

# User makes an edit
"user review fix" | Set-Content file-new1.txt

# The edit should appear as unstaged (diff between staged and working tree)
$unstaged = git diff --name-only
Assert-Contains $unstaged "file-new1.txt" "User edit to file-new1.txt appears as unstaged change"

# Staged should still have the original PR diff
$staged = git diff --cached --name-only
Assert-Contains $staged "file-new1.txt" "file-new1.txt still in staged (original PR diff)"
Assert-Contains $staged "file-shared.txt" "file-shared.txt still in staged"

Cleanup-TestRepo $testDir

# ============================================================
Write-Host "`n==== TEST 9: Sync when remote ahead and review edit blocks ff-only ====" -ForegroundColor Cyan

$setup = Setup-TestRepoWithOrigin
$testDir = $setup.WorkDir
$bareDir = $setup.BareDir

# Advance origin/feature without moving local branch
git fetch origin
$remoteTip = git rev-parse origin/feature
"remote only" | Set-Content file-remote.txt
git add file-remote.txt
git commit -q -m "C: remote only"
$remoteCommit = git rev-parse HEAD
git push origin HEAD:feature 2>$null
git reset --hard $remoteTip 2>$null

# Simulate review edit overlapping a file origin also changed
"review fix on shared" | Set-Content file-shared.txt

$syncOk = Sync-ReviewBranchWithOrigin 'feature'
Assert-Equal $true $syncOk "Sync succeeds when stash + ff-only handles dirty overlap"

$headAfter = git rev-parse HEAD
$originHead = git rev-parse origin/feature
Assert-Equal $originHead $headAfter "HEAD fast-forwarded to origin/feature"

$wtContent = Get-Content file-shared.txt -Raw
Assert-Equal "review fix on shared" $wtContent.TrimEnd() "Review edit restored after stash pop"

Cleanup-TestRepo $testDir
Remove-Item $bareDir -Recurse -Force -ErrorAction SilentlyContinue

# ============================================================
Write-Host "`n==== TEST 10: Sync rebases when branch diverged from origin ====" -ForegroundColor Cyan

$setup = Setup-TestRepoWithOrigin
$testDir = $setup.WorkDir
$bareDir = $setup.BareDir

# Local-only commit (not pushed)
"local only" | Set-Content file-local.txt
git add file-local.txt
git commit -q -m "C: local only"

# Remote-only commit on feature
git fetch origin
$beforeRemote = git rev-parse HEAD
git checkout -q origin/feature
"remote on feature" | Set-Content file-remote2.txt
git add file-remote2.txt
git commit -q -m "D: remote on feature"
git push origin HEAD:feature 2>$null
git checkout -q feature
git reset --hard $beforeRemote 2>$null

"review fix diverged" | Set-Content file-shared.txt

$syncOk = Sync-ReviewBranchWithOrigin 'feature'
Assert-Equal $true $syncOk "Sync succeeds via rebase when branches diverged"

Assert-Equal $true (Test-Path file-local.txt) "Local commit replayed after rebase"
Assert-Equal $true (Test-Path file-remote2.txt) "Remote commit present after rebase"

$wtContent = Get-Content file-shared.txt -Raw
Assert-Equal "review fix diverged" $wtContent.TrimEnd() "Review edit preserved after rebase + stash pop"

Cleanup-TestRepo $testDir
Remove-Item $bareDir -Recurse -Force -ErrorAction SilentlyContinue

# ============================================================
Write-Host "`n==== TEST 11: Retry skips reset when HEAD already past tip mark ====" -ForegroundColor Cyan

$setup = Setup-TestRepoWithOrigin
$testDir = $setup.WorkDir
$bareDir = $setup.BareDir

$tipSha = git rev-parse HEAD
git update-ref refs/heads/feature-mark $tipSha

# Advance HEAD past tip mark (simulate successful sync)
"remote ahead" | Set-Content file-remote3.txt
git add file-remote3.txt
git commit -q -m "E: remote ahead sim"
git push origin feature 2>$null
git fetch origin
git merge --ff-only origin/feature 2>$null

$headBefore = git rev-parse HEAD
"review retry edit" | Set-Content file-shared.txt

$resetResult = Reset-ReviewDoneMixed 'refs/heads/feature-mark'
Assert-Equal 'skipped' $resetResult "reset --mixed skipped when HEAD past tip mark"

$headAfter = git rev-parse HEAD
Assert-Equal $headBefore $headAfter "HEAD unchanged when reset skipped"

$wtContent = Get-Content file-shared.txt -Raw
Assert-Equal "review retry edit" $wtContent.TrimEnd() "Review edit preserved when reset skipped"

Cleanup-TestRepo $testDir
Remove-Item $bareDir -Recurse -Force -ErrorAction SilentlyContinue

# ============================================================
Write-Host "`n==== TEST 12: Rebase conflict aborts sync and leaves review edits in stash ====" -ForegroundColor Cyan

$setup = Setup-TestRepoWithOrigin
$testDir = $setup.WorkDir
$bareDir = $setup.BareDir

# Local commit that will conflict with remote on the same file
"local diverge" | Set-Content file-shared.txt
git add file-shared.txt
git commit -q -m "C: local diverge"

git fetch origin
$beforeRemote = git rev-parse HEAD
git checkout -q origin/feature
"remote diverge" | Set-Content file-shared.txt
git add file-shared.txt
git commit -q -m "D: remote diverge"
git push origin HEAD:feature 2>$null
git checkout -q feature
git reset --hard $beforeRemote 2>$null

"review edit before sync" | Set-Content file-shared.txt

$syncOk = Sync-ReviewBranchWithOrigin 'feature'
Assert-Equal $false $syncOk "Sync returns false when rebase conflicts"

$rebaseActive = (Test-Path .git/rebase-merge) -or (Test-Path .git/rebase-apply)
Assert-Equal $false $rebaseActive "Rebase aborted (no rebase in progress)"

$stashList = git stash list
Assert-Match 'Git-ReviewDone: review edits' $stashList "Review edits preserved in stash after rebase abort"

# Manual recovery: rebase onto origin (prefer upstream on conflict), then stash pop
$env:GIT_EDITOR = 'true'
git -c core.editor=true rebase -X ours origin/feature 2>$null
if ($LASTEXITCODE -ne 0 -and ((Test-Path .git/rebase-merge) -or (Test-Path .git/rebase-apply))) {
    git checkout --ours file-shared.txt 2>$null
    git add file-shared.txt
    git -c core.editor=true rebase --continue 2>$null
}
Assert-Equal 0 $LASTEXITCODE "Manual rebase completes after conflict resolution"

git stash pop 2>$null
if ($LASTEXITCODE -ne 0) {
    git checkout stash -- file-shared.txt 2>$null
    git stash drop 2>$null
}
Assert-Equal 0 $LASTEXITCODE "stash pop restores review edits after manual rebase"

$wtContent = Get-Content file-shared.txt -Raw
Assert-Equal "review edit before sync" $wtContent.TrimEnd() "Review edit restored after rebase + stash pop"

Cleanup-TestRepo $testDir
Remove-Item $bareDir -Recurse -Force -ErrorAction SilentlyContinue

# ============================================================
# Summary
Write-Host "`n============================================================" -ForegroundColor White
Write-Host "RESULTS: $testsPassed passed, $testsFailed failed" -ForegroundColor $(if ($testsFailed -eq 0) { 'Green' } else { 'Red' })
Write-Host "============================================================`n" -ForegroundColor White

if ($testsFailed -gt 0) { exit 1 }
