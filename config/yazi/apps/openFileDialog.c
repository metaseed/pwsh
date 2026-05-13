// Show a Windows File Open dialog that allows multiple file/folder selection,
// and output the selected paths to stdout (one per line).
//
// Parameters:
//   [--title "Dialog Title"]  — optional dialog title (default: "Open")
//   [--filter "Name|*.ext"]   — optional filter (default: "All Files|*.*")
//   [--folder]                — pick folders instead of files
//   <path>                    — file or directory; dialog opens its parent
//                               and pre-selects it (root paths open as-is)
//
// Examples:
//   openFileDialog.exe C:\Users\me\photo.jpg
//       — opens C:\Users\me\ with photo.jpg pre-selected
//   openFileDialog.exe C:\Users\me\photoFolder
//       — opens C:\Users\me\ with photoFolder pre-selected
//   openFileDialog.exe --folder C:\Users\me\Documents
//       — opens C:\Users\me\ with Documents pre-selected (folder picker)
//   openFileDialog.exe C:\Users\me\
//       — opens C:\Users\me\ with nothing pre-selected (root/trailing slash)
//
// Compile (MinGW / MSYS2):
//   gcc -Os -s -o openFileDialog.exe openFileDialog.c \
//       -lole32 -lshell32 -lshlwapi -luuid -municode
// Compile (MSVC):
//   cl /O2 /W4 openFileDialog.c ole32.lib shell32.lib shlwapi.lib uuid.lib

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
#include <shlwapi.h>
#include <shlguid.h>
#include <servprov.h>
#include <wchar.h>
#include <stdio.h>
#include <stdlib.h>

// ── Helpers ─────────────────────────────────────────────────────────────────

static void PrintItemPath(IShellItem *pItem) {
    LPWSTR path = NULL;
    if (SUCCEEDED(IShellItem_GetDisplayName(pItem, SIGDN_FILESYSPATH, &path))) {
        wprintf(L"%s\n", path);
        CoTaskMemFree(path);
    }
}

// ── Pre-selection ───────────────────────────────────────────────────────────
//
// IFileDialog has no built-in API to highlight an item in its list view.
// We obtain the underlying IFolderView through:
//
//   IFileDialog → IServiceProvider → IShellBrowser → IShellView → IFolderView
//
// then walk the items and call IFolderView_SelectItem on the match.
//
// Timing: OnFolderChange fires during the dialog's own initialisation, and
// the dialog resets the selection after the callback returns.  A one-shot
// WM_TIMER (low-priority, dispatched after all pending messages) defers our
// selection until the dialog is idle, so the highlight sticks.

static void SelectItemByName(IFileDialog *pfd, const wchar_t *targetName) {
    IServiceProvider *pSP = NULL;
    HRESULT hr = IFileDialog_QueryInterface(pfd, &IID_IServiceProvider, (void **)&pSP);
    if (FAILED(hr)) return;

    IShellBrowser *pSB = NULL;
    hr = IServiceProvider_QueryService(pSP, &SID_STopLevelBrowser,
                                       &IID_IShellBrowser, (void **)&pSB);
    IServiceProvider_Release(pSP);
    if (FAILED(hr)) return;

    IShellView *pSV = NULL;
    hr = IShellBrowser_QueryActiveShellView(pSB, &pSV);
    IShellBrowser_Release(pSB);
    if (FAILED(hr) || !pSV) return;

    IFolderView *pFV = NULL;
    hr = IShellView_QueryInterface(pSV, &IID_IFolderView, (void **)&pFV);
    IShellView_Release(pSV);
    if (FAILED(hr)) return;

    IShellFolder *pSF = NULL;
    hr = IFolderView_GetFolder(pFV, &IID_IShellFolder, (void **)&pSF);
    if (FAILED(hr)) { IFolderView_Release(pFV); return; }

    int count = 0;
    IFolderView_ItemCount(pFV, SVGIO_ALLVIEW, &count);

    for (int i = 0; i < count; i++) {
        LPITEMIDLIST pidl = NULL;
        if (SUCCEEDED(IFolderView_Item(pFV, i, &pidl))) {
            STRRET sr;
            if (SUCCEEDED(IShellFolder_GetDisplayNameOf(pSF, pidl, SHGDN_NORMAL, &sr))) {
                wchar_t name[MAX_PATH];
                if (SUCCEEDED(StrRetToBufW(&sr, pidl, name, MAX_PATH))
                    && _wcsicmp(name, targetName) == 0) {
                    IFolderView_SelectItem(pFV, i,
                        SVSI_SELECT | SVSI_FOCUSED | SVSI_ENSUREVISIBLE
                        | SVSI_DESELECTOTHERS);
                    CoTaskMemFree(pidl);
                    IShellFolder_Release(pSF);
                    IFolderView_Release(pFV);
                    return;
                }
            }
            CoTaskMemFree(pidl);
        }
    }

    IShellFolder_Release(pSF);
    IFolderView_Release(pFV);
}

// ── IFileDialogEvents (deferred selection via one-shot timer) ───────────────

#define SEL_TIMER_ID 0x5E1

static IFileDialog *g_selDialog;
static wchar_t      g_selTarget[MAX_PATH];

static VOID CALLBACK SelTimerProc(HWND hwnd, UINT msg, UINT_PTR id, DWORD time) {
    (void)msg; (void)time;
    KillTimer(hwnd, id);
    if (g_selDialog)
        SelectItemByName(g_selDialog, g_selTarget);
    g_selDialog = NULL;
}

typedef struct {
    IFileDialogEventsVtbl *lpVtbl;
    LONG     refCount;
    wchar_t  targetName[MAX_PATH];
    BOOL     fired;
} SelectEvents;

static HRESULT STDMETHODCALLTYPE SE_QueryInterface(
        IFileDialogEvents *This, REFIID riid, void **ppv) {
    if (IsEqualIID(riid, &IID_IUnknown)
        || IsEqualIID(riid, &IID_IFileDialogEvents)) {
        *ppv = This;
        IFileDialogEvents_AddRef(This);
        return S_OK;
    }
    *ppv = NULL;
    return E_NOINTERFACE;
}

static ULONG STDMETHODCALLTYPE SE_AddRef(IFileDialogEvents *This) {
    return InterlockedIncrement(&((SelectEvents *)This)->refCount);
}

static ULONG STDMETHODCALLTYPE SE_Release(IFileDialogEvents *This) {
    LONG r = InterlockedDecrement(&((SelectEvents *)This)->refCount);
    if (r == 0) free(This);
    return r;
}

// Stubs for unused callbacks
static HRESULT STDMETHODCALLTYPE SE_Stub1(IFileDialogEvents *t, IFileDialog *d)
    { (void)t; (void)d; return S_OK; }
static HRESULT STDMETHODCALLTYPE SE_Stub2(IFileDialogEvents *t, IFileDialog *d, IShellItem *i)
    { (void)t; (void)d; (void)i; return S_OK; }
static HRESULT STDMETHODCALLTYPE SE_Stub3(IFileDialogEvents *t, IFileDialog *d, IShellItem *i, FDE_SHAREVIOLATION_RESPONSE *r)
    { (void)t; (void)d; (void)i; (void)r; return S_OK; }
static HRESULT STDMETHODCALLTYPE SE_Stub4(IFileDialogEvents *t, IFileDialog *d, IShellItem *i, FDE_OVERWRITE_RESPONSE *r)
    { (void)t; (void)d; (void)i; (void)r; return S_OK; }

static HRESULT STDMETHODCALLTYPE SE_OnFolderChange(
        IFileDialogEvents *This, IFileDialog *pfd) {
    SelectEvents *self = (SelectEvents *)This;
    if (self->fired) return S_OK;
    self->fired = TRUE;

    // Get the dialog HWND so we can post a timer on it.
    IOleWindow *pOW = NULL;
    HRESULT hr = IFileDialog_QueryInterface(pfd, &IID_IOleWindow, (void **)&pOW);
    if (FAILED(hr)) return S_OK;

    HWND hwnd = NULL;
    IOleWindow_GetWindow(pOW, &hwnd);
    IOleWindow_Release(pOW);
    if (!hwnd) return S_OK;

    g_selDialog = pfd;
    wcscpy(g_selTarget, self->targetName);
    SetTimer(hwnd, SEL_TIMER_ID, 50, SelTimerProc);
    return S_OK;
}

// Vtable order must match IFileDialogEventsVtbl in shobjidl.h:
//   QI, AddRef, Release, OnFileOk, OnFolderChanging, OnFolderChange,
//   OnSelectionChange, OnShareViolation, OnTypeChange, OnOverwrite
static IFileDialogEventsVtbl g_SE_Vtbl = {
    SE_QueryInterface, SE_AddRef, SE_Release,
    SE_Stub1,           /* OnFileOk         */
    SE_Stub2,           /* OnFolderChanging  */
    SE_OnFolderChange,  /* OnFolderChange    */
    SE_Stub1,           /* OnSelectionChange */
    SE_Stub3,           /* OnShareViolation  */
    SE_Stub1,           /* OnTypeChange      */
    SE_Stub4            /* OnOverwrite       */
};

// ── Entry point ─────────────────────────────────────────────────────────────

int wmain(int argc, wchar_t *argv[]) {
    const wchar_t *title    = NULL;
    const wchar_t *filter   = NULL;
    const wchar_t *initPath = NULL;
    BOOL pickFolder = FALSE;

    for (int i = 1; i < argc; i++) {
        if (wcscmp(argv[i], L"--title") == 0 && i + 1 < argc)
            title = argv[++i];
        else if (wcscmp(argv[i], L"--filter") == 0 && i + 1 < argc)
            filter = argv[++i];
        else if (wcscmp(argv[i], L"--folder") == 0)
            pickFolder = TRUE;
        else if (!initPath)
            initPath = argv[i];
    }

    if (!initPath) {
        fwprintf(stderr,
            L"Usage: openFileDialog [--title \"...\"] [--filter \"Name|*.ext\"]"
            L" [--folder] <path>\n");
        return 1;
    }

    // ── Resolve path ────────────────────────────────────────────────────

    wchar_t fullpath[MAX_PATH];
    if (!GetFullPathNameW(initPath, MAX_PATH, fullpath, NULL)) {
        fwprintf(stderr, L"Invalid path: %s\n", initPath);
        return 1;
    }

    // Navigate to the parent directory so the target can be pre-selected.
    // Root paths (e.g. "C:\") and non-existent paths are used as-is.
    wchar_t dirpath[MAX_PATH];
    DWORD attr = GetFileAttributesW(fullpath);

    wcscpy(dirpath, fullpath);
    if (attr != INVALID_FILE_ATTRIBUTES) {
        wchar_t *lastSlash = wcsrchr(dirpath, L'\\');
        if (lastSlash && lastSlash != dirpath)
            *lastSlash = L'\0';
    }

    // ── COM init ────────────────────────────────────────────────────────

    HRESULT hr = CoInitializeEx(NULL,
        COINIT_APARTMENTTHREADED | COINIT_DISABLE_OLE1DDE);
    if (FAILED(hr)) {
        fwprintf(stderr, L"CoInitializeEx failed: 0x%08lX\n", hr);
        return 1;
    }

    // ── Create dialog ───────────────────────────────────────────────────

    IFileOpenDialog *pDialog = NULL;
    hr = CoCreateInstance(&CLSID_FileOpenDialog, NULL, CLSCTX_ALL,
                          &IID_IFileOpenDialog, (void **)&pDialog);
    if (FAILED(hr)) {
        fwprintf(stderr, L"Failed to create dialog: 0x%08lX\n", hr);
        CoUninitialize();
        return 1;
    }

    // ── Options ─────────────────────────────────────────────────────────

    DWORD options = 0;
    IFileOpenDialog_GetOptions(pDialog, &options);
    options |= FOS_ALLOWMULTISELECT | FOS_FORCEFILESYSTEM | FOS_PATHMUSTEXIST;
    if (pickFolder)
        options |= FOS_PICKFOLDERS;
    IFileOpenDialog_SetOptions(pDialog, options);

    if (title)
        IFileOpenDialog_SetTitle(pDialog, title);

    // ── File type filter (ignored in folder mode) ───────────────────────

    if (!pickFolder) {
        if (filter) {
            wchar_t filterBuf[512];
            wcscpy(filterBuf, filter);
            wchar_t *sep = wcschr(filterBuf, L'|');
            if (sep) {
                *sep = L'\0';
                COMDLG_FILTERSPEC spec[2];
                spec[0].pszName = filterBuf;
                spec[0].pszSpec = sep + 1;
                spec[1].pszName = L"All Files";
                spec[1].pszSpec = L"*.*";
                IFileOpenDialog_SetFileTypes(pDialog, 2, spec);
            }
        } else {
            COMDLG_FILTERSPEC spec = { L"All Files", L"*.*" };
            IFileOpenDialog_SetFileTypes(pDialog, 1, &spec);
        }
    }

    // ── Initial directory ───────────────────────────────────────────────

    IShellItem *pFolder = NULL;
    hr = SHCreateItemFromParsingName(dirpath, NULL,
                                     &IID_IShellItem, (void **)&pFolder);
    if (SUCCEEDED(hr)) {
        IFileOpenDialog_SetFolder(pDialog, pFolder);
        IShellItem_Release(pFolder);
    }

    // ── Pre-select item ─────────────────────────────────────────────────

    DWORD evtCookie = 0;
    if (attr != INVALID_FILE_ATTRIBUTES) {
        const wchar_t *base = wcsrchr(fullpath, L'\\');
        if (base && base[1]) {
            SelectEvents *pEvt = (SelectEvents *)calloc(1, sizeof(*pEvt));
            if (pEvt) {
                pEvt->lpVtbl   = &g_SE_Vtbl;
                pEvt->refCount = 1;
                wcscpy(pEvt->targetName, base + 1);
                IFileOpenDialog_Advise(pDialog,
                    (IFileDialogEvents *)pEvt, &evtCookie);
                IFileDialogEvents_Release((IFileDialogEvents *)pEvt);
            }
        }
    }

    // ── Show & collect results ──────────────────────────────────────────

    // Use the current foreground window as owner so the dialog stays in
    // front and doesn't lose focus to the caller (e.g. terminal/yazi).
    HWND hwndOwner = GetForegroundWindow();
    hr = IFileOpenDialog_Show(pDialog, hwndOwner);

    if (hr != HRESULT_FROM_WIN32(ERROR_CANCELLED) && SUCCEEDED(hr)) {
        IShellItemArray *pResults = NULL;
        hr = IFileOpenDialog_GetResults(pDialog, &pResults);
        if (SUCCEEDED(hr)) {
            DWORD count = 0;
            IShellItemArray_GetCount(pResults, &count);
            for (DWORD i = 0; i < count; i++) {
                IShellItem *pItem = NULL;
                if (SUCCEEDED(IShellItemArray_GetItemAt(pResults, i, &pItem))) {
                    PrintItemPath(pItem);
                    IShellItem_Release(pItem);
                }
            }
            IShellItemArray_Release(pResults);
        }
    }

    // ── Cleanup ─────────────────────────────────────────────────────────

    if (evtCookie)
        IFileOpenDialog_Unadvise(pDialog, evtCookie);
    IFileOpenDialog_Release(pDialog);
    CoUninitialize();
    return 0;
}
