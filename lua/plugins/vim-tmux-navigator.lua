-- ================================================================================================
-- TITLE : vim-tmux-navigator
-- ABOUT :
--   <C-h/j/k/l> moves between Neovim splits and tmux panes interchangeably.
-- NOTE  :
--   The plugin was previously loaded with no `cmd`/`keys`, so lazy.nvim loaded it eagerly
--   and its mappings were created before this config's own. Declaring the commands and keys
--   lets it load on first use and makes the bindings explicit rather than implicit.
--
--   The matching tmux side is required for pane hand-off to work:
--     set -g @plugin 'christoomey/vim-tmux-navigator'
-- LINKS :
--   > github : https://github.com/christoomey/vim-tmux-navigator
-- ================================================================================================

return {
	"christoomey/vim-tmux-navigator",

	cmd = {
		"TmuxNavigateLeft",
		"TmuxNavigateDown",
		"TmuxNavigateUp",
		"TmuxNavigateRight",
		"TmuxNavigatePrevious",
	},

	keys = {
		{ "<C-h>", "<cmd>TmuxNavigateLeft<cr>", desc = "Window/pane left" },
		{ "<C-j>", "<cmd>TmuxNavigateDown<cr>", desc = "Window/pane down" },
		{ "<C-k>", "<cmd>TmuxNavigateUp<cr>", desc = "Window/pane up" },
		{ "<C-l>", "<cmd>TmuxNavigateRight<cr>", desc = "Window/pane right" },
		{ "<C-\\>", "<cmd>TmuxNavigatePrevious<cr>", desc = "Window/pane previous" },
	},
}
