return {
	"lewis6991/gitsigns.nvim",

	event = { "BufReadPre", "BufNewFile" },

	config = function()
		local gs = require("gitsigns")

		gs.setup({
			signs = {
				add = { text = "│" },
				change = { text = "│" },
				delete = { text = "_" },
				topdelete = { text = "‾" },
				changedelete = { text = "~" },
				untracked = { text = "┆" },
			},

			signs_staged_enable = true,

			signcolumn = true,
			numhl = false,
			linehl = false,
			word_diff = false,

			watch_gitdir = {
				follow_files = true,
			},

			auto_attach = true,
			attach_to_untracked = true,

			-- GitLens-style blame
			current_line_blame = true,

			current_line_blame_opts = {
				virt_text = true,
				virt_text_pos = "eol",
				delay = 300,
				ignore_whitespace = false,
				virt_text_priority = 100,
				use_focus = true,
			},

			current_line_blame_formatter = "  <author> • <author_time:%R> • <summary>",

			preview_config = {
				border = "rounded",
				style = "minimal",
				relative = "cursor",
				row = 0,
				col = 1,
			},

			on_attach = function(bufnr)
				local function map(mode, lhs, rhs, desc)
					vim.keymap.set(mode, lhs, rhs, {
						buffer = bufnr,
						desc = desc,
					})
				end

				-- Navigation
				map("n", "]c", function()
					if vim.wo.diff then
						vim.cmd.normal({ "]c", bang = true })
					else
						gs.nav_hunk("next")
					end
				end, "Next Git Hunk")

				map("n", "[c", function()
					if vim.wo.diff then
						vim.cmd.normal({ "[c", bang = true })
					else
						gs.nav_hunk("prev")
					end
				end, "Previous Git Hunk")

				-- Hunk actions
				map("n", "<leader>gp", gs.preview_hunk, "Preview Hunk")

				map("n", "<leader>gs", gs.stage_hunk, "Stage Hunk")
				map("n", "<leader>gu", gs.undo_stage_hunk, "Undo Stage Hunk")

				map("n", "<leader>gr", gs.reset_hunk, "Reset Hunk")
				map("n", "<leader>gR", gs.reset_buffer, "Reset Buffer")

				-- Visual-mode hunk actions
				map("v", "<leader>gs", function()
					gs.stage_hunk({
						vim.fn.line("."),
						vim.fn.line("v"),
					})
				end, "Stage Selected Hunk")

				map("v", "<leader>gr", function()
					gs.reset_hunk({
						vim.fn.line("."),
						vim.fn.line("v"),
					})
				end, "Reset Selected Hunk")

				-- Blame
				map("n", "<leader>gb", function()
					gs.blame_line({
						full = true,
					})
				end, "Blame Line")

				map("n", "<leader>gB", gs.toggle_current_line_blame, "Toggle Line Blame")

				-- Diff
				map("n", "<leader>gd", gs.diffthis, "Diff Current File")

				map("n", "<leader>gD", function()
					gs.diffthis("~")
				end, "Diff Against Previous Commit")

				-- Deleted lines
				map("n", "<leader>gt", gs.toggle_deleted, "Toggle Deleted Lines")
			end,
		})
	end,
}
