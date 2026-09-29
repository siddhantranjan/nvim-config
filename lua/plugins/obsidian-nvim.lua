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
	init = function()
		-- obsidian.nvim resolves every workspace path during setup() and throws a hard
		-- FileNotFoundError if it doesn't exist -- surfacing as lazy.nvim's "Failed to
		-- run `config` for obsidian.nvim" the moment a markdown file is opened. `init`
		-- runs before the plugin loads regardless of load trigger, so create the vault
		-- folder here rather than requiring it to already exist on every machine.
		vim.fn.mkdir(vim.fn.expand("~/codebase/Notes"), "p")
	end,
	opts = {
		legacy_commands = false,
		workspaces = {
			{
				name = "Notes",
				path = vim.fn.expand("~/codebase/Notes"),
			},
		},
		picker = { name = "fzf-lua" },
		-- NOTE: `nvim_cmp` used to opt into a cmp completion source here; it isn't a
		-- field on the current schema any more (completion is LSP-/blink.cmp-driven
		-- upstream now), so it was silently ignored. min_chars is still honoured.
		completion = {
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
