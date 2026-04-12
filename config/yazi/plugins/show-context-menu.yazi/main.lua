-- show-context-menu.yazi/main.lua
-- Shows the Windows shell right-click context menu for the hovered item,
-- positioned beside the item's row in the terminal.

local EXE = "M:\\Script\\Pwsh\\config\\yazi\\apps\\showShellContextMenu.exe"

local HEADER_ROWS = 1

local get_cx = ya.sync(function()
	local cur = cx.active.current
	if not cur.hovered then return nil end
	local area = cx.area
	return {
		path = tostring(cur.hovered.url),
		row  = cur.cursor - cur.offset,
		rows = area and area.h or 0,
		cols = area and area.w or 0,
	}
end)

return {
	entry = function()
		local info = get_cx()
		if not info then return end

		local rows = info.rows > 0 and info.rows or 24
		local cols = info.cols > 0 and info.cols or 80
		local row  = HEADER_ROWS + info.row

		local path_q = '"' .. info.path:gsub('"', '\\"') .. '"'
		local cmd = string.format('%s --row %d %d %d %s', EXE, row, rows, cols, path_q)

		ya.emit("shell", { cmd, orphan = true })
	end,
}
