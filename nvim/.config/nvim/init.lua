vim.g.mapleader = " "
vim.g.maplocalleader = " "
vim.o.tabstop = 4
require("plugins")
vim.o.scrollback = 8
vim.o.scrolloff = 8
vim.o.hlsearch = false

vim.wo.number = true
vim.wo.relativenumber = true
vim.o.mouse = "a"
vim.o.breakindent = true
vim.o.swapfile = false
-- Save undo history
vim.o.undofile = true
vim.o.wrap = false
-- Case-insensitive searching UNLESS \C or capital in search
vim.o.ignorecase = true
vim.o.smartcase = true

vim.wo.signcolumn = "yes"

-- Decrease update time
vim.o.updatetime = 250
vim.o.timeoutlen = 300

-- NOTE: You should make sure your terminal supports this
vim.o.termguicolors = true

vim.o.spell = true
vim.o.spelllang = "en_au"
-- Keymaps for better default experience
-- See `:help vim.keymap.set()`
vim.keymap.set({ "n", "v" }, "<Space>", "<Nop>", { silent = true })
vim.keymap.set({ "i", "v", "x", "n" }, "<C-[>", "<Esc>", { noremap = true, silent = true })
-- Remap for dealing with word wrap
vim.keymap.set("n", "k", "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
vim.keymap.set("n", "j", "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")

-- Diagnostic keymaps
vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, { desc = "Go to previous diagnostic message" })
vim.keymap.set("n", "]d", vim.diagnostic.goto_next, { desc = "Go to next diagnostic message" })
vim.keymap.set("n", "<leader>e", vim.diagnostic.open_float, { desc = "Open floating diagnostic message" })
vim.keymap.set("n", "<leader>q", vim.diagnostic.setloclist, { desc = "Open diagnostics list" })

-- [[ Highlight on yank ]]
-- See `:help vim.highlight.on_yank()`
local highlight_group = vim.api.nvim_create_augroup("YankHighlight", { clear = true })
vim.api.nvim_create_autocmd("TextYankPost", {
	callback = function()
		vim.highlight.on_yank()
	end,
	group = highlight_group,
	pattern = "*",
})
local blade_group = vim.api.nvim_create_augroup("lsp_blade", { clear = true })
vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
	group = blade_group,
	pattern = "*.blade.php",
	callback = function()
		vim.bo.filetype = "php"
	end,
})

vim.api.nvim_create_autocmd("LspAttach", {
	pattern = "*.blade.php",
	callback = function(args)
		vim.schedule(function()
			for _, client in ipairs(vim.lsp.get_active_clients()) do
				if client.name == "intelephense" and client.attached_buffers[args.buf] then
					vim.bo.filetype = "blade"
					vim.bo.syntax = "blade"
				end
			end
		end)
	end,
})
vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")
vim.keymap.set("n", "n", "nzzzv")
vim.keymap.set("n", "N", "Nzzzv")

vim.keymap.set({ "n", "v" }, "<leader>y", [["+y]])
vim.keymap.set("n", "<leader>Y", [["+Y]])
vim.keymap.set("n", "<C-f>", "<cmd>silent !tmux neww tmux-sessionizer<CR>")
vim.keymap.set("x", "<leader>p", [["_dP]])

vim.filetype.add({
	pattern = {
		[".env.*"] = "dotenv",
	},
})
