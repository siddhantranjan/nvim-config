-- ================================================================================================
-- TITLE : yamlls (YAML Language Server) LSP Setup
-- ABOUT :
--   Schemas come from SchemaStore.nvim (GitHub workflows, docker-compose, pre-commit,
--   .gitlab-ci.yml and hundreds more). yamlls' own built-in SchemaStore fetch is
--   switched off so the two don't fight -- `url = ""` is required as well, or yamlls throws a
--   TypeError trying to download the catalogue anyway.
-- LINKS :
--   > github      : https://github.com/redhat-developer/yaml-language-server
--   > schemastore : https://github.com/b0o/SchemaStore.nvim
-- ================================================================================================

--- @param capabilities table LSP client capabilities (typically from nvim-cmp or similar)
--- @return nil
return function(capabilities)
	local ok, schemastore = pcall(require, "schemastore")

	vim.lsp.config("yamlls", {
		capabilities = capabilities,
		settings = {
			yaml = {
				schemaStore = { enable = false, url = "" },
				schemas = ok and schemastore.yaml.schemas() or {},
				validate = true,
				-- conform.nvim owns formatting (prettierd for yaml). Leaving this on
				-- gives yamlls a competing formatter that surfaces via `gq` and
				-- vim.lsp.buf.format().
				format = { enable = false },
			},
		},
		filetypes = { "yaml" },
	})
end
