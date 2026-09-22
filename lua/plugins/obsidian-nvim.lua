-- ================================================================================================
-- TITLE : obsidian.nvim
-- ABOUT : Obsidian vault integration -- notes, daily notes, backlinks, wiki links.
-- LINKS :
--   > github : https://github.com/obsidian-nvim/obsidian.nvim
-- ================================================================================================

return {
	"obsidian-nvim/obsidian.nvim",
	version = "*",
	ft = "markdown",
	dependencies = {
		"nvim-lua/plenary.nvim",
	},
	opts = {
		legacy_commands = false,
		workspaces = {
			{
				name = "Notes",
				path = vim.fn.expand("~/codebase/Notes"),
			},
		},
		picker = { name = "fzf-lua" },
		completion = {
			nvim_cmp = true,
			min_chars = 2,
		},
		ui = { enable = true },
	},
	keys = {
		{ "<leader>nn", "<cmd>Obsidian new<cr>", desc = "New note" },
		{ "<leader>nf", "<cmd>Obsidian quick_switch<cr>", desc = "Find note" },
		{ "<leader>ns", "<cmd>Obsidian search<cr>", desc = "Search notes" },
		{ "<leader>nt", "<cmd>Obsidian today<cr>", desc = "Today's daily note" },
		{ "<leader>ny", "<cmd>Obsidian yesterday<cr>", desc = "Yesterday's daily note" },
		{ "<leader>nb", "<cmd>Obsidian backlinks<cr>", desc = "Backlinks" },
		{ "<leader>nl", "<cmd>Obsidian links<cr>", desc = "Links in note" },
		{ "<leader>nT", "<cmd>Obsidian template<cr>", desc = "Insert template" },
	},
}
