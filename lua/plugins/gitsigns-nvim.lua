return {
	"lewis6991/gitsigns.nvim",

	event = { "BufReadPre", "BufNewFile" },

	config = function()
		local gitsigns = require("gitsigns")

		gitsigns.setup({
			signs = {
				add = { text = "│" },
				change = { text = "│" },
				delete = { text = "_" },
				topdelete = { text = "‾" },
				changedelete = { text = "~" },
				untracked = { text = "┆" },
			},

			signcolumn = true,
			numhl = false,
			linehl = false,
			word_diff = false,

			watch_gitdir = {
				follow_files = true,
			},

			auto_attach = true,
			attach_to_untracked = true,

			current_line_blame = false,

			current_line_blame_opts = {
				virt_text = true,
				virt_text_pos = "eol",
				delay = 500,
				ignore_whitespace = false,
			},

			preview_config = {
				border = "rounded",
				style = "minimal",
				relative = "cursor",
				row = 0,
				col = 1,
			},
		})

		-- Keymaps
		vim.keymap.set("n", "]c", function()
			if vim.wo.diff then
				vim.cmd.normal({ "]c", bang = true })
			else
				gitsigns.nav_hunk("next")
			end
		end, { desc = "Next Git Hunk" })

		vim.keymap.set("n", "[c", function()
			if vim.wo.diff then
				vim.cmd.normal({ "[c", bang = true })
			else
				gitsigns.nav_hunk("prev")
			end
		end, { desc = "Previous Git Hunk" })

		vim.keymap.set("n", "<leader>gp", gitsigns.preview_hunk, { desc = "Preview Hunk" })

		vim.keymap.set("n", "<leader>gr", gitsigns.reset_hunk, { desc = "Reset Hunk" })

		vim.keymap.set("n", "<leader>gR", gitsigns.reset_buffer, { desc = "Reset Buffer" })

		vim.keymap.set("n", "<leader>gs", gitsigns.stage_hunk, { desc = "Stage Hunk" })

		vim.keymap.set("n", "<leader>gu", gitsigns.undo_stage_hunk, { desc = "Undo Stage Hunk" })

		vim.keymap.set("n", "<leader>gb", gitsigns.blame_line, { desc = "Blame Line" })

		vim.keymap.set("n", "<leader>gB", function()
			gitsigns.toggle_current_line_blame()
		end, { desc = "Toggle Line Blame" })

		vim.keymap.set("n", "<leader>gd", gitsigns.diffthis, { desc = "Git Diff This" })

		vim.keymap.set("n", "<leader>gD", function()
			gitsigns.diffthis("~")
		end, { desc = "Git Diff Against ~" })

		vim.keymap.set("n", "<leader>gt", gitsigns.toggle_deleted, { desc = "Toggle Deleted" })
	end,
}
