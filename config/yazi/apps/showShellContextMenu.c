// showShellContextMenu.c — Show the Windows Explorer right-click context menu
//                          for a given file or folder path.
//
// Usage: showShellContextMenu [--pos X Y | --row ROW ROWS COLS] <path>
//
//   --pos X Y            Absolute screen pixel coordinates for the menu.
//   --row ROW ROWS COLS  Position at terminal row ROW (0-based from viewport
//                        top).  ROWS/COLS = terminal grid dimensions so cell
//                        size can be derived from the foreground window's
//                        client rect.  X is placed at ~12.5% of the terminal
//                        width (yazi default 1:4:3 pane ratio).
//   (no flag)            Falls back to the current mouse-cursor position.
//
// Compile (MinGW / MSYS2):
//   gcc -Os -s -o showShellContextMenu.exe showShellContextMenu.c \
//       -lole32 -lshell32 -luuid -luser32 -municode
// Compile (MSVC):
//   cl /O2 /W4 showShellContextMenu.c \
//       ole32.lib shell32.lib uuid.lib user32.lib

#define WIN32_LEAN_AND_MEAN
#define CINTERFACE
#define COBJMACROS
#ifndef UNICODE
#define UNICODE
#endif
#ifndef _UNICODE
#define _UNICODE
#endif

#include <windows.h>
#include <shobjidl.h>
#include <shlobj.h>
#include <wchar.h>
#include <stdio.h>

static IContextMenu2 *g_pCM2 = NULL;
static IContextMenu3 *g_pCM3 = NULL;

// Forward owner-draw / submenu messages to IContextMenu2/3 so that icons,
// dynamic submenus, and custom-drawn items render correctly.
static LRESULT CALLBACK MenuWndProc(HWND hwnd, UINT msg, WPARAM wp, LPARAM lp) {
    if (g_pCM3) {
        LRESULT lr = 0;
        if (SUCCEEDED(IContextMenu3_HandleMenuMsg2(g_pCM3, msg, wp, lp, &lr)))
            return lr;
    } else if (g_pCM2) {
        switch (msg) {
        case WM_INITMENUPOPUP:
        case WM_DRAWITEM:
        case WM_MEASUREITEM:
            if (SUCCEEDED(IContextMenu2_HandleMenuMsg(g_pCM2, msg, wp, lp)))
                return 0;
        }
    }
    return DefWindowProcW(hwnd, msg, wp, lp);
}

#define CMD_FIRST 1
#define CMD_LAST  0x7FFF

int wmain(int argc, wchar_t *argv[]) {
    FreeConsole();

    if (argc < 2) {
        fwprintf(stderr, L"Usage: showShellContextMenu [--pos X Y | --row ROW ROWS COLS] <path>\n");
        return 1;
    }

    BOOL hasPos = FALSE;
    int posX = 0, posY = 0;
    int pathArgStart = 1;

    if (argc >= 4 && wcscmp(argv[1], L"--pos") == 0) {
        wchar_t *end = NULL;
        posX = (int)wcstol(argv[2], &end, 10);
        if (end == argv[2]) { fwprintf(stderr, L"Invalid X: %s\n", argv[2]); return 1; }
        posY = (int)wcstol(argv[3], &end, 10);
        if (end == argv[3]) { fwprintf(stderr, L"Invalid Y: %s\n", argv[3]); return 1; }
        hasPos = TRUE;
        pathArgStart = 4;

    } else if (argc >= 5 && wcscmp(argv[1], L"--row") == 0) {
        wchar_t *end;
        end = NULL; int rowN    = (int)wcstol(argv[2], &end, 10);
        if (end == argv[2]) { fwprintf(stderr, L"Invalid ROW: %s\n",  argv[2]); return 1; }
        end = NULL; int visRows = (int)wcstol(argv[3], &end, 10);
        if (end == argv[3]) { fwprintf(stderr, L"Invalid ROWS: %s\n", argv[3]); return 1; }
        end = NULL; int visCols = (int)wcstol(argv[4], &end, 10);
        if (end == argv[4]) { fwprintf(stderr, L"Invalid COLS: %s\n", argv[4]); return 1; }

        if (visRows <= 0) visRows = 24;
        if (visCols <= 0) visCols = 80;

        HWND hwndTerm = GetForegroundWindow();
        RECT cr = {0};
        if (hwndTerm) GetClientRect(hwndTerm, &cr);

        double cellH = (cr.bottom > 0) ? (double)cr.bottom / visRows : 16.0;
        double cellW = (cr.right  > 0) ? (double)cr.right  / visCols :  8.0;

        POINT origin = {0, 0};
        if (hwndTerm) ClientToScreen(hwndTerm, &origin);

        posY = origin.y + (int)(rowN * cellH + cellH / 2);
        posX = origin.x + (int)(visCols * cellW / 8.0);
        hasPos = TRUE;
        pathArgStart = 5;
    }

    if (pathArgStart >= argc) {
        fwprintf(stderr, L"Usage: showShellContextMenu [--pos X Y | --row ROW ROWS COLS] <path>\n");
        return 1;
    }

    wchar_t rawpath[MAX_PATH] = {0};
    for (int i = pathArgStart; i < argc; i++) {
        if (i > pathArgStart) wcscat(rawpath, L" ");
        wcscat(rawpath, argv[i]);
    }

    wchar_t fullpath[MAX_PATH];
    if (!GetFullPathNameW(rawpath, MAX_PATH, fullpath, NULL)) {
        fwprintf(stderr, L"Invalid path: %s\n", rawpath);
        return 1;
    }
    if (GetFileAttributesW(fullpath) == INVALID_FILE_ATTRIBUTES) {
        fwprintf(stderr, L"Path not found: %s\n", fullpath);
        return 1;
    }

    HRESULT hr = CoInitializeEx(NULL, COINIT_APARTMENTTHREADED | COINIT_DISABLE_OLE1DDE);
    if (FAILED(hr)) return 1;

    int ret = 1;

    PIDLIST_ABSOLUTE pidl = NULL;
    hr = SHParseDisplayName(fullpath, NULL, &pidl, 0, NULL);
    if (FAILED(hr)) goto done;

    IShellFolder *pFolder = NULL;
    PCUITEMID_CHILD pidlChild = NULL;
    hr = SHBindToParent(pidl, &IID_IShellFolder, (void **)&pFolder, &pidlChild);
    if (FAILED(hr)) { CoTaskMemFree(pidl); goto done; }

    IContextMenu *pCM = NULL;
    hr = IShellFolder_GetUIObjectOf(pFolder, NULL, 1, &pidlChild,
                                     &IID_IContextMenu, NULL, (void **)&pCM);
    CoTaskMemFree(pidl);
    IShellFolder_Release(pFolder);
    if (FAILED(hr)) goto done;

    IContextMenu_QueryInterface(pCM, &IID_IContextMenu3, (void **)&g_pCM3);
    IContextMenu_QueryInterface(pCM, &IID_IContextMenu2, (void **)&g_pCM2);

    WNDCLASSW wc = {
        .lpfnWndProc   = MenuWndProc,
        .hInstance      = GetModuleHandleW(NULL),
        .lpszClassName  = L"ShellCtxMenuOwner"
    };
    RegisterClassW(&wc);
    HWND hwnd = CreateWindowExW(0, wc.lpszClassName, L"", WS_POPUP,
                                 0, 0, 0, 0, NULL, NULL, wc.hInstance, NULL);

    HMENU hMenu = CreatePopupMenu();
    if (!hMenu) goto cleanup_cm;

    hr = IContextMenu_QueryContextMenu(pCM, hMenu, 0, CMD_FIRST, CMD_LAST,
                                        CMF_NORMAL | CMF_EXPLORE);
    if (FAILED(hr)) { DestroyMenu(hMenu); goto cleanup_cm; }

    POINT pt;
    if (hasPos) {
        pt.x = posX;
        pt.y = posY;
    } else {
        GetCursorPos(&pt);
    }

    // Open menu upward when near the bottom of the monitor.
    HMONITOR hMon = MonitorFromPoint(pt, MONITOR_DEFAULTTONEAREST);
    MONITORINFO mi = { .cbSize = sizeof(mi) };
    GetMonitorInfoW(hMon, &mi);
    UINT align = (pt.y > (mi.rcWork.top + mi.rcWork.bottom) / 2)
                 ? TPM_BOTTOMALIGN : TPM_TOPALIGN;

    SetForegroundWindow(hwnd);
    UINT cmd = TrackPopupMenuEx(hMenu, TPM_RETURNCMD | TPM_RIGHTBUTTON | align,
                                 pt.x, pt.y, hwnd, NULL);
    PostMessageW(hwnd, WM_NULL, 0, 0);

    if (cmd >= CMD_FIRST) {
        CMINVOKECOMMANDINFO ici = {
            .cbSize = sizeof(ici),
            .hwnd   = hwnd,
            .lpVerb = MAKEINTRESOURCEA(cmd - CMD_FIRST),
            .nShow  = SW_SHOWNORMAL
        };
        IContextMenu_InvokeCommand(pCM, &ici);
    }

    ret = 0;
    DestroyMenu(hMenu);

cleanup_cm:
    if (g_pCM3) IContextMenu3_Release(g_pCM3);
    if (g_pCM2) IContextMenu2_Release(g_pCM2);
    IContextMenu_Release(pCM);
    if (hwnd) DestroyWindow(hwnd);

done:
    CoUninitialize();
    return ret;
}
