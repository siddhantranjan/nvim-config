-- ================================================================================================
-- TITLE : vim-fugitive
-- ABOUT : Full Git porcelain inside Neovim -- staging, committing, blame, log, :Git anything.
-- NOTE  : Hunk-level work is faster in gitsigns (<leader>gs / <leader>gr); fugitive covers
--         the commit-level operations gitsigns doesn't do.
-- LINKS :
--   > github : https://github.com/tpope/vim-fugitive
-- ================================================================================================

return {
	"tpope/vim-fugitive",
	cmd = { "Git", "G", "Gdiffsplit", "Gvdiffsplit", "Gread", "Gwrite", "Gedit", "GBrowse" },

	keys = {
		{ "<leader>gg", "<cmd>Git<cr>", desc = "Git status (fugitive)" },
		{ "<leader>gm", "<cmd>Git commit<cr>", desc = "Git commit" },
		{ "<leader>gA", "<cmd>Git commit --amend<cr>", desc = "Git commit --amend" },
		{ "<leader>gk", "<cmd>Git push<cr>", desc = "Git push" },
		{ "<leader>gj", "<cmd>Git pull --rebase<cr>", desc = "Git pull --rebase" },
		{ "<leader>gL", "<cmd>Git log --oneline --graph --decorate<cr>", desc = "Git log (graph)" },
		{ "<leader>ge", "<cmd>Gedit<cr>", desc = "Git edit (restore from index)" },
	},
}
