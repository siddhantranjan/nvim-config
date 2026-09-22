-- ================================================================================================
-- TITLE : lspsaga.nvim
-- ABOUT : Prettier UI over the built-in LSP client -- peek definition, code action, rename.
-- NOTE  :
--   The repo moved: `glepnir/lspsaga.nvim` (what this config pointed at) is the author's old
--   personal namespace and no longer receives updates. `nvimdev/lspsaga.nvim` is the
--   maintained location.
--
--   Keymaps for these commands are buffer-local and live in lua/utils/lsp.lua, so they only
--   exist where a language server is actually attached.
-- LINKS :
--   > github : https://github.com/nvimdev/lspsaga.nvim
-- ================================================================================================

return {
	"nvimdev/lspsaga.nvim",
	event = "LspAttach",
	cmd = "Lspsaga", -- belt and braces: the :Lspsaga command works even before any attach
	dependencies = {
		"nvim-treesitter/nvim-treesitter",
		"nvim-mini/mini.icons",
	},

	opts = function()
		return {
			ui = {
				border = "rounded",
				code_action = require("utils.icons").misc.lightbulb,
			},

			-- Move within saga floats with the same keys used to move in the cmp menu.
			scroll_preview = { scroll_down = "<C-f>", scroll_up = "<C-b>" },

			definition = {
				width = 0.7,
				height = 0.5,
				keys = {
					edit = "<CR>",
					vsplit = "<C-v>",
					split = "<C-x>",
					tabe = "<C-t>",
					quit = "q",
				},
			},

			finder = {
				max_height = 0.6,
				keys = {
					toggle_or_open = "<CR>",
					vsplit = "<C-v>",
					split = "<C-x>",
					tabe = "<C-t>",
					quit = "q",
				},
			},

			code_action = {
				show_server_name = true,
				extend_gitsigns = false, -- gitsigns has its own hunk mappings under <leader>g
				keys = { quit = "q", exec = "<CR>" },
			},

			lightbulb = {
				enable = true,
				sign = false, -- sign column is already busy with git + diagnostics
				virtual_text = true,
			},

			diagnostic = {
				show_code_action = true,
				jump_num_shortcut = true,
				max_width = 0.7,
				keys = { quit = { "q", "<ESC>" } },
			},

			outline = {
				win_width = 35,
				auto_preview = false,
				keys = { toggle_or_jump = "<CR>", quit = "q" },
			},

			symbol_in_winbar = {
				-- OFF: dropbar.nvim owns the winbar. Two plugins writing vim.wo.winbar
				-- means whichever updates last wins, and the bar flickers between them.
				enable = false,
			},

			rename = {
				in_select = false, -- start in normal mode so the old name isn't wiped
				keys = { quit = "<C-c>", exec = "<CR>", select = "x" },
			},

			hover = { open_cmd = "!open", open_browser = true },
		}
	end,
}
