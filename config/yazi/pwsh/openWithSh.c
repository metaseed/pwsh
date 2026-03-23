// ===========================================================================
// openWithSh.c — Lightweight wrapper that launches the system OpenWith.exe
//                and automatically sends a Tab key to the dialog so the
//                app-selection list is focused immediately.
//
// Why not call OpenWith.exe directly?
//   - OpenWith.exe does not accept relative paths or forward-slash separators.
//   - When the dialog opens, keyboard focus lands on the title / description
//     area, not on the app list — the user must Tab into it manually.
//   This wrapper fixes both issues.
//
// How it works:
//   1. Resolve the file argument to an absolute path (GetFullPathNameW).
//   2. Spawn C:\WINDOWS\system32\OpenWith.exe with CreateProcessW.
//   3. Wait for the dialog window to appear by enumerating top-level windows
//      and matching the spawned process ID (locale-independent — no title
//      string matching needed).
//   4. Bring the dialog to the foreground, then synthesise a Tab key press
//      via SendInput so the app list receives focus.
//   5. Exit (the dialog continues to run independently).
//
// Compile (MinGW / MSYS2):
//   gcc -Os -s -o openwithsh.exe openWithSh.c -municode
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

int wmain(int argc, wchar_t *argv[]) {
    if (argc < 2) return 1;

    // --- Step 1: Resolve the path to absolute form --------------------------
    wchar_t fullpath[MAX_PATH];
    if (!GetFullPathNameW(argv[1], MAX_PATH, fullpath, NULL))
        return 1;

    // --- Step 2: Build and launch the OpenWith.exe command ------------------
    wchar_t cmd[MAX_PATH * 2];
    swprintf(cmd, sizeof(cmd) / sizeof(cmd[0]),
             L"C:\\WINDOWS\\system32\\OpenWith.exe \"%s\"", fullpath);

    STARTUPINFOW si = { .cb = sizeof(si) };
    PROCESS_INFORMATION pi;
    if (!CreateProcessW(NULL, cmd, NULL, NULL, FALSE, 0, NULL, NULL, &si, &pi))
        return 1;

    // --- Step 3: Find the dialog window by process ID -----------------------
    // First let the child process initialise its message queue.
    WaitForInputIdle(pi.hProcess, 5000);

    HWND hwnd = NULL;
    for (int i = 0; i < 50; i++) {          // poll up to ~5 seconds
        Sleep(100);
        hwnd = NULL;
        // Enumerate all top-level windows looking for one owned by our child.
        HWND w = NULL;
        while ((w = FindWindowExW(NULL, w, NULL, NULL)) != NULL) {
            DWORD wndPid = 0;
            GetWindowThreadProcessId(w, &wndPid);
            if (wndPid == pi.dwProcessId && IsWindowVisible(w)) {
                hwnd = w;
                break;
            }
        }
        if (hwnd) break;
    }

    // --- Step 4: Send Tab to move focus onto the app list -------------------
    if (hwnd) {
        SetForegroundWindow(hwnd);
        Sleep(200);                          // let the dialog finish rendering

        // Synthesise a Tab key-down + key-up via SendInput.
        INPUT inp[2] = {0};
        inp[0].type = INPUT_KEYBOARD;
        inp[0].ki.wVk = VK_TAB;             // key down
        inp[1].type = INPUT_KEYBOARD;
        inp[1].ki.wVk = VK_TAB;
        inp[1].ki.dwFlags = KEYEVENTF_KEYUP; // key up
        SendInput(2, inp, sizeof(INPUT));
    }

    // --- Step 5: Clean up handles and exit ----------------------------------
    CloseHandle(pi.hProcess);
    CloseHandle(pi.hThread);
    return 0;
}
