// ===========================================================================
// openWithSh.c — Open the "Open With" dialog and auto-focus the app list.
//
// use shift-tab to focus on the 'just once' button
// Problem:
//   When you launch C:\WINDOWS\system32\OpenWith.exe <file>, the dialog
//   opens but keyboard focus lands on a search/description area instead of
//   the app list.  The user must Tab into the list manually.
//
// Why this wrapper exists:
//   1. Resolve the file argument to an absolute path with backslashes
//      (OpenWith.exe rejects relative paths and forward slashes).
//   2. Launch OpenWith.exe as a child process.
//   3. Wait for the dialog to appear and its content to render.
//   4. Bring the dialog to the foreground and send a Tab key press to
//      move focus onto the app list.
//
// Technical notes (Windows 10/11):
//   - The "Open With" dialog is a WinUI / XAML Islands window.
//   - EnumWindows / EnumThreadWindows CANNOT find it.  Only FindWindowW
//     with class name "Open With" works reliably.
//   - We must wait for the window to be visible with a non-zero client
//     area before interacting with it, because the XAML content loads
//     asynchronously after the HWND is created.
//
// Compile (MinGW / MSYS2):
//   gcc -Os -s -municode -o openwithsh.exe openWithSh.c
// ===========================================================================

#define WIN32_LEAN_AND_MEAN

#ifndef UNICODE
#define UNICODE
#endif
#ifndef _UNICODE
#define _UNICODE
#endif

#include <windows.h>
#include <wchar.h>


// ========================== Window Snapshot ==================================
//
// Before launching OpenWith.exe we record every existing "Open With" window
// handle.  After launch, we look for a NEW handle not in this set, so we
// always target the dialog we just spawned (not a leftover from a previous
// invocation).

#define MAX_SNAP 64
static HWND g_snap[MAX_SNAP];
static int  g_snapCount;

static BOOL CALLBACK SnapOpenWith(HWND w, LPARAM lp) {
    (void)lp;
    wchar_t cls[32];
    if (GetClassNameW(w, cls, 32) && wcscmp(cls, L"Open With") == 0)
        if (g_snapCount < MAX_SNAP)
            g_snap[g_snapCount++] = w;
    return TRUE;
}

static int snap_contains(HWND w) {
    for (int i = 0; i < g_snapCount; i++)
        if (g_snap[i] == w) return 1;
    return 0;
}


// ============================= Main =========================================

int wmain(int argc, wchar_t *argv[]) {
    if (argc < 2) return 1;

    // -- Step 1: Build an absolute path from the arguments --------------------
    //
    // If the caller didn't quote the path, spaces cause it to be split
    // across multiple argv entries.  Rejoin them here.
    wchar_t rawpath[MAX_PATH] = {0};
    for (int i = 1; i < argc; i++) {
        if (i > 1) wcscat(rawpath, L" ");
        wcscat(rawpath, argv[i]);
    }

    // GetFullPathNameW also normalises '/' to '\'.
    wchar_t fullpath[MAX_PATH];
    if (!GetFullPathNameW(rawpath, MAX_PATH, fullpath, NULL))
        return 1;

    // -- Step 2: Snapshot + Launch --------------------------------------------

    EnumWindows(SnapOpenWith, 0);

    wchar_t cmd[MAX_PATH * 2];
    swprintf(cmd, sizeof(cmd) / sizeof(cmd[0]),
             L"C:\\WINDOWS\\system32\\OpenWith.exe \"%s\"", fullpath);

    STARTUPINFOW si = { .cb = sizeof(si) };
    PROCESS_INFORMATION pi;
    if (!CreateProcessW(NULL, cmd, NULL, NULL, FALSE, 0, NULL, NULL, &si, &pi))
        return 1;

    WaitForInputIdle(pi.hProcess, 5000);

    // -- Step 3: Find the newly created dialog --------------------------------
    //
    // FindWindowW is the only reliable way to locate this WinUI window.
    // EnumWindows cannot see it.  We poll for up to ~5 seconds.
    HWND hwnd = NULL;
    for (int i = 0; i < 250; i++) {
        Sleep(20);
        HWND fw = FindWindowW(L"Open With", NULL);
        if (fw && !snap_contains(fw)) {
            hwnd = fw;
            break;
        }
    }
    if (!hwnd) goto done;

    // -- Step 4: Wait for the window to be fully rendered ---------------------
    //
    // The HWND can exist before the XAML content has loaded.  Wait until
    // the window is visible and has a non-zero client area.
    for (int i = 0; i < 100; i++) {
        if (IsWindowVisible(hwnd)) {
            RECT rc;
            GetClientRect(hwnd, &rc);
            if (rc.right > 0 && rc.bottom > 0) break;
        }
        Sleep(20);
    }

    // -- Step 5: Foreground + Tab to move focus onto the app list -------------

    SetForegroundWindow(hwnd);
    Sleep(100);

    INPUT inp[2] = {0};
    inp[0].type      = INPUT_KEYBOARD;
    inp[0].ki.wVk    = VK_TAB;
    inp[1].type      = INPUT_KEYBOARD;
    inp[1].ki.wVk    = VK_TAB;
    inp[1].ki.dwFlags = KEYEVENTF_KEYUP;
    SendInput(2, inp, sizeof(INPUT));

done:
    CloseHandle(pi.hProcess);
    CloseHandle(pi.hThread);
    return 0;
}
