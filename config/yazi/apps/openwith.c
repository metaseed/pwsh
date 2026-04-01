// NOTE: we can directly use the C:\WINDOWS\system32\OpenWith.exe, note it can not handle relative path and path should use \ instead of / as separator, same as rundll32.exe shell32.dll,OpenAs_RunDLL "M:\Script\Pwsh\config\yazi\pwsh\openwith.c"
// Open the Windows "Open With" dialog for a given file,
// and keep the process alive until the dialog is closed.
//
// Compile:
// gcc -Os -s -o openwith.exe openwith.c -lshell32 -luser32 -lole32 -municode
// or:
// cl /O2 /W4 openwith.c shell32.lib user32.lib ole32.lib
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

// Handle to the "Open With" dialog once found
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
    (void)hook; (void)thread; (void)time;
    if (idObject != OBJID_WINDOW || idChild != CHILDID_SELF)
        return;

    if (!g_dialog && event == EVENT_OBJECT_SHOW) {
        // The "Open With" dialog uses class "#32770" and its title varies by
        // locale but typically contains "Open with" (EN) or equivalent.
        // We match any #32770 dialog whose title starts with "Open with" or
        // contains it, but a simpler approach: the dialog that appears shortly
        // after our SHOpenWithDialog call with class #32770.
        wchar_t cls[64];
        if (GetClassNameW(hwnd, cls, 64) && wcscmp(cls, L"#32770") == 0) {
            wchar_t title[256];
            if (GetWindowTextW(hwnd, title, 256)) {
                // Modern Windows "Open with" dialog title is typically
                // "Open with" or localized equivalent. We also accept the
                // newer immersive dialog which may not be #32770.
                // For robustness, accept any #32770 dialog that appears.
            }
            g_dialog = hwnd;
            if (g_noFocus) {
                SetWindowPos(hwnd, HWND_TOPMOST, 0, 0, 0, 0,
                             SWP_NOMOVE | SWP_NOSIZE | SWP_NOACTIVATE);
                if (g_prevForeground && IsWindow(g_prevForeground))
                    SetForegroundWindow(g_prevForeground);
            }
        }
    } else if (event == EVENT_OBJECT_DESTROY && hwnd == g_dialog) {
        PostQuitMessage(0);
    }
}

// Import SHOpenWithDialog from shell32.dll at runtime to avoid link issues
// with older MinGW toolchains that may lack it in the import library.
typedef HRESULT (WINAPI *PFN_SHOpenWithDialog)(HWND hwndParent, const OPENASINFO *poainfo);

int wmain(int argc, wchar_t *argv[]) {
    if (argc < 2) {
        fwprintf(stderr, L"Usage: openwith [--no-focus] <path>\n");
        return 1;
    }

    int pathArg = 1;
    if (argc >= 3 && wcscmp(argv[1], L"--no-focus") == 0) {
        g_noFocus = TRUE;
        pathArg = 2;
    }

    wchar_t fullpath[MAX_PATH];
    if (!GetFullPathNameW(argv[pathArg], MAX_PATH, fullpath, NULL)) {
        fwprintf(stderr, L"Invalid path: %s\n", argv[pathArg]);
        return 1;
    }

    // Verify the file exists
    DWORD attr = GetFileAttributesW(fullpath);
    if (attr == INVALID_FILE_ATTRIBUTES) {
        fwprintf(stderr, L"File not found: %s\n", fullpath);
        return 1;
    }

    // Load SHOpenWithDialog dynamically
    HMODULE hShell32 = GetModuleHandleW(L"shell32.dll");
    if (!hShell32) hShell32 = LoadLibraryW(L"shell32.dll");
    PFN_SHOpenWithDialog pfnSHOpenWithDialog =
        (PFN_SHOpenWithDialog)GetProcAddress(hShell32, "SHOpenWithDialog");
    if (!pfnSHOpenWithDialog) {
        fwprintf(stderr, L"SHOpenWithDialog not available on this system.\n");
        return 1;
    }

    CoInitializeEx(NULL, COINIT_APARTMENTTHREADED | COINIT_DISABLE_OLE1DDE);

    OPENASINFO oai = {0};
    oai.pcszFile = fullpath;
    oai.pcszClass = NULL;
    // OAIF_ALLOW_REGISTRATION: let the user set the default app
    // OAIF_EXEC: launch the chosen app immediately
    oai.oaifInFlags = OAIF_ALLOW_REGISTRATION | OAIF_EXEC;

    // SHOpenWithDialog is modal — it blocks until the user picks an app or cancels.
    // So we don't need the event-hook / message-loop pattern for waiting.
    // However, if --no-focus is requested, we set up the hook to reposition
    // the dialog before it steals focus.
    HWINEVENTHOOK hook = NULL;
    if (g_noFocus) {
        hook = SetWinEventHook(
            EVENT_OBJECT_DESTROY, EVENT_OBJECT_SHOW,
            NULL, OnWinEvent, 0, 0, WINEVENT_OUTOFCONTEXT);
        g_prevForeground = GetForegroundWindow();
    }

    HRESULT hr = pfnSHOpenWithDialog(NULL, &oai);

    if (hook) UnhookWinEvent(hook);

    if (FAILED(hr) && hr != HRESULT_FROM_WIN32(ERROR_CANCELLED)) {
        fwprintf(stderr, L"SHOpenWithDialog failed: 0x%08lX\n", hr);
        return 1;
    }

    return 0;
}
