-- ================================================================================================
-- TITLE : cssls (CSS Language Server) LSP Setup
-- LINKS :
--   > github: https://github.com/microsoft/vscode-css-languageservice
-- ================================================================================================

--- @param capabilities table LSP client capabilities (typically from nvim-cmp or similar)
--- @return nil
return function(capabilities)
	vim.lsp.config("cssls", {
		capabilities = capabilities,
		filetypes = { "css", "scss", "less" },
		settings = {
			-- Tailwind's at-rules (@tailwind, @apply) are unknown to the plain CSS
			-- service; without this every Tailwind file is a wall of red.
			css = { validate = true, lint = { unknownAtRules = "ignore" } },
			scss = { validate = true, lint = { unknownAtRules = "ignore" } },
			less = { validate = true, lint = { unknownAtRules = "ignore" } },
		},
	})
end
