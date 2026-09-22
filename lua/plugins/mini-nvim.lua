-- ================================================================================================
-- TITLE : mini.nvim
-- ABOUT : Library of independent Lua modules, installed individually rather than as a bundle.
-- NOTE  : mini.trailspace was listed twice in this file; lazy.nvim deduplicates, but the
--         second entry's opts silently won. Each module appears exactly once now.
-- LINKS :
--   > github : https://github.com/nvim-mini/mini.nvim
-- ================================================================================================

return {
	-- ── Text objects & editing ──────────────────────────────────────────────────────────
	{
		"nvim-mini/mini.ai",
		version = "*",
		event = "VeryLazy",
		opts = function()
			local ai = require("mini.ai")
			return {
				n_lines = 500,
				custom_textobjects = {
					-- `af`/`ac` come from nvim-treesitter-textobjects; `ao`/`io`
					-- covers blocks, conditionals and loops here so that neither
					-- plugin needs to claim `al`/`il` (mini.ai's own "last"
					-- textobject) or `aa`/`ia` (mini.ai's own "argument").
					o = ai.gen_spec.treesitter({
						a = { "@block.outer", "@conditional.outer", "@loop.outer" },
						i = { "@block.inner", "@conditional.inner", "@loop.inner" },
					}),
					d = { "%f[%d]%d+" }, -- digits
					e = { -- sub-word: camelCase / snake_case segments
						{
							"%u[%l%d]+%f[^%l%d]",
							"%f[%S][%l%d]+%f[^%l%d]",
							"%f[%P][%l%d]+%f[^%l%d]",
							"^[%l%d]+%f[^%l%d]",
						},
						"^().*()$",
					},
				},
			}
		end,
	},

	{ "nvim-mini/mini.comment", version = "*", event = "VeryLazy", opts = {} },
	{ "nvim-mini/mini.surround", version = "*", event = "VeryLazy", opts = {} },
	{ "nvim-mini/mini.pairs", version = "*", event = "InsertEnter", opts = {} },

	-- Owns <M-h/j/k/l> (== <A-h/j/k/l>) for moving lines and selections in both normal
	-- and visual mode. config/keymaps.lua deliberately defines no <A-j>/<A-k>.
	{
		"nvim-mini/mini.move",
		version = "*",
		event = "VeryLazy",
		opts = {
			mappings = {
				left = "<M-h>",
				right = "<M-l>",
				down = "<M-j>",
				up = "<M-k>",
				line_left = "<M-h>",
				line_right = "<M-l>",
				line_down = "<M-j>",
				line_up = "<M-k>",
			},
		},
	},

	-- ── Visual aids ─────────────────────────────────────────────────────────────────────
	{ "nvim-mini/mini.cursorword", version = "*", event = "VeryLazy", opts = { delay = 250 } },

	{
		"nvim-mini/mini.indentscope",
		version = "*",
		event = { "BufReadPre", "BufNewFile" },
		opts = function()
			return {
				symbol = "│",
				options = { try_as_border = true },
				draw = {
					delay = 50,
					animation = require("mini.indentscope").gen_animation.none(),
				},
			}
		end,
		init = function()
			-- The scope line is noise in these buffers.
			vim.api.nvim_create_autocmd("FileType", {
				pattern = {
					"Trouble",
					"alpha",
					"checkhealth",
					"dashboard",
					"help",
					"lazy",
					"mason",
					"markdown",
					"notify",
					"oil",
					"toggleterm",
					"trouble",
				},
				callback = function()
					vim.b.miniindentscope_disable = true
				end,
			})
		end,
	},

	-- ── Buffer & whitespace utilities ───────────────────────────────────────────────────
	{ "nvim-mini/mini.bufremove", version = "*", lazy = true, opts = {} },

	{
		"nvim-mini/mini.trailspace",
		version = "*",
		event = { "BufReadPost", "BufNewFile" },
		opts = {},
		config = function(_, opts)
			require("mini.trailspace").setup(opts)

			vim.keymap.set("n", "<leader>cw", function()
				require("mini.trailspace").trim()
				require("mini.trailspace").trim_last_lines()
			end, { desc = "Trim trailing whitespace" })
		end,
	},

	-- ── Notifications ───────────────────────────────────────────────────────────────────
	{
		"nvim-mini/mini.notify",
		version = "*",
		event = "VeryLazy",
		config = function()
			local notify = require("mini.notify")

			notify.setup({
				window = {
					config = { border = "rounded" },
					winblend = 0,
				},
				lsp_progress = { enable = true },
			})

			-- This is the line that was missing: installing mini.notify does nothing
			-- on its own. vim.notify has to be pointed at it explicitly, otherwise
			-- every notification still goes to the built-in message area.
			vim.notify = notify.make_notify({
				ERROR = { duration = 5000 },
				WARN = { duration = 4000 },
				INFO = { duration = 2500 },
			})

			vim.keymap.set("n", "<leader>fn", function()
				notify.show_history()
			end, { desc = "Notification history" })
		end,
	},

	-- ── Icons ───────────────────────────────────────────────────────────────────────────
	{
		"nvim-mini/mini.icons",
		version = "*",
		lazy = true,
		opts = {},
		init = function()
			-- Several plugins here (fzf-lua, lualine, dropbar, trouble) request
			-- nvim-web-devicons directly. Mocking lets mini.icons answer those calls
			-- so there is one icon set instead of two slightly different ones.
			package.preload["nvim-web-devicons"] = function()
				require("mini.icons").mock_nvim_web_devicons()
				return package.loaded["nvim-web-devicons"]
			end
		end,
	},
}
