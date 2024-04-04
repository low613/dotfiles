return {
	-- Git related plugins

	-- Detect tabstop and shiftwidth automatically
	"tpope/vim-sleuth",

	-- Useful plugin to show you pending keybinds.
	{
		"folke/which-key.nvim",
		config = function()
			require("which-key").register({
				["<leader>c"] = { name = "[C]ode", _ = "which_key_ignore" },
				["<leader>d"] = { name = "[D]ocument", _ = "which_key_ignore" },
				["<leader>g"] = { name = "[G]it", _ = "which_key_ignore" },
				["<leader>h"] = { name = "Git [H]unk", _ = "which_key_ignore" },
				["<leader>r"] = { name = "[R]ename", _ = "which_key_ignore" },
				["<leader>s"] = { name = "[S]earch", _ = "which_key_ignore" },
				["<leader>t"] = { name = "[T]oggle", _ = "which_key_ignore" },
				["<leader>w"] = { name = "[W]orkspace", _ = "which_key_ignore" },
			})
			-- register which-key VISUAL mode
			-- required for visual <leader>hs (hunk stage) to work
			require("which-key").register({
				["<leader>"] = { name = "VISUAL <leader>" },
				["<leader>h"] = { "Git [H]unk" },
			}, { mode = "v" })
		end,
	},
	{
		"nvim-tree/nvim-web-devicons",
		lazy = false,
	},
	{
		"theprimeagen/harpoon",
		branch = "harpoon2",
		dependencies = { "nvim-lua/plenary.nvim" },
		config = function()
			local harpoon = require("harpoon")
			harpoon:setup({
				global_settings = {
					save_on_toggle = false,
				},
			})
			local conf = require("telescope.config").values
			local function toggle_telescope(harpoon_files)
				local file_paths = {}
				for _, item in ipairs(harpoon_files.items) do
					table.insert(file_paths, item.value)
				end
				require("telescope.pickers")
					.new({}, {
						prompt_title = "Harpoon",
						finder = require("telescope.finders").new_table({
							results = file_paths,
						}),
						previewer = conf.file_previewer({}),
						sorter = conf.generic_sorter({}),
					})
					:find()
			end
			vim.keymap.set("n", "<leader>hf", function()
				toggle_telescope(harpoon:list())
			end, { desc = "Open Harpoon Files" })
		end,
		keys = {
			{
				"<C-e>",
				function()
					local harpoon = require("harpoon")
					harpoon.ui:toggle_quick_menu(harpoon:list())
				end,
				desc = "harpoon quick menu",
			},
			{
				"<leader>1",
				function()
					require("harpoon"):list():select(1)
				end,
				desc = "harpoon to file 1",
			},
			{
				"<leader>2",
				function()
					require("harpoon"):list():select(2)
				end,
				desc = "harpoon to file 2",
			},
			{
				"<leader>3",
				function()
					require("harpoon"):list():select(3)
				end,
				desc = "harpoon to file 3",
			},
			{
				"<leader>4",
				function()
					require("harpoon"):list():select(4)
				end,
				desc = "harpoon to file 4",
			},
			{
				"<leader>5",
				function()
					require("harpoon"):list():select(5)
				end,
				desc = "harpoon to file 5",
			},
			{
				"<leader>6",
				function()
					require("harpoon"):list():select(6)
				end,
			},
			{
				"<leader>7",
				function()
					require("harpoon"):list():select(7)
				end,
			},
			{
				"<leader>8",
				function()
					require("harpoon"):list():select(8)
				end,
			},
			{
				"<leader>9",
				function()
					require("harpoon"):list():select(9)
				end,
			},
			{
				"<leader>0",
				function()
					require("harpoon"):list():select(10)
				end,
			},
			{
				"<leader>ha",
				function()
					require("harpoon"):list():add()
				end,
			},
		},
	},
	{
		"catppuccin/nvim",
		priority = 100,
		name = "catppuccin",
		config = function()
			require("catppuccin").setup({
				flavour = "mocha",
				integrations = {
					which_key = true,
				},
			})
			vim.o.termguicolors = true
			vim.cmd.colorscheme("catppuccin")
		end,
	},
	{
		-- Set lualine as statusline
		"nvim-lualine/lualine.nvim",
		-- See `:help lualine.txt`
		opts = {
			options = {
				icons_enabled = true,
				theme = "catppuccin",
				component_separators = "|",
				section_separators = "",
				disabled_filetypes = {
					"dap-repl",
				},
			},
		},
		config = function(self, opts)
			require("lualine").setup({
				options = opts.options,
				sections = {
					lualine_x = { "copilot", "encoding", "fileformat", "filetype" },
				},
				winbar = {
					lualine_c = {
						{
							"navic",
							color_correction = nil,
							navic_opts = nil,
						},
					},
				},
			})
		end,
		dependencies = { "SmiteshP/nvim-navic" },
	},

	{
		-- Add indentation guides even on blank lines
		"lukas-reineke/indent-blankline.nvim",
		-- Enable `lukas-reineke/indent-blankline.nvim`
		-- See `:help ibl`
		main = "ibl",
		opts = {},
	},

	-- "gc" to comment visual regions/lines
	{ "numToStr/Comment.nvim", opts = {} },
	{ -- Collection of various small independent plugins/modules
		"echasnovski/mini.nvim",
		config = function()
			-- Better Around/Inside textobjects
			--
			-- Examples:
			--  - va)  - [V]isually select [A]round [)]parenthen
			--  - yinq - [Y]ank [I]nside [N]ext [']quote
			--  - ci'  - [C]hange [I]nside [']quote
			require("mini.ai").setup({ n_lines = 500 })

			-- Add/delete/replace surroundings (brackets, quotes, etc.)
			--
			-- - saiw) - [S]urround [A]dd [I]nner [W]ord [)]Paren
			-- - sd'   - [S]urround [D]elete [']quotes
			-- - sr)'  - [S]urround [R]eplace [)] [']
			require("mini.surround").setup()
		end,
	},
	-- Fuzzy Finder (files, lsp, etc)
}
