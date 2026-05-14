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