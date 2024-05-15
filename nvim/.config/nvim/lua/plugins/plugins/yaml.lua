return {
	{
		"someone-stole-my-name/yaml-companion.nvim",
		opts = {},
		config = function()
			require("telescope").load_extension("yaml_schema")
		end,
	},
}
