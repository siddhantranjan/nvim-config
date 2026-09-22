-- ================================================================================================
-- TITLE : diffview.nvim
-- ABOUT : Side-by-side diffs, merge conflict resolution, and file history.
-- LINKS :
--   > github : https://github.com/sindrets/diffview.nvim
-- ================================================================================================

return {
	"sindrets/diffview.nvim",
	cmd = { "DiffviewOpen", "DiffviewClose", "DiffviewFileHistory", "DiffviewToggleFiles" },
	dependencies = { "nvim-lua/plenary.nvim" },

	keys = {
		{ "<leader>gv", "<cmd>DiffviewOpen<cr>", desc = "Diffview: open" },
		{ "<leader>gq", "<cmd>DiffviewClose<cr>", desc = "Diffview: close" },
		{ "<leader>gh", "<cmd>DiffviewFileHistory %<cr>", desc = "Diffview: current file history" },
		{ "<leader>gH", "<cmd>DiffviewFileHistory<cr>", desc = "Diffview: repo history" },
		{ "<leader>gM", "<cmd>DiffviewOpen origin/HEAD...HEAD<cr>", desc = "Diffview: review branch" },
		{ "<leader>gh", "<cmd>'<,'>DiffviewFileHistory<cr>", mode = "v", desc = "Diffview: history for selection" },
	},

	opts = {
		enhanced_diff_hl = true,

		view = {
			default = { layout = "diff2_horizontal" },
			merge_tool = {
				layout = "diff3_horizontal",
				disable_diagnostics = true, -- diagnostics are meaningless mid-conflict
				winbar_info = true,
			},
			file_history = { layout = "diff2_horizontal" },
		},

		file_panel = {
			listing_style = "tree",
			win_config = { position = "left", width = 35 },
		},

		file_history_panel = {
			log_options = {
				git = {
					single_file = { diff_merges = "combined" },
					multi_file = { diff_merges = "first-parent" },
				},
			},
			win_config = { position = "bottom", height = 16 },
		},

		keymaps = {
			disable_defaults = false,
			view = {
				{ "n", "<leader>gq", "<cmd>DiffviewClose<cr>", { desc = "Close diffview" } },
			},
			file_panel = {
				{ "n", "<leader>gq", "<cmd>DiffviewClose<cr>", { desc = "Close diffview" } },
			},
		},
	},
}
