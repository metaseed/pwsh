-- ~/.config/yazi/init.lua
function Linemode:size_and_mtime()
	local time = math.floor(self._file.cha.mtime or 0)
	if time == 0 then
		time = ""
	elseif os.date("%Y", time) == os.date("%Y") then
		time = os.date("%b %d %H:%M", time)
	else
		time = os.date("%b %d  %Y", time)
	end

	local size = self._file:size()
	return string.format("%s %s", size and ya.readable_size(size) or "-", time)
end

th.git = th.git or {}
th.git.unknown_sign = " "
th.git.ignored_sign = ""
th.git.untracked_sign = "?"
th.git.modified_sign = "~" --""
th.git.added_sign = "+" --""
th.git.deleted_sign = "-" --""
th.git.updated_sign = "⨤" --"✔" -- staged or index
th.git.clean_sign = " "
require("git"):setup {
	-- Order of status signs showing in the linemode
	order = 1500,
}

function Entity:click(event, up)
	if up or event.is_middle then return end
	ya.emit("reveal", { self._file.url })
	if event.is_right then
		ya.emit("plugin", { "show-context-menu" })
	else
		-- ya.emit("open", {})
	end
end

dofile(os.getenv("YAZI_CONFIG_HOME") .. "/bookmarks/whoosh.init.lua")
-- https://github.com/hankertrix/augment-command.yazi
-- Using the default configuration
require("augment-command"):setup({
    prompt = false,
    default_item_group_for_prompt = "hovered",
    smart_enter = false,
    smart_paste = false,
    smart_tab_create = false,
    smart_tab_switch = false,
    confirm_on_quit = true,
    open_file_after_creation = false,
    enter_directory_after_creation = false,
    use_default_create_behaviour = false,
    enter_archives = true,
    extract_retries = 3,
    recursively_extract_archives = true,
    preserve_file_permissions = false,
    encrypt_archives = false,
    encrypt_archive_headers = false,
    reveal_created_archive = true,
    remove_archived_files = false,
    must_have_hovered_item = true,
    skip_single_subdirectory_on_enter = true,
    skip_single_subdirectory_on_leave = true,
    smooth_scrolling = false,
    scroll_delay = 0.02,
    create_item_delay = 0.25,
    wraparound_file_navigation = true,
})