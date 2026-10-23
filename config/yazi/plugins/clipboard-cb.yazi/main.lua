-- NOTE (2026-09-30): renamed from `clipboard.yazi` to `clipboard-cb.yazi`.
-- Since yazi v26.8.15 (https://github.com/sxyazi/yazi/pull/4005) and the
-- follow-up OSC 5522 clipboard support (https://github.com/sxyazi/yazi/pull/4035),
-- yazi ships a BUILT-IN plugin/module also named `clipboard`, which pastes
-- files from the OS clipboard natively (no external `cb` tool needed) when
-- the terminal replies to an OSC 5522 clipboard-read request with a
-- `text/uri-list`. Having a custom plugin folder also named `clipboard.yazi`
-- collides with that reserved name and triggers a startup deprecation warning.
--
-- As of now, OSC 5522 is only implemented by Kitty (per the PR author's
-- testing), NOT by Windows Terminal. So on Windows this custom plugin is
-- still required.
--
-- TODO: once Windows Terminal (or whatever terminal you use) supports
-- OSC 5522, switch to the built-in behavior instead:
--   1. Delete this `clipboard-cb.yazi` plugin folder.
--   2. Remove the `<S-p>` -> `plugin clipboard-cb` keymap entry in keymap.toml
--      (and the matching `!config/yazi/plugins/clipboard-cb.yazi` line in .gitignore).
--   3. Just do a native terminal paste (e.g. right-click paste / Ctrl+Shift+V)
--      while browsing in yazi's file list - no plugin/keybinding needed.

-- Note: the cb is not under maintenance, and not work well on win11, some time hanging.
-- Solution: gps cb|spps
-- <S-p> to paste from system clipboard.

-- adjust the system clipboard for past functionality. (yazi system-clipboard)
-- https://github.com/Slackadays/ClipBoard
-- Meant to run at async context. (yazi system-clipboard)
-- paste files FROM cb clipboard into current directory (or hovered dir)

local get_cwd = ya.sync(function(state)
	-- local h = cx.active.current.hovered
	-- if h and h.cha.is_dir then
	-- 	return tostring(h.url)
	-- end
	return tostring(cx.active.current.cwd)
end)

return {
	entry = function(self, job)
		local cwd = get_cwd()  -- called from async entry, safe

		local status, err = Command("cb")
			:arg("paste")
			:cwd(cwd)
			:status()

		if status and status.success then
			ya.notify({
				title = "Clipboard",
				content = "Pasted into " .. cwd,
				level = "info",
				timeout = 5,
			})
		else
			ya.notify({
				title = "Clipboard",
				content = string.format(
					"Could not paste: %s",
					status and tostring(status.code) or tostring(err)
				),
				level = "error",
				timeout = 5,
			})
		end
	end,
}