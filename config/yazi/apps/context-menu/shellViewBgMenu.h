// shellViewBgMenu.h — Obtain the full folder-background context menu by
//                     creating a real IShellView (CDefView) so that items
//                     like View, Sort by, Paste, Refresh, New, etc. appear.
//
// Requires: CINTERFACE, COBJMACROS, <shobjidl.h>, <shlobj.h>

#ifndef SHELL_VIEW_BG_MENU_H
#define SHELL_VIEW_BG_MENU_H

#include <windows.h>
#include <shobjidl.h>
#include <shlobj.h>
#include <stdlib.h>

// ── Minimal IShellBrowser stub ──────────────────────────────────────────────
// Just enough for IShellView::CreateViewWindow to succeed so CDefView
// builds the full background context menu.

typedef struct MiniBrowser {
    IShellBrowserVtbl *lpVtbl;
    LONG  refCount;
    HWND  hwnd;
} MiniBrowser;

static HRESULT STDMETHODCALLTYPE MB_QI(IShellBrowser *This, REFIID riid, void **ppv) {
    if (IsEqualIID(riid, &IID_IUnknown) ||
        IsEqualIID(riid, &IID_IOleWindow) ||
        IsEqualIID(riid, &IID_IShellBrowser)) {
        *ppv = This;
        IShellBrowser_AddRef(This);
        return S_OK;
    }
    *ppv = NULL;
    return E_NOINTERFACE;
}
static ULONG STDMETHODCALLTYPE MB_AddRef(IShellBrowser *This) {
    return InterlockedIncrement(&((MiniBrowser *)This)->refCount);
}
static ULONG STDMETHODCALLTYPE MB_Release(IShellBrowser *This) {
    LONG r = InterlockedDecrement(&((MiniBrowser *)This)->refCount);
    if (r == 0) free(This);
    return r;
}
static HRESULT STDMETHODCALLTYPE MB_GetWindow(IShellBrowser *This, HWND *ph) {
    *ph = ((MiniBrowser *)This)->hwnd;
    return S_OK;
}

#define MB_STUB_V(name) \
    static HRESULT STDMETHODCALLTYPE name(IShellBrowser *This, ...) { \
        (void)This; return E_NOTIMPL; }

MB_STUB_V(MB_ContextSensitiveHelp)
MB_STUB_V(MB_InsertMenusSB)
MB_STUB_V(MB_SetMenuSB)
MB_STUB_V(MB_RemoveMenusSB)
MB_STUB_V(MB_SetStatusTextSB)
MB_STUB_V(MB_EnableModelessSB)
MB_STUB_V(MB_TranslateAcceleratorSB)
MB_STUB_V(MB_BrowseObject)
MB_STUB_V(MB_GetViewStateStream)
MB_STUB_V(MB_GetControlWindow)
MB_STUB_V(MB_SendControlMsg)
MB_STUB_V(MB_QueryActiveShellView)
MB_STUB_V(MB_SetToolbarItems)

static HRESULT STDMETHODCALLTYPE MB_OnViewWindowActive(IShellBrowser *This, IShellView *pv) {
    (void)This; (void)pv; return S_OK;
}

static IShellBrowserVtbl g_MBVtbl = {
    MB_QI, MB_AddRef, MB_Release,
    MB_GetWindow,
    (void *)MB_ContextSensitiveHelp,
    (void *)MB_InsertMenusSB,
    (void *)MB_SetMenuSB,
    (void *)MB_RemoveMenusSB,
    (void *)MB_SetStatusTextSB,
    (void *)MB_EnableModelessSB,
    (void *)MB_TranslateAcceleratorSB,
    (void *)MB_BrowseObject,
    (void *)MB_GetViewStateStream,
    (void *)MB_GetControlWindow,
    (void *)MB_SendControlMsg,
    (void *)MB_QueryActiveShellView,
    MB_OnViewWindowActive,
    (void *)MB_SetToolbarItems
};

static IShellBrowser *CreateMiniBrowser(HWND hwnd) {
    MiniBrowser *mb = calloc(1, sizeof(*mb));
    if (!mb) return NULL;
    mb->lpVtbl   = &g_MBVtbl;
    mb->refCount = 1;
    mb->hwnd     = hwnd;
    return (IShellBrowser *)mb;
}

// ── Background context menu via IShellView ──────────────────────────────────

// Creates a real IShellView for the given folder path, then retrieves the
// background IContextMenu from it.  The caller must eventually call
// IShellView_DestroyViewWindow + IShellView_Release on *ppSV.
static HRESULT GetBackgroundContextMenu(const wchar_t *path, HWND hwnd,
                                        IContextMenu **ppCM, IShellView **ppSV) {
    *ppCM = NULL;
    *ppSV = NULL;

    PIDLIST_ABSOLUTE pidl = NULL;
    HRESULT hr = SHParseDisplayName(path, NULL, &pidl, 0, NULL);
    if (FAILED(hr)) return hr;

    IShellFolder *pFolder = NULL;
    hr = SHBindToObject(NULL, pidl, NULL, &IID_IShellFolder, (void **)&pFolder);
    CoTaskMemFree(pidl);
    if (FAILED(hr)) return hr;

    IShellView *pSV = NULL;
    hr = IShellFolder_CreateViewObject(pFolder, hwnd,
                                        &IID_IShellView, (void **)&pSV);
    IShellFolder_Release(pFolder);
    if (FAILED(hr)) return hr;

    IShellBrowser *pSB = CreateMiniBrowser(hwnd);
    FOLDERSETTINGS fs = { FVM_DETAILS, 0 };
    RECT rc = {0, 0, 100, 100};
    HWND hwndView = NULL;
    hr = IShellView_CreateViewWindow(pSV, NULL, &fs, pSB, &rc, &hwndView);
    IShellBrowser_Release(pSB);
    if (FAILED(hr)) { IShellView_Release(pSV); return hr; }

    if (hwndView) ShowWindow(hwndView, SW_HIDE);

    hr = IShellView_GetItemObject(pSV, SVGIO_BACKGROUND,
                                   &IID_IContextMenu, (void **)ppCM);
    if (FAILED(hr)) {
        IShellView_DestroyViewWindow(pSV);
        IShellView_Release(pSV);
        return hr;
    }

    *ppSV = pSV;
    return S_OK;
}

#endif // SHELL_VIEW_BG_MENU_H
