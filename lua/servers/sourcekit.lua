return function(capabilities)
	vim.lsp.config("sourcekit", {
		cmd = { "xcrun", "sourcekit-lsp" },
		filetypes = { "swift" },
		root_markers = {
			".git",
			"compile_commands.json",
			".sourcekit-lsp",
			"Package.swift",
		},
		capabilities = vim.tbl_deep_extend("force", capabilities, {
			workspace = {
				didChangeWatchedFiles = {
					dynamicRegistration = true,
				},
			},
			textDocument = {
				diagnostic = {
					dynamicRegistration = true,
					relatedDocumentSupport = true,
				},
			},
		}),
	})
end
