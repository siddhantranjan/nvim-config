-- ================================================================================================
-- TITLE : conform.nvim
-- ABOUT :
--   The single owner of formatting in this config. efm-langserver is configured as a
--   LINTER-ONLY server (documentFormatting = false) so a buffer is never formatted twice by
--   two tools with different settings.
--
--   Anything without an entry below falls through to `lsp_format = "fallback"`, i.e. the
--   attached language server formats it (dartls for Dart, sourcekit for Swift, etc.).
-- LINKS :
--   > github : https://github.com/stevearc/conform.nvim
-- ================================================================================================

return {
	"stevearc/conform.nvim",
	event = { "BufWritePre" },
	cmd = { "ConformInfo" },

	keys = {
		{
			"<leader>cF",
			function()
				require("conform").format({ async = true, lsp_format = "fallback" })
			end,
			mode = { "n", "v" },
			desc = "Format buffer / selection",
		},
		{
			"<leader>ct",
			function()
				vim.g.disable_autoformat = not vim.g.disable_autoformat
				vim.notify(
					"Format on save " .. (vim.g.disable_autoformat and "DISABLED" or "ENABLED"),
					vim.log.levels.INFO
				)
			end,
			desc = "Toggle format on save",
		},
	},

	opts = {
		formatters_by_ft = {
			-- Conform runs a list sequentially; `stop_after_first` makes it pick the
			-- first available instead.
			bash = { "shfmt" },
			c = { "clang_format" },
			cpp = { "clang_format" },
			css = { "prettierd", "prettier", stop_after_first = true },
			dart = { "dart_format" },
			go = { "goimports", "gofumpt" },
			html = { "prettierd", "prettier", stop_after_first = true },
			javascript = { "prettierd", "prettier", stop_after_first = true },
			javascriptreact = { "prettierd", "prettier", stop_after_first = true },
			json = { "prettierd", "prettier", "jq", stop_after_first = true },
			jsonc = { "prettierd", "prettier", stop_after_first = true },
			lua = { "stylua" },
			markdown = { "prettierd", "prettier", stop_after_first = true },
			python = { "isort", "black" },
			ruby = { "rubocop" },
			rust = { "rustfmt" },
			sh = { "shfmt" },
			solidity = { "prettierd", "prettier", stop_after_first = true },
			svelte = { "prettierd", "prettier", stop_after_first = true },
			toml = { "taplo" },
			typescript = { "prettierd", "prettier", stop_after_first = true },
			typescriptreact = { "prettierd", "prettier", stop_after_first = true },
			vue = { "prettierd", "prettier", stop_after_first = true },
			yaml = { "prettierd", "prettier", stop_after_first = true },

			-- Strip trailing whitespace + fix final newline in every other filetype.
			-- This replaces the old BufWritePre autocmd that called mini.trailspace
			-- unconditionally, including in buffers the user never intended to reformat.
			["_"] = { "trim_whitespace", "trim_newlines" },
		},

		format_on_save = function(bufnr)
			-- Escape hatches: <leader>ct toggles globally, or set b:disable_autoformat
			-- for one buffer.
			if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then
				return
			end

			-- Don't reformat files that aren't ours to reformat.
			local path = vim.api.nvim_buf_get_name(bufnr)
			for _, pattern in ipairs({ "/node_modules/", "/vendor/", "/%.git/", "/target/", "/build/" }) do
				if path:find(pattern) then
					return
				end
			end

			return { timeout_ms = 5000, lsp_format = "fallback" }
		end,

		formatters = {
			shfmt = {
				prepend_args = { "-i", "2", "-ci" },
			},
			stylua = {
				-- Fall back to this config's own style when a project has no
				-- stylua.toml of its own.
				prepend_args = function(_, ctx)
					if
						vim.fs.find({ ".stylua.toml", "stylua.toml" }, {
							upward = true,
							path = ctx.dirname,
						})[1]
					then
						return {}
					end
					return { "--indent-type", "Tabs", "--column-width", "100" }
				end,
			},
		},
	},

	init = function()
		-- Make `gq` use conform, so the operator works on motions and ranges.
		vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"
		vim.g.disable_autoformat = false
	end,
}
