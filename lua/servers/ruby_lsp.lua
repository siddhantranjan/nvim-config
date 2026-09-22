-- ================================================================================================
-- TITLE : ruby_lsp (Ruby Language Server) LSP Setup
-- ABOUT :
--   Resolved through asdf shims rather than Mason, so the server always matches the Ruby
--   version asdf selects for the current project. If the shim is absent the server is simply
--   not registered -- no startup error.
-- LINKS :
--   > github: https://github.com/Shopify/ruby-lsp
-- ================================================================================================

--- @param capabilities table LSP client capabilities (typically from nvim-cmp or similar)
--- @return boolean available whether the server was registered
return function(capabilities)
	local shim = vim.fn.expand("~/.asdf/shims/ruby-lsp")
	local cmd

	if vim.fn.executable(shim) == 1 then
		cmd = { shim }
	elseif vim.fn.executable("ruby-lsp") == 1 then
		cmd = { "ruby-lsp" }
	else
		return false
	end

	vim.lsp.config("ruby_lsp", {
		capabilities = capabilities,
		cmd = cmd,
		filetypes = { "ruby", "eruby" },
		root_markers = { "Gemfile", ".git" },
		init_options = {
			formatter = "none", -- conform.nvim owns formatting
			linters = {}, -- efm owns linting
		},
	})

	return true
end
