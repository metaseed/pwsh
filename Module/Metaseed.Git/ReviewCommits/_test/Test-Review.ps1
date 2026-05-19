# Test script for Git-Review and Git-ReviewDone
# Covers: new files, modified files, deleted files, merge commits
# Verifies that only feature changes appear and merged master changes are excluded

$ErrorActionPreference = 'Stop'
$testsPassed = 0
$testsFailed = 0

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

function Setup-TestRepo {
    $testDir = "$env:TEMP\git-review-test-$(Get-Random)"
    New-Item -ItemType Directory -Path $testDir -Force | Out-Null
    Set-Location $testDir

    git init -q
    git config user.email "test@test.com"
    git config user.name "Test"

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
function Enter-ReviewMode($CommitFrom) {
    $mergeBase = git merge-base $CommitFrom HEAD
    $featureTip = git rev-parse HEAD
    git config --local review.commitFrom $CommitFrom
    git update-ref refs/heads/feature-mark $featureTip
    git reset --soft $mergeBase 2>$null
    return @{ MergeBase = $mergeBase; FeatureTip = $featureTip }
}

# Helper to simulate core logic of Git-ReviewDone (non-interactive)
function Exit-ReviewMode {
    $tipRef = "refs/heads/feature-mark"
    git reset --mixed $tipRef 2>$null
}

# ============================================================
Write-Host "`n==== TEST 1: Default mode - PR diff in STAGED, excludes master merge ====" -ForegroundColor Cyan

$testDir = Setup-TestRepo
$info = Enter-ReviewMode "master"

# Check: all PR changes are STAGED
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
Assert-Equal 0 $unstagedCount "No unstaged changes in default mode"

Cleanup-TestRepo $testDir

# ============================================================
Write-Host "`n==== TEST 3: Working tree is at feature tip (debuggable) ====" -ForegroundColor Cyan

$testDir = Setup-TestRepo
$info = Enter-ReviewMode "master"

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
Write-Host "`n==== TEST 4: ReviewDone restores branch and shows only review edits ====" -ForegroundColor Cyan

$testDir = Setup-TestRepo
$info = Enter-ReviewMode "master"

# Simulate user making a review edit
"fixed in review" | Set-Content file-shared.txt

# Exit review
Exit-ReviewMode

# Check: HEAD is back at feature tip
$headAfter = git rev-parse HEAD
Assert-Equal $info.FeatureTip $headAfter "HEAD restored to feature tip"

# Check: branch is feature
$branch = git branch --show-current
Assert-Equal "feature" $branch "Still on feature branch"

# Check: only the review edit remains
$changedFiles = git diff --name-only
Assert-Equal 1 ($changedFiles | Measure-Object -Line).Lines "Only 1 file changed after ReviewDone"
Assert-Contains $changedFiles "file-shared.txt" "file-shared.txt is the review edit"

# Check: no staged changes
$stagedCount = (git diff --cached --name-only | Measure-Object -Line).Lines
Assert-Equal 0 $stagedCount "No staged changes after ReviewDone"

Cleanup-TestRepo $testDir

# ============================================================
Write-Host "`n==== TEST 5: ReviewDone with no edits leaves clean state ====" -ForegroundColor Cyan

$testDir = Setup-TestRepo
$info = Enter-ReviewMode "master"

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

$info = Enter-ReviewMode "master"

# Default mode: changes should be staged
$staged = git diff --cached --name-only
Assert-Contains $staged "file-f.txt" "file-f.txt (new) in staged"
Assert-Contains $staged "file-a.txt" "file-a.txt (modified) in staged"
Assert-NotContains $staged "file-m.txt" "file-m.txt (master) NOT in staged"
Assert-NotContains $staged "file-m2.txt" "file-m2.txt (master) NOT in staged"

$unstagedCount = (git diff --name-only | Measure-Object -Line).Lines
Assert-Equal 0 $unstagedCount "No unstaged changes (simple branch, default mode)"

Cleanup-TestRepo $testDir

# ============================================================
Write-Host "`n==== TEST 7: ContinueReview re-enters review mode (staged) ====" -ForegroundColor Cyan

$testDir = Setup-TestRepo
$info = Enter-ReviewMode "master"

# Make a review edit
"fixed" | Set-Content file-shared.txt

# Exit review (simulate ReviewDone without push)
Exit-ReviewMode

# Simulate ContinueReview: re-enter review
$commitFrom = "master"
$mergeBase = git merge-base $commitFrom HEAD
git update-ref refs/heads/feature-mark HEAD
git reset --soft $mergeBase 2>$null

# PR diff should be staged
$staged = git diff --cached --name-only
Assert-Contains $staged "file-shared.txt" "file-shared.txt in staged (PR diff)"
Assert-Contains $staged "file-new1.txt" "file-new1.txt in staged"
Assert-NotContains $staged "file-master-c.txt" "file-master-c.txt still excluded"

# Review edit appears as unstaged (working tree differs from index for that file)
$unstaged = git diff --name-only
Assert-Contains $unstaged "file-shared.txt" "Review edit to file-shared.txt visible as unstaged"

Cleanup-TestRepo $testDir

# ============================================================
Write-Host "`n==== TEST 8: User edit during review appears as unstaged (default staged mode) ====" -ForegroundColor Cyan

$testDir = Setup-TestRepo
$info = Enter-ReviewMode "master"

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
# Summary
Write-Host "`n============================================================" -ForegroundColor White
Write-Host "RESULTS: $testsPassed passed, $testsFailed failed" -ForegroundColor $(if ($testsFailed -eq 0) { 'Green' } else { 'Red' })
Write-Host "============================================================`n" -ForegroundColor White

if ($testsFailed -gt 0) { exit 1 }
