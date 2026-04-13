// showShellContextMenu.c — Show the Windows Explorer right-click context menu
//                          for a given file or folder path.
//
// Usage: showShellContextMenu [--pos X Y | --row ROW ROWS COLS] [--modern] [--background] <path>
//
//   --pos X Y            Absolute screen pixel coordinates for the menu.
//   --row ROW ROWS COLS  Position at terminal row ROW (0-based from viewport
//                        top).  ROWS/COLS = terminal grid dimensions so cell
//                        size can be derived from the foreground window's
//                        client rect.  X is placed at ~12.5% of the terminal
//                        width (yazi default 1:4:3 pane ratio).
//   --modern             Use SHCreateDefaultContextMenu for a richer menu that
//                        includes IExplorerCommand-based handlers (Win11-style
//                        entries).  Without this flag the classic IShellFolder
//                        context menu is shown.
//   --background         Show the folder background context menu (the one you
//                        get when right-clicking empty space in Explorer).
//                        <path> must be a directory.  Creates a real IShellView
//                        so that CDefView populates the full menu (View, Sort
//                        by, Paste, Refresh, New, etc.).
//   (no flag)            Falls back to the current mouse-cursor position.
//
// Compile (MinGW / MSYS2), from this directory:
//   gcc -Os -s -o showShellContextMenu.exe showShellContextMenu.c -lole32 -lshell32 -luuid -luser32 -municode
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

#include "shellViewBgMenu.h"

#define CMD_FIRST 1
#define CMD_LAST  0x7FFF

static const wchar_t *USAGE =
    L"Usage: showShellContextMenu [--pos X Y | --row ROW ROWS COLS] "
    L"[--modern] [--background] <path>\n";

// ── Parsed command-line options ─────────────────────────────────────────────

typedef struct Options {
    BOOL  hasPos;
    int   posX, posY;
    BOOL  useModern;
    BOOL  useBackground;
    wchar_t path[MAX_PATH];
} Options;

static BOOL ParseArgs(int argc, wchar_t *argv[], Options *opts) {
    memset(opts, 0, sizeof(*opts));
    int i = 1;

    if (i < argc && wcscmp(argv[i], L"--pos") == 0) {
        if (i + 3 > argc) return FALSE;
        wchar_t *end = NULL;
        opts->posX = (int)wcstol(argv[i+1], &end, 10);
        if (end == argv[i+1]) return FALSE;
        opts->posY = (int)wcstol(argv[i+2], &end, 10);
        if (end == argv[i+2]) return FALSE;
        opts->hasPos = TRUE;
        i += 3;

    } else if (i < argc && wcscmp(argv[i], L"--row") == 0) {
        if (i + 4 > argc) return FALSE;
        wchar_t *end;
        end = NULL; int rowN    = (int)wcstol(argv[i+1], &end, 10);
        if (end == argv[i+1]) return FALSE;
        end = NULL; int visRows = (int)wcstol(argv[i+2], &end, 10);
        if (end == argv[i+2]) return FALSE;
        end = NULL; int visCols = (int)wcstol(argv[i+3], &end, 10);
        if (end == argv[i+3]) return FALSE;

        if (visRows <= 0) visRows = 24;
        if (visCols <= 0) visCols = 80;

        HWND hwndTerm = GetForegroundWindow();
        RECT cr = {0};
        if (hwndTerm) GetClientRect(hwndTerm, &cr);

        double cellH = (cr.bottom > 0) ? (double)cr.bottom / visRows : 16.0;
        double cellW = (cr.right  > 0) ? (double)cr.right  / visCols :  8.0;

        POINT origin = {0, 0};
        if (hwndTerm) ClientToScreen(hwndTerm, &origin);

        opts->posY   = origin.y + (int)(rowN * cellH + cellH / 2);
        opts->posX   = origin.x + (int)(visCols * cellW / 8.0);
        opts->hasPos = TRUE;
        i += 4;
    }

    for (; i < argc; i++) {
        if (wcscmp(argv[i], L"--modern") == 0)
            opts->useModern = TRUE;
        else if (wcscmp(argv[i], L"--background") == 0)
            opts->useBackground = TRUE;
        else
            break;
    }

    if (i >= argc) return FALSE;

    opts->path[0] = L'\0';
    for (; i < argc; i++) {
        if (opts->path[0]) wcscat(opts->path, L" ");
        wcscat(opts->path, argv[i]);
    }
    return TRUE;
}

static BOOL ResolvePath(wchar_t *out, const wchar_t *raw) {
    if (!GetFullPathNameW(raw, MAX_PATH, out, NULL))
        return FALSE;
    return GetFileAttributesW(out) != INVALID_FILE_ATTRIBUTES;
}

// ── Owner window for menu messages ──────────────────────────────────────────

static IContextMenu2 *g_pCM2 = NULL;
static IContextMenu3 *g_pCM3 = NULL;

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

static HWND CreateOwnerWindow(void) {
    static BOOL registered = FALSE;
    HINSTANCE hInst = GetModuleHandleW(NULL);
    if (!registered) {
        WNDCLASSW wc = {
            .lpfnWndProc  = MenuWndProc,
            .hInstance     = hInst,
            .lpszClassName = L"ShellCtxMenuOwner"
        };
        RegisterClassW(&wc);
        registered = TRUE;
    }
    return CreateWindowExW(0, L"ShellCtxMenuOwner", L"", WS_POPUP,
                           0, 0, 0, 0, NULL, NULL, hInst, NULL);
}

// ── Item context menu ───────────────────────────────────────────────────────

static HRESULT GetItemContextMenu(const wchar_t *path, HWND hwnd,
                                  BOOL useModern, IContextMenu **ppCM) {
    *ppCM = NULL;

    PIDLIST_ABSOLUTE pidl = NULL;
    HRESULT hr = SHParseDisplayName(path, NULL, &pidl, 0, NULL);
    if (FAILED(hr)) return hr;

    IShellFolder *pFolder = NULL;
    PCUITEMID_CHILD pidlChild = NULL;
    hr = SHBindToParent(pidl, &IID_IShellFolder, (void **)&pFolder, &pidlChild);
    if (FAILED(hr)) { CoTaskMemFree(pidl); return hr; }

    if (useModern) {
        DEFCONTEXTMENU dcm = {0};
        dcm.hwnd  = hwnd;
        dcm.psf   = pFolder;
        dcm.cidl  = 1;
        dcm.apidl = &pidlChild;
        hr = SHCreateDefaultContextMenu(&dcm, &IID_IContextMenu, (void **)ppCM);
    } else {
        hr = IShellFolder_GetUIObjectOf(pFolder, hwnd, 1, &pidlChild,
                                         &IID_IContextMenu, NULL, (void **)ppCM);
    }

    CoTaskMemFree(pidl);
    IShellFolder_Release(pFolder);
    return hr;
}

// ── Menu display & invocation ───────────────────────────────────────────────

static POINT ResolveMenuPosition(const Options *opts) {
    POINT pt;
    if (opts->hasPos) {
        pt.x = opts->posX;
        pt.y = opts->posY;
    } else {
        GetCursorPos(&pt);
    }
    return pt;
}

static int ShowAndInvokeMenu(IContextMenu *pCM, HWND hwnd, POINT pt) {
    g_pCM2 = NULL;
    g_pCM3 = NULL;
    IContextMenu_QueryInterface(pCM, &IID_IContextMenu3, (void **)&g_pCM3);
    IContextMenu_QueryInterface(pCM, &IID_IContextMenu2, (void **)&g_pCM2);

    HMENU hMenu = CreatePopupMenu();
    if (!hMenu) return 1;

    HRESULT hr = IContextMenu_QueryContextMenu(pCM, hMenu, 0, CMD_FIRST,
                                                CMD_LAST, CMF_NORMAL | CMF_EXPLORE);
    if (FAILED(hr)) { DestroyMenu(hMenu); return 1; }

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

    DestroyMenu(hMenu);

    if (g_pCM3) IContextMenu3_Release(g_pCM3);
    if (g_pCM2) IContextMenu2_Release(g_pCM2);
    g_pCM3 = NULL;
    g_pCM2 = NULL;

    return 0;
}

// ── Entry point ─────────────────────────────────────────────────────────────

int wmain(int argc, wchar_t *argv[]) {
    FreeConsole();

    Options opts;
    if (argc < 2 || !ParseArgs(argc, argv, &opts)) {
        fwprintf(stderr, USAGE);
        return 1;
    }

    wchar_t fullpath[MAX_PATH];
    if (!ResolvePath(fullpath, opts.path)) {
        fwprintf(stderr, L"Invalid or missing path: %s\n", opts.path);
        return 1;
    }

    HRESULT hr = CoInitializeEx(NULL, COINIT_APARTMENTTHREADED | COINIT_DISABLE_OLE1DDE);
    if (FAILED(hr)) return 1;

    int ret = 1;
    HWND hwnd = CreateOwnerWindow();
    IContextMenu *pCM = NULL;
    IShellView   *pSV = NULL;

    if (opts.useBackground)
        hr = GetBackgroundContextMenu(fullpath, hwnd, &pCM, &pSV);
    else
        hr = GetItemContextMenu(fullpath, hwnd, opts.useModern, &pCM);

    if (SUCCEEDED(hr)) {
        POINT pt = ResolveMenuPosition(&opts);
        ret = ShowAndInvokeMenu(pCM, hwnd, pt);
        IContextMenu_Release(pCM);
    }

    if (pSV) {
        IShellView_DestroyViewWindow(pSV);
        IShellView_Release(pSV);
    }
    if (hwnd) DestroyWindow(hwnd);

    CoUninitialize();
    return ret;
}
