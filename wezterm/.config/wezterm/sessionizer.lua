local wezterm = require("wezterm")
local act = wezterm.action

local M = {}

local fd = "/usr/bin/fdfind"
local rootPath = "/home/eli"

M.toggle = function(window, pane)
	local projects = {}
	local configs = wezterm.glob(rootPath .. "/dotfiles/*/.config")
	local locals = wezterm.glob(rootPath .. "/dotfiles/*/.local")

	local cmd = {
		fd,
		"-td",
		"--full-path",
		"--max-depth=1",
		rootPath,
		rootPath,
		rootPath .. "/work",
		rootPath .. "/personal",
	}
	for _, config in ipairs(configs) do
		table.insert(cmd, config)
	end
	for _, local_ in ipairs(locals) do
		table.insert(cmd, local_)
	end
	local success, stdout, stderr = wezterm.run_child_process(cmd)
	if not success then
		wezterm.log_error("Failed to run fd: " .. stderr)
		return
	end

	for line in stdout:gmatch("([^\n]*)\n?") do
		table.insert(projects, { label = tostring(line), id = tostring(line) })
	end

	window:perform_action(
		act.InputSelector({
			action = wezterm.action_callback(function(win, _, id, label)
				if not id and not label then
					wezterm.log_info("Cancelled")
				else
					wezterm.log_info("Selected " .. label)
					win:perform_action(act.SwitchToWorkspace({ name = id, spawn = { cwd = label } }), pane)
				end
			end),
			fuzzy = true,
			title = "Select project",
			choices = projects,
		}),
		pane
	)
end

return M
