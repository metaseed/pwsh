## for large git repo to speed up git status check:

### Problem: git_status module slow or missing in large repos

Starship uses `libgit2` (not native git) for `git_status`. In large repos (e.g. 60K+ files),
the status check can exceed the default `command_timeout` (500ms), causing starship to abort
and show no staged/modified indicators.

The debug log will show: `git status execution failed`
(misleading — it includes timeout as a "failure")

### How to debug

```powershell
$env:STARSHIP_LOG = "trace"
# hit Enter, then look for:
# Took XXXms to compute module "git_status"
```

### Fix 1: Increase starship timeout

In `starship.toml`:
```toml
command_timeout = 5000
```

### Fix 2: Speed up git status with filesystem monitor

```bash
git config core.fsmonitor true
git config core.untrackedcache true
```

This uses OS-level file change notifications instead of stat-ing every file.
First run is still slow (daemon needs to warm up). After that it should be much faster.

Check daemon status:
```bash
git fsmonitor--daemon status
git fsmonitor--daemon start
```
