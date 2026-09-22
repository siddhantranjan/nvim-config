-- ================================================================================================
-- TITLE : gitsigns.nvim
-- ABOUT : Hunk signs in the gutter, inline blame, and hunk staging/resetting.
-- NOTE  :
--   <leader>gd and <leader>gD used to be mapped here AND in the LSP on_attach (as peek/goto
--   definition). Both were buffer-local, so on a buffer with an LSP attached the git
--   mappings were silently replaced. LSP navigation now lives on the standard `g` motions
--   (gd / gD / gy / gO), leaving the whole <leader>g… namespace to git.
-- LINKS :
--   > github : https://github.com/lewis6991/gitsigns.nvim
-- ================================================================================================

return {
	"lewis6991/gitsigns.nvim",
	event = { "BufReadPre", "BufNewFile" },

	config = function()
		local gs = require("gitsigns")
		local signs = require("utils.icons").signs

		gs.setup({
			signs = {
				add = { text = signs.gutter },
				change = { text = signs.gutter },
				delete = { text = signs.delete },
				topdelete = { text = signs.topdelete },
				changedelete = { text = signs.changedelete },
				untracked = { text = signs.gutter_dashed },
			},

			signs_staged_enable = true,
			signcolumn = true,
			numhl = false,
			linehl = false,
			word_diff = false,

			watch_gitdir = { follow_files = true },
			auto_attach = true,
			attach_to_untracked = true,

			-- GitLens-style inline blame at end of line.
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
					vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc })
				end

				-- ── Navigation ──────────────────────────────────────────────────
				map("n", "]c", function()
					if vim.wo.diff then
						vim.cmd.normal({ "]c", bang = true })
					else
						gs.nav_hunk("next")
					end
				end, "Next git hunk")

				map("n", "[c", function()
					if vim.wo.diff then
						vim.cmd.normal({ "[c", bang = true })
					else
						gs.nav_hunk("prev")
					end
				end, "Previous git hunk")

				-- ── Hunk actions ────────────────────────────────────────────────
				map("n", "<leader>gp", gs.preview_hunk, "Preview hunk")
				map("n", "<leader>gP", gs.preview_hunk_inline, "Preview hunk inline")
				-- `stage_hunk` toggles: on a staged sign it unstages. That replaces
				-- `undo_stage_hunk`, which gitsigns has deprecated (as it has
				-- `toggle_deleted`, whose job `preview_hunk_inline` now does).
				map("n", "<leader>gs", gs.stage_hunk, "Stage / unstage hunk")
				map("n", "<leader>gr", gs.reset_hunk, "Reset hunk")
				map("n", "<leader>gS", gs.stage_buffer, "Stage buffer")
				map("n", "<leader>gR", gs.reset_buffer, "Reset buffer")

				map("v", "<leader>gs", function()
					gs.stage_hunk({ vim.fn.line("."), vim.fn.line("v") })
				end, "Stage selected hunk")

				map("v", "<leader>gr", function()
					gs.reset_hunk({ vim.fn.line("."), vim.fn.line("v") })
				end, "Reset selected hunk")

				-- ── Blame ───────────────────────────────────────────────────────
				map("n", "<leader>gb", function()
					gs.blame_line({ full = true })
				end, "Blame line (full)")

				map("n", "<leader>gB", gs.toggle_current_line_blame, "Toggle inline blame")

				-- ── Diff ────────────────────────────────────────────────────────
				map("n", "<leader>gd", gs.diffthis, "Diff this file")

				map("n", "<leader>gD", function()
					gs.diffthis("~")
				end, "Diff against previous commit")

				-- ── Text object ─────────────────────────────────────────────────
				-- `dih` deletes the hunk under the cursor, `vih` selects it.
				map({ "o", "x" }, "ih", gs.select_hunk, "Select git hunk")
			end,
		})
	end,
}
