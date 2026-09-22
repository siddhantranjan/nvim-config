-- ================================================================================================
-- TITLE : sourcekit (Swift / Objective-C Language Server) LSP Setup
-- ABOUT :
--   Ships with Xcode rather than Mason, and is reached through `xcrun` so it tracks whatever
--   toolchain `xcode-select` points at. If Xcode's command line tools aren't installed the
--   module opts out instead of registering a server whose `cmd` can never run.
-- LINKS :
--   > github: https://github.com/swiftlang/sourcekit-lsp
-- ================================================================================================

--- @param capabilities table LSP client capabilities (typically from nvim-cmp or similar)
--- @return boolean available whether the server was registered
return function(capabilities)
	if vim.fn.executable("xcrun") == 0 then
		return false
	end

	vim.lsp.config("sourcekit", {
		capabilities = vim.tbl_deep_extend("force", capabilities, {
			workspace = {
				didChangeWatchedFiles = { dynamicRegistration = true },
			},
			textDocument = {
				diagnostic = {
					dynamicRegistration = true,
					relatedDocumentSupport = true,
				},
			},
		}),
		cmd = { "xcrun", "sourcekit-lsp" },
		filetypes = { "swift", "objc", "objcpp" },
		root_markers = {
			"buildServer.json",
			"Package.swift",
			"compile_commands.json",
			".sourcekit-lsp",
			".git",
		},
	})

	return true
end
