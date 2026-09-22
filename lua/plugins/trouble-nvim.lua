-- ================================================================================================
-- TITLE : trouble.nvim
-- ABOUT : Pretty, navigable list for diagnostics, references, quickfix and location lists.
-- NOTE  : The <leader>x… group used to be shadowed by a bare <leader>x mapping
--         (delete-without-yanking, now on <leader>D), which made every key here wait out
--         'timeoutlen' before firing.
-- LINKS :
--   > github : https://github.com/folke/trouble.nvim
-- ================================================================================================

return {
	"folke/trouble.nvim",
	cmd = "Trouble",

	opts = {
		focus = true,
		win = { border = "rounded" },
		modes = {
			diagnostics = {
				auto_open = false,
				auto_close = false,
			},
		},
	},

	keys = {
		{ "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>", desc = "Diagnostics (workspace)" },
		{ "<leader>xX", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>", desc = "Diagnostics (buffer)" },
		{ "<leader>xL", "<cmd>Trouble loclist toggle<cr>", desc = "Location list" },
		{ "<leader>xQ", "<cmd>Trouble qflist toggle<cr>", desc = "Quickfix list" },
		{ "<leader>xt", "<cmd>Trouble todo toggle<cr>", desc = "Todo comments" },
		{ "<leader>cs", "<cmd>Trouble symbols toggle focus=false<cr>", desc = "Symbols (Trouble)" },
		{
			"<leader>cl",
			"<cmd>Trouble lsp toggle focus=false win.position=right<cr>",
			desc = "LSP definitions / references (Trouble)",
		},
	},
}
