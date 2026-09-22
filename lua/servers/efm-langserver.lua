-- ================================================================================================
-- TITLE : efm-langserver
-- ABOUT :
--   General purpose language server, used here as a LINTER-ONLY bridge. Formatting is owned
--   entirely by conform.nvim (see lua/plugins/conform.lua) so that a file is never formatted
--   twice by two different tools with two different configs.
-- LINKS :
--   > github  : https://github.com/mattn/efm-langserver
--   > configs : https://github.com/creativenull/efmls-configs-nvim/tree/main
-- ================================================================================================

--- @param capabilities table LSP client capabilities (from nvim-cmp)
--- @return nil
return function(capabilities)
	local luacheck = require("efmls-configs.linters.luacheck") -- lua
	local flake8 = require("efmls-configs.linters.flake8") -- python
	local go_revive = require("efmls-configs.linters.go_revive") -- go
	local eslint_d = require("efmls-configs.linters.eslint_d") -- js/ts/react/svelte/vue
	local shellcheck = require("efmls-configs.linters.shellcheck") -- bash
	local hadolint = require("efmls-configs.linters.hadolint") -- docker
	local cpplint = require("efmls-configs.linters.cpplint") -- c/cpp
	local solhint = require("efmls-configs.linters.solhint") -- solidity
	local rubocop = require("efmls-configs.linters.rubocop") -- ruby

	-- NOTE: keys below are Neovim FILETYPES, not language names. `dockerfile` (not `docker`)
	-- is the filetype Neovim assigns to a Dockerfile -- getting this wrong silently disables
	-- the linter with no error message.
	local languages = {
		c = { cpplint },
		cpp = { cpplint },
		dockerfile = { hadolint },
		go = { go_revive },
		javascript = { eslint_d },
		javascriptreact = { eslint_d },
		lua = { luacheck },
		python = { flake8 },
		ruby = { rubocop },
		sh = { shellcheck },
		bash = { shellcheck },
		solidity = { solhint },
		svelte = { eslint_d },
		typescript = { eslint_d },
		typescriptreact = { eslint_d },
		vue = { eslint_d },
	}

	vim.lsp.config("efm", {
		capabilities = capabilities,
		filetypes = vim.tbl_keys(languages),
		init_options = {
			documentFormatting = false, -- conform.nvim owns formatting
			documentRangeFormatting = false,
			hover = false,
			documentSymbol = false,
			codeAction = true,
			completion = false,
		},
		settings = {
			rootMarkers = { ".git/" },
			languages = languages,
		},
	})
end
