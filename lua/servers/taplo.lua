-- ================================================================================================
-- TITLE : taplo (TOML Language Server) LSP Setup
-- ABOUT :
--   Validation, completion and hover docs for TOML. Cargo.toml is matched to its schema
--   automatically through the schemastore.org catalogue, so unknown keys, typos in
--   [profile.release] and wrong value types are flagged as you type. Dependency *versions*
--   are crates.nvim's job (lua/plugins/crates.lua).
--
--   Formatting stays with conform.nvim (taplo the CLI, same binary).
-- LINKS :
--   > github : https://github.com/tamasfe/taplo
-- ================================================================================================

--- @param capabilities table LSP client capabilities (typically from nvim-cmp or similar)
--- @return nil
return function(capabilities)
	vim.lsp.config("taplo", {
		capabilities = capabilities,
		settings = {
			evenBetterToml = {
				schema = { enabled = true },
			},
		},
	})
end
