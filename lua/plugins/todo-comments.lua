-- ================================================================================================
-- TITLE : todo-comments.nvim
-- ABOUT :
--   Highlights TODO / FIXME / HACK / NOTE / WARN / PERF comments and makes them searchable.
--   Added because trouble.nvim's <leader>xt mode and the <leader>ft picker both depend on
--   it, and because a config this size accumulates notes-to-self that are otherwise
--   invisible.
-- LINKS :
--   > github : https://github.com/folke/todo-comments.nvim
-- ================================================================================================

return {
	"folke/todo-comments.nvim",
	event = { "BufReadPost", "BufNewFile" },
	dependencies = { "nvim-lua/plenary.nvim" },

	opts = {
		signs = true,
		sign_priority = 8,
		highlight = {
			multiline = false,
			keyword = "wide",
			after = "fg",
		},
	},

	keys = {
		-- <leader>ft is LSP type-definitions (buffer-local, utils/lsp.lua), hence the capital.
		{ "<leader>fT", "<cmd>TodoFzfLua<cr>", desc = "Todo comments" },
		{
			"]t",
			function()
				require("todo-comments").jump_next()
			end,
			desc = "Next todo comment",
		},
		{
			"[t",
			function()
				require("todo-comments").jump_prev()
			end,
			desc = "Previous todo comment",
		},
	},
}
