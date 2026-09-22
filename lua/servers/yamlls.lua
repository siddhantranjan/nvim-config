-- ================================================================================================
-- TITLE : yamlls (YAML Language Server) LSP Setup
-- LINKS :
--   > github: https://github.com/redhat-developer/yaml-language-server
-- ================================================================================================

--- @param capabilities table LSP client capabilities (typically from nvim-cmp or similar)
--- @return nil
return function(capabilities)
	vim.lsp.config('yamlls', {
		capabilities = capabilities,
		settings = {
			yaml = {
				schemas = {
					["https://json.schemastore.org/composer.json"] = "composer.json",
					["https://json.schemastore.org/docker-compose.json"] = "docker-compose*.yml",
				},
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
