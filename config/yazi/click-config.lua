local _last_click = { url = nil, time = 0 }
local DOUBLE_CLICK_MS = 0.5 -- seconds

function Entity:click(event, up)
	if up or event.is_middle then return end

	local url = tostring(self._file.url)
	local now = ya.time()

	if event.is_right then
		ya.emit("reveal", { self._file.url })
		ya.emit("plugin", { "show-context-menu" })
		_last_click = { url = nil, time = 0 }
		return
	end

	-- Left click: reveal (move cursor to) the file
	ya.emit("reveal", { self._file.url })

	-- Double-click detection
	if _last_click.url == url and (now - _last_click.time) < DOUBLE_CLICK_MS then
		if self._file.cha.is_dir then
			ya.emit("enter", {})
		else
			ya.emit("open", { hovered = true })
		end
		_last_click = { url = nil, time = 0 }
	else
		_last_click = { url = url, time = now }
	end
end
