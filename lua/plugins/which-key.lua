-- ================================================================================================
-- TITLE : which-key.nvim
-- ABOUT :
--   Shows the available continuations after a prefix key. Previously loaded with bare
--   `opts = {}`, so it listed raw key sequences with no idea what any group meant -- the
--   `spec` below gives every prefix a name and an icon.
--
--   which-key is also the fastest way to spot a shadowed group: if a single-key mapping
--   exists at a prefix, which-key shows it as a command rather than a group, and every key
--   under it stalls for 'timeoutlen'.
-- LINKS :
--   > github : https://github.com/folke/which-key.nvim
-- ================================================================================================

return {
	"folke/which-key.nvim",
	event = "VeryLazy",

	opts = function()
		local icons = require("utils.icons").groups

		return {
			preset = "helix",
			delay = function(ctx)
				return ctx.plugin and 0 or 300
			end,

			win = { border = "rounded" },

			spec = {
				{ "<leader>b", group = "buffer", icon = icons.buffer },
				{ "<leader>c", group = "code / AI", icon = icons.code },
				{ "<leader>d", group = "debug", icon = icons.debug },
				{ "<leader>f", group = "find", icon = icons.find },
				{ "<leader>g", group = "git", icon = icons.git },
				{ "<leader>m", group = "mobile (flutter/xcode)", icon = icons.mobile },
				{ "<leader>n", group = "notes", icon = icons.notes },
				{ "<leader>o", group = "organize", icon = icons.organize },
				{ "<leader>p", group = "paste / path", icon = icons.paste },
				{ "<leader>r", group = "rename / resize / config", icon = icons.rename },
				{ "<leader>s", group = "splits", icon = icons.splits },
				{ "<leader>x", group = "diagnostics", icon = icons.diagnostics },

				-- Standalone keys worth surfacing.
				{ "<leader>h", desc = "Clear search highlights" },
				{ "<leader>k", desc = "Diagnostics under cursor" },
				{ "<leader>K", desc = "Diagnostics for line" },
				{ "<leader>q", desc = "Open Oil" },
				{ "<leader>z", desc = "Toggle Zen Mode" },
				{ "<leader>;", desc = "Winbar: pick symbol" },
				{ "<leader>D", desc = "Delete without yanking" },

				-- Bracket motions.
				{ "[", group = "previous" },
				{ "]", group = "next" },
				{ "g", group = "goto" },
			},
		}
	end,

	keys = {
		{
			"<leader>?",
			function()
				require("which-key").show({ global = false })
			end,
			desc = "Buffer-local keymaps",
		},
		{
			"<leader>fK",
			function()
				require("which-key").show({ global = true })
			end,
			desc = "All keymaps (which-key)",
		},
	},
}
