-- ================================================================================================
-- TITLE : jsonls (JSON Language Server) LSP Setup
-- ABOUT :
--   Schemas come from SchemaStore.nvim (the schemastore.org catalogue VS Code uses), so
--   package.json, tsconfig.json, .eslintrc, CMakePresets.json and hundreds more get
--   validation, completion and hover docs automatically.
-- LINKS :
--   > github      : https://github.com/microsoft/vscode-json-languageservice
--   > schemastore : https://github.com/b0o/SchemaStore.nvim
-- ================================================================================================

--- @param capabilities table LSP client capabilities (typically from nvim-cmp or similar)
--- @return nil
return function(capabilities)
	local ok, schemastore = pcall(require, "schemastore")

	vim.lsp.config("jsonls", {
		capabilities = capabilities,
		filetypes = { "json", "jsonc" },
		settings = {
			json = {
				schemas = ok and schemastore.json.schemas() or {},
				validate = { enable = true },
			},
		},
	})
end
