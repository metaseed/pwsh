// Open the Windows shell "Properties" dialog for a given file or folder,
// and keep the process alive until the dialog is closed.
//
// Compile:
// -Os — optimize for size (smaller exe, negligible speed difference from -O2 for this code)
// -s — strip debug symbols (smaller binary)
// gcc -Os -s -o properties.exe properties.c -lshell32 -luser32 -lole32 -municode
// or: gcc -O2 -o properties.exe properties.c -lshell32 -luser32 -lole32 -municode
// or:
// cl /O2 /W4 properties.c shell32.lib user32.lib ole32.lib
#define WIN32_LEAN_AND_MEAN
#ifndef UNICODE
#define UNICODE
#endif
#ifndef _UNICODE
#define _UNICODE
#endif
#include <windows.h>
#include <shlobj.h>
#include <wchar.h>

// Expected window title of the properties dialog, e.g. "README.md Properties"
static wchar_t g_title[MAX_PATH + 32];
// Handle to the properties dialog once found
static HWND g_dialog = NULL;
// The foreground window before the dialog opens (e.g. the yazi terminal)
static HWND g_prevForeground = NULL;
// Whether to keep the dialog on top without stealing focus
static BOOL g_noFocus = FALSE;

// Callback for SetWinEventHook.
// Listens for EVENT_OBJECT_SHOW to discover the dialog (by class + title),
// and EVENT_OBJECT_DESTROY to detect when the user closes it.
static void CALLBACK OnWinEvent(HWINEVENTHOOK hook, DWORD event, HWND hwnd,
                                LONG idObject, LONG idChild, DWORD thread, DWORD time) {
    // Only care about top-level window events, not child controls
    if (idObject != OBJID_WINDOW || idChild != CHILDID_SELF)
        return;

    if (!g_dialog && event == EVENT_OBJECT_SHOW) {
        // Dialog not yet found — check if this is the properties dialog.
        // Shell property sheets use the standard dialog class "#32770".
        wchar_t cls[64];
        if (GetClassNameW(hwnd, cls, 64) && wcscmp(cls, L"#32770") == 0) {
            wchar_t title[MAX_PATH + 32];
            if (GetWindowTextW(hwnd, title, sizeof(title) / sizeof(title[0])) &&
                wcscmp(title, g_title) == 0) {
                g_dialog = hwnd;
                if (g_noFocus) {
                    // Make the dialog always-on-top so it stays visible, then restore
                    // keyboard focus to the previous window (e.g. yazi terminal).
                    SetWindowPos(hwnd, HWND_TOPMOST, 0, 0, 0, 0,
                                 SWP_NOMOVE | SWP_NOSIZE | SWP_NOACTIVATE);
                    if (g_prevForeground && IsWindow(g_prevForeground))
                        SetForegroundWindow(g_prevForeground);
                }
            }
        }
    } else if (event == EVENT_OBJECT_DESTROY && hwnd == g_dialog) {
        // The properties dialog was closed — exit the message loop
        PostQuitMessage(0);
    }
}

int wmain(int argc, wchar_t *argv[]) {
    if (argc < 2) {
        fwprintf(stderr, L"Usage: properties [--no-focus] <path>\n");
        return 1;
    }

    // Parse optional --no-focus flag: keep dialog on top without stealing keyboard focus
    int pathArg = 1;
    if (argc >= 3 && wcscmp(argv[1], L"--no-focus") == 0) {
        g_noFocus = TRUE;
        pathArg = 2;
    }

    // Resolve to absolute path for SHObjectProperties
    wchar_t fullpath[MAX_PATH];
    if (!GetFullPathNameW(argv[pathArg], MAX_PATH, fullpath, NULL)) {
        fwprintf(stderr, L"Invalid path: %s\n", argv[1]);
        return 1;
    }

    // Build the expected dialog title: "<filename> Properties"
    const wchar_t *leaf = wcsrchr(fullpath, L'\\');
    leaf = leaf ? leaf + 1 : fullpath;
    swprintf(g_title, sizeof(g_title) / sizeof(g_title[0]), L"%s Properties", leaf);

    // Install a WinEvent hook to receive notifications when windows are
    // shown or destroyed, across all processes (WINEVENT_OUTOFCONTEXT).
    // Range EVENT_OBJECT_DESTROY (0x8001) .. EVENT_OBJECT_SHOW (0x8002).
    // The hook callbacks are delivered via the message queue, so we need
    // a message loop below to receive them — no Sleep polling required.
    HWINEVENTHOOK hook = SetWinEventHook(
        EVENT_OBJECT_DESTROY, EVENT_OBJECT_SHOW,
        NULL, OnWinEvent, 0, 0, WINEVENT_OUTOFCONTEXT);

    // Remember the current foreground window so we can restore focus after the dialog appears
    g_prevForeground = GetForegroundWindow();

    // Open the properties dialog (returns immediately; dialog runs on a shell thread).
    // If a dialog for the exact same path is already open, the shell brings it
    // to the foreground instead of creating a new one. so the g_dialog is still set for 2nd invoke.
    SHObjectProperties(NULL, SHOP_FILEPATH, fullpath, NULL);

    // Initial 2s delay to allow the dialog to appear, then 500ms periodic check.
    // SetTimer with NULL hwnd assigns its own ID via the return value.
    //
    // Why a timer fallback is needed:
    // EVENT_OBJECT_DESTROY works reliably for the first instance (which owns the
    // shell thread that created the dialog). But for a second instance opening the
    // same file, the shell reuses the existing dialog — g_dialog gets set via
    // EVENT_OBJECT_SHOW, but EVENT_OBJECT_DESTROY may not be delivered reliably
    // because the owning thread/process can tear down before the async
    // WINEVENT_OUTOFCONTEXT notification reaches other listeners.
    // IsWindow(g_dialog) is a simple, robust fallback that doesn't depend on
    // receiving the destroy event.
    UINT_PTR timerId = SetTimer(NULL, 0, 2000, NULL);
    BOOL firstTick = TRUE;

    MSG msg;
    while (GetMessage(&msg, NULL, 0, 0) > 0) {
        if (msg.message == WM_TIMER && msg.wParam == timerId) {
            if (!g_dialog || !IsWindow(g_dialog))
                break;
            if (firstTick) {
                // Switch to faster polling now that initial delay has passed
                SetTimer(NULL, timerId, 500, NULL);
                firstTick = FALSE;
            }
        }
        TranslateMessage(&msg);
        DispatchMessage(&msg);
    }

    if (hook) UnhookWinEvent(hook);
    return 0;
}
