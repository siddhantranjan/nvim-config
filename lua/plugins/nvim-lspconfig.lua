-- ================================================================================================
-- TITLE : nvim-lspconfig
-- ABOUT :
--   Quickstart configurations for the built-in Neovim LSP client, plus Mason to install the
--   actual binaries. Server settings live in lua/servers/ -- this file only bootstraps.
-- NOTES :
--   nvim-lspconfig has NO `opts` handling of its own (that's a LazyVim feature). Passing
--   `opts = { servers = ... }` here does nothing at all. Server config belongs in
--   lua/servers/<name>.lua.
-- LINKS :
--   > github                     : https://github.com/neovim/nvim-lspconfig
--   > mason.nvim (dep)           : https://github.com/mason-org/mason.nvim
--   > mason-tool-installer (dep) : https://github.com/WhoIsSethDaniel/mason-tool-installer.nvim
--   > efmls-configs-nvim (dep)   : https://github.com/creativenull/efmls-configs-nvim
-- ================================================================================================

return {
	"neovim/nvim-lspconfig",
	lazy = false,
	priority = 400,
	dependencies = {
		{
			"mason-org/mason.nvim",
			opts = function()
				local glyphs = require("utils.icons").mason

				return {
					ui = {
						border = "rounded",
						icons = {
							package_installed = glyphs.installed,
							package_pending = glyphs.pending,
							package_uninstalled = glyphs.uninstalled,
						},
					},
				}
			end,
		},

		{
			"WhoIsSethDaniel/mason-tool-installer.nvim",
			dependencies = { "mason-org/mason.nvim" },
			opts = {
				-- Everything referenced anywhere in this config: LSP servers, the linters
				-- efm shells out to, the formatters conform shells out to, and the debug
				-- adapter nvim-dap expects at ~/.local/share/nvim/mason/bin/codelldb.
				ensure_installed = {
					-- Language servers
					"bash-language-server",
					"clangd",
					"css-lsp",
					"dockerfile-language-server",
					"emmet-ls",
					"gopls",
					"html-lsp",
					"json-lsp",
					"lua-language-server",
					"nomicfoundation-solidity-language-server",
					"pyright",
					"tailwindcss-language-server",
					"typescript-language-server",
					"yaml-language-server",

					-- Linter bridge
					"efm",

					-- Linters
					"cpplint",
					"eslint_d",
					"flake8",
					"hadolint",
					"luacheck",
					"revive",
					"rubocop",
					"shellcheck",
					"solhint",

					-- Formatters
					"black",
					"clang-format",
					"gofumpt",
					"goimports",
					"isort",
					"jq",
					"prettierd",
					"shfmt",
					"stylua",
					"taplo",

					-- Debug adapters
					"codelldb",
				},
				run_on_start = true,
				start_delay = 2000, -- let the UI settle before downloading
				debounce_hours = 24, -- don't re-check on every single launch
			},
		},

		"creativenull/efmls-configs-nvim", -- preconfigured efm linter definitions
		"hrsh7th/cmp-nvim-lsp", -- completion capabilities
	},

	config = function()
		require("utils.diagnostics").setup()
		require("servers")
	end,
}
