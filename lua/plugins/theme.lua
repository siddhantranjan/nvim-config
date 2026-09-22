-- ================================================================================================
-- TITLE : colorscheme
-- ABOUT :
--   kanagawa (dragon) with a transparent background.
-- NOTE  :
--   The Telescope* and NvimTree* highlight groups in nvim-transparent's extra_groups were
--   left over from a previous setup -- this config uses fzf-lua and oil. Replaced with the
--   groups that actually exist here (fzf-lua, dropbar, mini.notify, which-key, trouble).
--
--   kanagawa's `compile = true` caches the compiled colorscheme; run `:KanagawaCompile`
--   after changing anything in `overrides`.
-- LINKS :
--   > kanagawa        : https://github.com/rebelot/kanagawa.nvim
--   > nvim-transparent: https://github.com/xiyaowong/transparent.nvim
-- ================================================================================================

return {
	{
		"xiyaowong/transparent.nvim",
		lazy = false,
		priority = 1000,
		opts = {
			extra_groups = {
				"NormalFloat",
				"FloatBorder",
				"FloatTitle",

				-- fzf-lua
				"FzfLuaNormal",
				"FzfLuaBorder",
				"FzfLuaTitle",
				"FzfLuaPreviewNormal",
				"FzfLuaPreviewBorder",

				-- dropbar (winbar)
				"WinBar",
				"WinBarNC",
				"DropBarMenuNormalFloat",
				"DropBarMenuFloatBorder",

				-- which-key
				"WhichKeyNormal",
				"WhichKeyBorder",

				-- mini.notify
				"MiniNotifyNormal",
				"MiniNotifyBorder",

				-- lspsaga
				"SagaNormal",
				"SagaBorder",

				-- diagnostics / completion popups
				"Pmenu",
				"NormalSB",
				"SignColumn",
			},

			exclude_groups = {
				-- Keep these opaque or they become unreadable over terminal wallpaper.
				"CursorLine",
				"Visual",
			},
		},
	},

	{
		"rebelot/kanagawa.nvim",
		lazy = false,
		priority = 999,

		opts = {
			compile = true,
			transparent = true,
			dimInactive = true,
			terminalColors = true,

			theme = "dragon",

			colors = {
				theme = {
					dragon = {
						ui = { bg_gutter = "none" },
					},
				},
			},

			overrides = function(colors)
				local theme = colors.theme

				return {
					NormalFloat = { bg = "NONE" },
					FloatBorder = { bg = "NONE", fg = theme.ui.special },
					FloatTitle = { bg = "NONE", fg = theme.ui.special, bold = true },

					Pmenu = { fg = theme.ui.shade0, bg = "NONE" },
					PmenuSel = { fg = "NONE", bg = theme.ui.bg_p2 },
					PmenuSbar = { bg = theme.ui.bg_m1 },
					PmenuThumb = { bg = theme.ui.bg_p2 },

					CursorLine = { bg = theme.ui.bg_p1 },
					Visual = { bg = theme.ui.bg_p2 },

					-- dropbar: dim the path, make the trailing (current) symbol stand out.
					WinBar = { bg = "NONE", fg = theme.ui.nontext },
					WinBarNC = { bg = "NONE", fg = theme.ui.nontext },
					DropBarIconUISeparator = { fg = theme.ui.nontext },
					DropBarMenuCurrentContext = { bg = theme.ui.bg_p1 },
					DropBarMenuHoverEntry = { bg = theme.ui.bg_p2 },

					-- Make the colorcolumn a hint rather than a wall.
					ColorColumn = { bg = theme.ui.bg_p1 },

					-- gitsigns inline blame should recede.
					GitSignsCurrentLineBlame = { fg = theme.ui.nontext, italic = true },

					-- Diagnostics: underline rather than fill.
					DiagnosticUnderlineError = { undercurl = true, sp = theme.diag.error },
					DiagnosticUnderlineWarn = { undercurl = true, sp = theme.diag.warning },
					DiagnosticUnderlineInfo = { undercurl = true, sp = theme.diag.info },
					DiagnosticUnderlineHint = { undercurl = true, sp = theme.diag.hint },
				}
			end,
		},

		config = function(_, opts)
			require("kanagawa").setup(opts)
			vim.cmd.colorscheme("kanagawa")
		end,
	},
}
