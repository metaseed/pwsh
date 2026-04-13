-- show-context-menu.yazi/main.lua
-- Shows the Windows shell right-click context menu for the hovered item,
-- positioned beside the item's row in the terminal.
--
-- Plugin args (combinable):
--   --modern      Use SHCreateDefaultContextMenu (richer, IExplorerCommand-
--                 based handlers).
--   --background  Show the folder-background context menu (New, Paste, View,
--                 Sort by …) instead of the item context menu.  Uses the
--                 current directory as the target folder.

local EXE = "M:\\Script\\Pwsh\\config\\yazi\\apps\\context-menu\\showShellContextMenu.exe"

local HEADER_ROWS = 1

local get_cx = ya.sync(function()
	local cur = cx.active.current
	local area = cx.area
	return {
		path    = cur.hovered and tostring(cur.hovered.url) or nil,
		cwd     = tostring(cx.active.current.cwd),
		row     = cur.cursor - cur.offset,
		rows    = area and area.h or 0,
		cols    = area and area.w or 0,
	}
end)

return {
	entry = function(_, job)
		local info = get_cx()
		if not info then return end

		local args = (job and job.args) or {}
		local flags = ""
		local background = args.background
		if args.modern then flags = flags .. " --modern" end
		if background   then flags = flags .. " --background" end

		local target = background and info.cwd or info.path
		if not target then return end

		local rows = info.rows > 0 and info.rows or 24
		local cols = info.cols > 0 and info.cols or 80
		local row  = HEADER_ROWS + info.row

		local path_q = '"' .. target:gsub('"', '\\"') .. '"'
		local cmd = string.format(
			'%s --row %d %d %d%s %s',
			EXE, row, rows, cols, flags, path_q
		)

		ya.emit("shell", { cmd, orphan = true })
	end,
}
