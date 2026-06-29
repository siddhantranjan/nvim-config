-- ================================================================================================
-- TITLE : melange-nvim
-- ABOUT : A subtle, warm colorscheme for Neovim inspired by Sublime Text's Melange theme.
-- LINKS :
--   > github : https://github.com/savq/melange-nvim
-- ================================================================================================

return {
	{
		"xiyaowong/nvim-transparent",
		lazy = false,
		priority = 1000,
		opts = {
			extra_groups = {
				"NormalFloat",
				"FloatBorder",
				"TelescopeNormal",
				"TelescopeBorder",
				"TelescopePromptNormal",
				"TelescopePromptBorder",
				"NvimTreeNormal",
				"NvimTreeNormalNC",
				"NvimTreeEndOfBuffer",
				"NvimTreeSignColumn",
				"NvimTreeWinSeparator",
			},
		},
	},

	{
		"rebelot/kanagawa.nvim",
		lazy = false,
		priority = 999,
		config = function()
			require("kanagawa").setup({
				compile = true,
				transparent = true,
				dimInactive = true,

				theme = "dragon",

				colors = {
					theme = {
						dragon = {
							ui = {
								bg_gutter = "none",
							},
						},
					},
				},

				overrides = function(colors)
					local theme = colors.theme

					return {
						NormalFloat = { bg = "NONE" },
						FloatBorder = {
							bg = "NONE",
							fg = theme.ui.special,
						},

						Pmenu = {
							fg = theme.ui.shade0,
							bg = "NONE",
						},

						PmenuSel = {
							fg = "NONE",
							bg = theme.ui.bg_p2,
						},

						CursorLine = {
							bg = theme.ui.bg_p1,
						},

						Visual = {
							bg = theme.ui.bg_p2,
						},

						TelescopeTitle = {
							fg = theme.ui.special,
							bold = true,
						},
					}
				end,
			})

			vim.cmd.colorscheme("kanagawa")
		end,
	},
}
