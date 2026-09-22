-- ================================================================================================
-- TITLE : ccc.nvim
-- ABOUT : Colour picker and inline colour highlighter.
-- LINKS :
--   > github : https://github.com/uga-rosa/ccc.nvim
-- ================================================================================================

return {
	"uga-rosa/ccc.nvim",
	cmd = { "CccPick", "CccConvert", "CccHighlighterToggle" },
	ft = { "css", "scss", "sass", "html", "javascript", "typescript", "javascriptreact", "typescriptreact", "lua", "dart", "svelte", "vue" },

	keys = {
		{ "<leader>cP", "<cmd>CccPick<cr>", desc = "Pick colour" },
		{ "<leader>cH", "<cmd>CccHighlighterToggle<cr>", desc = "Toggle colour highlighting" },
	},

	opts = function()
		return {
			highlighter = {
				auto_enable = true,
				lsp = true, -- also render colours reported by the language server
				max_byte = 512 * 1024, -- skip enormous files
			},
			highlight_mode = "virtual", -- a swatch beside the value, not a background fill
			virtual_symbol = require("utils.icons").misc.colour,
		}
	end,
}
