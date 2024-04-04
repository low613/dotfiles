local wezterm = require("wezterm")
local sessionizer = require("sessionizer")
local config = wezterm.config_builder()

config.color_scheme = "Catppuccin Mocha"

config.font = wezterm.font("Fira Code")
config.keys = {
	{
		key = "f",
		mods = "CTRL",
		action = wezterm.action_callback(sessionizer.toggle),
	},
	{ key = "l", mods = "ALT", action = wezterm.action.ShowLauncherArgs({ flags = "FUZZY|TABS|WORKSPACES" }) },
}
return config
