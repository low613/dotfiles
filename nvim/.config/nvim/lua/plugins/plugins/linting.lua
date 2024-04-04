return {
	{
		"mfussenegger/nvim-lint",
		opts = {},
		config = function()
			require("lint").linters_by_ft = {
				php = { "phpstan", "phpcs" },
			}
			local phpcs = require("lint").linters.phpcs
			local phpcs_bin = "phpcs"
			phpcs.cmd = function()
				local local_bin = vim.fn.fnamemodify("vendor/bin/" .. phpcs_bin, ":p")
				return vim.loop.fs_stat(local_bin) and local_bin or vim.loop.fs_stat(phpcs_bin) and phpcs_bin or "true"
			end
			vim.api.nvim_create_autocmd({ "BufWritePost" }, {
				callback = function()
					require("lint").try_lint()
				end,
			})
		end,
	},
}
