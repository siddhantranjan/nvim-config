-- ================================================================================================
-- TITLE : html (HTML Language Server) LSP Setup
-- LINKS :
--   > github: https://github.com/microsoft/vscode-html-languageservice
-- ================================================================================================

--- @param capabilities table LSP client capabilities (typically from nvim-cmp or similar)
--- @return nil
return function(capabilities)
	vim.lsp.config("html", {
		capabilities = capabilities,
		filetypes = { "html", "templ" },
		settings = {
			html = {
				format = { enable = false }, -- conform.nvim owns formatting (prettierd)
				hover = { documentation = true, references = true },
			},
		},
	})
end
