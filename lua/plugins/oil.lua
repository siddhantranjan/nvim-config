-- ================================================================================================
-- TITLE : oil.nvim
-- ABOUT :
--   Edit the filesystem like a buffer. Renaming a file is renaming a line; deleting is `dd`;
--   creating is typing a new line. Changes are staged until `:w`.
-- LINKS :
--   > github : https://github.com/stevearc/oil.nvim
-- ================================================================================================

return {
	"stevearc/oil.nvim",
	---@module 'oil'
	---@type oil.SetupOpts
	dependencies = { "nvim-mini/mini.icons" },
	-- Loading eagerly is the documented recommendation: oil replaces netrw, so it has to be
	-- present before the first `nvim <directory>`.
	lazy = false,

	keys = {
		{ "<leader>q", "<cmd>Oil<cr>", desc = "Open Oil (parent directory)" },
		{
			"<leader>Q",
			function()
				require("oil").toggle_float()
			end,
			desc = "Open Oil (floating)",
		},
	},

	opts = {
		default_file_explorer = true,
		delete_to_trash = true, -- recoverable; plain :w deletions are not
		skip_confirm_for_simple_edits = false,
		watch_for_changes = true,

		view_options = {
			show_hidden = true,
			natural_order = true,
			is_always_hidden = function(name, _)
				return name == ".." or name == ".git"
			end,
		},

		columns = { "icon" },

		win_options = {
			wrap = false,
			signcolumn = "no",
			cursorcolumn = false,
			foldcolumn = "0",
			spell = false,
			list = false,
			conceallevel = 3,
			concealcursor = "nvic",
		},

		keymaps = {
			["g?"] = "actions.show_help",
			["<CR>"] = "actions.select",
			["<C-v>"] = { "actions.select", opts = { vertical = true }, desc = "Open in vertical split" },
			["<C-x>"] = { "actions.select", opts = { horizontal = true }, desc = "Open in horizontal split" },
			["<C-t>"] = { "actions.select", opts = { tab = true }, desc = "Open in new tab" },
			["<C-p>"] = "actions.preview",
			["q"] = "actions.close",
			["<C-l>"] = "actions.refresh",
			["-"] = "actions.parent",
			["_"] = "actions.open_cwd",
			["`"] = "actions.cd",
			["~"] = { "actions.cd", opts = { scope = "tab" }, desc = "cd (tab)" },
			["gs"] = "actions.change_sort",
			["gx"] = "actions.open_external",
			["g."] = "actions.toggle_hidden",
			["g\\"] = "actions.toggle_trash",
		},

		float = {
			padding = 4,
			max_width = 100,
			max_height = 30,
			border = "rounded",
		},

		preview_win = {
			update_on_cursor_moved = true,
		},
	},
}
