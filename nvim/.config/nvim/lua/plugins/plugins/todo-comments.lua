return {
	{
		-- PERF: test
		-- HACK: hack
		-- TODO: todo
		-- FIX: fix
		-- WARNING: warning
		-- NOTE: note
		"folke/todo-comments.nvim",
		dependancies = { "nvim-lua/plenary.nvim" },
		config = function()
			local todo = require("todo-comments")
			todo.setup({})
			vim.keymap.set("n", "<leader>sc", ":TodoTelescope<CR>")
			vim.keymap.set("n", "]t", function()
				todo.jump_next()
			end, { desc = "Jump to next todo" })
			vim.keymap.set("n", "[t", function()
				todo.jump_prev()
			end, { desc = "Jump to previous todo" })
		end,
	},
}
