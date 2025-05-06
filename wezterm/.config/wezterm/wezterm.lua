local wezterm = require("wezterm")
local sessionizer = require("sessionizer")
local config = wezterm.config_builder()
local act = wezterm.action

config.color_scheme = "Catppuccin Mocha"

config.font = wezterm.font("Fira Code")
config.keys = {
	{
		key = "f",
		mods = "CTRL",
		action = wezterm.action_callback(sessionizer.toggle),
	},
	{
		key = "s",
		mods = "CTRL|SHIFT",
		action = act.SwitchToWorkspace({
			name = "/home/eli/work/schoolbox",
			spawn = {
				cwd = "/home/eli/work/schoolbox",
			},
		}),
	},
	{
		key = "p",
		mods = "CTRL|SHIFT",
		action = act.SwitchToWorkspace({
			name = "/home/eli/work/puppet-alaress",
			spawn = {
				cwd = "/home/eli/work/puppet-alaress",
			},
		}),
	},
	{
		key = "i",
		mods = "CTRL|SHIFT",
		action = act.SwitchToWorkspace({
			name = "/home/eli/work/instance-registry-new",
			spawn = {
				cwd = "/home/eli/work/instance-registry-new",
			},
		}),
	},
	{
		key = "t",
		mods = "CTRL|SHIFT",
		action = act.SwitchToWorkspace({
			name = "/home/eli/work/terraform",
			spawn = {
				cwd = "/home/eli/work/terraform",
			},
		}),
	},
	{ key = "l", mods = "ALT", action = wezterm.action.ShowLauncherArgs({ flags = "FUZZY|TABS|WORKSPACES" }) },
}
config.term = "wezterm"
return config
