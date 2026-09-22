-- ================================================================================================
-- TITLE : zen-mode.nvim
-- ABOUT : Distraction-free editing. twilight.nvim dims everything outside the current scope.
-- LINKS :
--   > github   : https://github.com/folke/zen-mode.nvim
--   > twilight : https://github.com/folke/twilight.nvim
-- ================================================================================================

return {
	"folke/zen-mode.nvim",
	cmd = "ZenMode",
	dependencies = {
		{ "folke/twilight.nvim", cmd = { "Twilight", "TwilightEnable" }, opts = {} },
	},

	keys = {
		{ "<leader>z", "<cmd>ZenMode<cr>", desc = "Toggle Zen Mode" },
	},

	opts = {
		window = {
			backdrop = 1,
			width = 0.60,
			options = {
				number = false,
				relativenumber = false,
				signcolumn = "no",
				cursorline = false,
				foldcolumn = "0",
			},
		},

		plugins = {
			options = { enabled = true, ruler = false, showcmd = false, laststatus = 0 },
			gitsigns = { enabled = false },
			tmux = { enabled = false },
			kitty = { enabled = false, font = "+2" },
			twilight = { enabled = true },
		},

		on_open = function()
			-- dropbar's winbar is a distraction in Zen mode; remember and restore it.
			vim.b.zen_saved_winbar = vim.wo.winbar
			vim.wo.winbar = ""
		end,

		on_close = function()
			if vim.b.zen_saved_winbar ~= nil then
				vim.wo.winbar = vim.b.zen_saved_winbar
				vim.b.zen_saved_winbar = nil
			end
		end,
	},
}
