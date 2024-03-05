-- return {
-- 	"nvimtools/none-ls.nvim",
-- 	config = function()
-- 		local null_ls = require("null-ls")
-- 		local augroup = vim.api.nvim_create_augroup("LspFormatting", {})
-- 		null_ls.setup({
-- 			on_attach = function(client, bufnr)
-- 				if client.supports_method("textDocument/formatting") then
-- 					vim.api.nvim_clear_autocmds({ group = augroup, buffer = bufnr })
-- 					vim.api.nvim_create_autocmd("BufWritePre", {
-- 						group = augroup,
-- 						buffer = bufnr,
-- 						callback = function()
-- 							vim.lsp.buf.format({ async = false })
-- 						end,
-- 					})
-- 				end
-- 			end,
-- 			sources = {
-- 				null_ls.builtins.formatting.stylua,
-- 				null_ls.builtins.formatting.prettier,
-- 				null_ls.builtins.formatting.puppet_lint,
-- 				null_ls.builtins.formatting.blade_formatter,
-- 				null_ls.builtins.diagnostics.puppet_lint,
-- 				null_ls.builtins.diagnostics.phpstan,
-- 				null_ls.builtins.code_actions.refactoring,
-- 				null_ls.builtins.code_actions.gomodifytags,
-- 				null_ls.builtins.code_actions.impl,
-- 				null_ls.builtins.formatting.goimports,
-- 				null_ls.builtins.formatting.gofumpt,
-- 				null_ls.builtins.formatting.terraform_fmt,
-- 				null_ls.builtins.formatting.prismaFmt,
-- 				null_ls.builtins.formatting.shfmt,
-- 			},
-- 		})
-- 	end,
-- }
return {
	"stevearc/conform.nvim",
	opts = {},
	config = function()
		require("conform").setup({
			formatters_by_ft = {
				lua = { "stylua" },
				javascript = { "prettier" },
				typescript = { "prettier" },
				puppet = { "puppet-lint" },
				blade = { "blade-formatter" },
				prisma = { "prismaFmt" },
				sh = { "shfmt" },
			},
		})
		vim.api.nvim_create_autocmd("BufWritePre", {
			pattern = "*",
			callback = function()
				require("conform").format({ lsp_fallback = true })
			end,
		})
	end,
}
