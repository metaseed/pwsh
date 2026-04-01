// Show a Windows File Open dialog that allows multiple file/folder selection,
// and output the selected paths to stdout (one per line).
//
// Parameters:
//   [--title "Dialog Title"]  — optional dialog title (default: "Open")
//   [--filter "Name|*.ext"]   — optional filter (default: "All Files|*.*")
//   [--folder]                — pick folders instead of files
//   <path>                    — file (uses its directory) or directory to open in
//
// Compile (MinGW / MSYS2):
//   gcc -Os -s -o openFileDialog.exe openFileDialog.c -lole32 -lshell32 -luuid -municode
// Compile (MSVC):
//   cl /O2 /W4 openFileDialog.c ole32.lib shell32.lib uuid.lib

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

// Print a shell item's path to stdout
static void PrintItemPath(IShellItem *pItem) {
    LPWSTR path = NULL;
    if (SUCCEEDED(IShellItem_GetDisplayName(pItem, SIGDN_FILESYSPATH, &path))) {
        wprintf(L"%s\n", path);
        CoTaskMemFree(path);
    }
}

int wmain(int argc, wchar_t *argv[]) {
    const wchar_t *title = NULL;
    const wchar_t *filter = NULL;
    const wchar_t *initPath = NULL;
    BOOL pickFolder = FALSE;

    // Parse arguments
    for (int i = 1; i < argc; i++) {
        if (wcscmp(argv[i], L"--title") == 0 && i + 1 < argc) {
            title = argv[++i];
        } else if (wcscmp(argv[i], L"--filter") == 0 && i + 1 < argc) {
            filter = argv[++i];
        } else if (wcscmp(argv[i], L"--folder") == 0) {
            pickFolder = TRUE;
        } else if (!initPath) {
            initPath = argv[i];
        }
    }

    if (!initPath) {
        fwprintf(stderr, L"Usage: openFileDialog [--title \"Title\"] [--filter \"Name|*.ext\"] [--folder] <path>\n");
        return 1;
    }

    // Resolve to absolute path
    wchar_t fullpath[MAX_PATH];
    if (!GetFullPathNameW(initPath, MAX_PATH, fullpath, NULL)) {
        fwprintf(stderr, L"Invalid path: %s\n", initPath);
        return 1;
    }

    // If path is a file, use its parent directory
    wchar_t dirpath[MAX_PATH];
    DWORD attr = GetFileAttributesW(fullpath);
    if (attr == INVALID_FILE_ATTRIBUTES) {
        // Path doesn't exist — try using it as-is (maybe parent dir)
        wcscpy(dirpath, fullpath);
    } else if (!(attr & FILE_ATTRIBUTE_DIRECTORY)) {
        // It's a file — get its directory
        wcscpy(dirpath, fullpath);
        wchar_t *lastSlash = wcsrchr(dirpath, L'\\');
        if (lastSlash) *lastSlash = L'\0';
    } else {
        wcscpy(dirpath, fullpath);
    }

    // Initialize COM
    HRESULT hr = CoInitializeEx(NULL, COINIT_APARTMENTTHREADED | COINIT_DISABLE_OLE1DDE);
    if (FAILED(hr)) {
        fwprintf(stderr, L"CoInitializeEx failed: 0x%08lX\n", hr);
        return 1;
    }

    // Create the File Open Dialog
    IFileOpenDialog *pDialog = NULL;
    hr = CoCreateInstance(&CLSID_FileOpenDialog, NULL, CLSCTX_ALL,
                          &IID_IFileOpenDialog, (void **)&pDialog);
    if (FAILED(hr)) {
        fwprintf(stderr, L"Failed to create FileOpenDialog: 0x%08lX\n", hr);
        CoUninitialize();
        return 1;
    }

    // Set options: multi-select
    DWORD options = 0;
    IFileOpenDialog_GetOptions(pDialog, &options);
    options |= FOS_ALLOWMULTISELECT | FOS_FORCEFILESYSTEM | FOS_PATHMUSTEXIST;
    if (pickFolder) {
        options |= FOS_PICKFOLDERS;
    }
    IFileOpenDialog_SetOptions(pDialog, options);

    // Set title
    if (title) {
        IFileOpenDialog_SetTitle(pDialog, title);
    }

    // Set file type filter (parse "Name|*.ext" or "Name|*.ext;*.ext2")
    if (!pickFolder) {
        if (filter) {
            // Parse filter string: "Display Name|pattern"
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

    // Set initial directory
    IShellItem *pFolder = NULL;
    hr = SHCreateItemFromParsingName(dirpath, NULL, &IID_IShellItem, (void **)&pFolder);
    if (SUCCEEDED(hr)) {
        IFileOpenDialog_SetFolder(pDialog, pFolder);
        IShellItem_Release(pFolder);
    }

    // Show the dialog
    hr = IFileOpenDialog_Show(pDialog, NULL);
    if (hr == HRESULT_FROM_WIN32(ERROR_CANCELLED)) {
        IFileOpenDialog_Release(pDialog);
        CoUninitialize();
        return 0;  // User cancelled — not an error
    }
    if (FAILED(hr)) {
        fwprintf(stderr, L"Dialog failed: 0x%08lX\n", hr);
        IFileOpenDialog_Release(pDialog);
        CoUninitialize();
        return 1;
    }

    // Get results
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

    IFileOpenDialog_Release(pDialog);
    CoUninitialize();
    return 0;
}
