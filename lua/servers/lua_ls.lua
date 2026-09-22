-- ================================================================================================
-- TITLE : lua_ls (Lua Language Server) LSP Setup
-- LINKS :
--   > github: https://github.com/LuaLS/lua-language-server
-- ================================================================================================

--- @param capabilities table LSP client capabilities (typically from nvim-cmp or similar)
--- @return nil
return function(capabilities)
	vim.lsp.config("lua_ls", {
		capabilities = capabilities,
		filetypes = { "lua" },
		root_markers = { ".luarc.json", ".luarc.jsonc", ".stylua.toml", "stylua.toml", ".git" },
		settings = {
			Lua = {
				runtime = {
					version = "LuaJIT",
					path = { "lua/?.lua", "lua/?/init.lua" },
				},
				diagnostics = {
					globals = { "vim" },
				},
				workspace = {
					-- Neovim runtime + this config's own lua/ dir, so `vim.*` and local
					-- `require("config.x")` calls resolve. stdpath("config") is correct
					-- regardless of whether XDG_CONFIG_HOME is set.
					library = {
						vim.env.VIMRUNTIME .. "/lua",
						vim.fn.stdpath("config") .. "/lua",
						vim.fn.stdpath("data") .. "/lazy/lazy.nvim/lua",
					},
					checkThirdParty = false,
				},
				telemetry = { enable = false },
				hint = { enable = true },
				format = { enable = false }, -- stylua owns formatting
			},
		},
	})
end
