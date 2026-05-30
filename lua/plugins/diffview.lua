return {
	"sindrets/diffview.nvim",

	dependencies = {
		"nvim-lua/plenary.nvim",
	},

	config = function()
		require("diffview").setup({
			enhanced_diff_hl = true,

			view = {
				default = {
					layout = "diff2_horizontal",
				},

				merge_tool = {
					layout = "diff3_horizontal",
				},

				file_history = {
					layout = "diff2_horizontal",
				},
			},

			file_panel = {
				listing_style = "tree",
				win_config = {
					position = "left",
					width = 35,
				},
			},

			file_history_panel = {
				log_options = {
					git = {
						single_file = {
							diff_merges = "combined",
						},
					},
				},

				win_config = {
					position = "bottom",
					height = 16,
				},
			},

			hooks = {},

			keymaps = {
				disable_defaults = false,
			},
		})

		-- Keymaps
		vim.keymap.set("n", "<leader>gv", "<cmd>DiffviewOpen<CR>", { desc = "Open Diffview" })

		vim.keymap.set("n", "<leader>gq", "<cmd>DiffviewClose<CR>", { desc = "Close Diffview" })

		vim.keymap.set("n", "<leader>gh", "<cmd>DiffviewFileHistory %<CR>", { desc = "Current File History" })

		vim.keymap.set("n", "<leader>gH", "<cmd>DiffviewFileHistory<CR>", { desc = "Repo File History" })
	end,
}
