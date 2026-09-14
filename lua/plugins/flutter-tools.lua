-- ================================================================================================
-- TITLE : Flutter and Dart tooling
-- ABOUT : Flutter commands, Dart LSP integration, hot reload, DevTools, and DAP debugging.
-- LINKS :
--   > github : https://github.com/nvim-flutter/flutter-tools.nvim
-- ================================================================================================

return {
	"nvim-flutter/flutter-tools.nvim",
	lazy = false,
	dependencies = {
		"nvim-lua/plenary.nvim",
		"mfussenegger/nvim-dap",
		"hrsh7th/cmp-nvim-lsp",
	},
	config = function()
		require("flutter-tools").setup({
			ui = {
				border = "rounded",
			},
			decorations = {
				statusline = {
					app_version = true,
					device = true,
					project_config = true,
				},
			},
			debugger = {
				enabled = true,
				exception_breakpoints = {},
				evaluate_to_string_in_debug_views = true,
			},
			root_patterns = { ".git", "pubspec.yaml" },
			dev_log = {
				enabled = true,
				notify_errors = true,
				open_cmd = "15split",
				focus_on_open = false,
			},
			outline = {
				open_cmd = "30vnew",
				auto_open = false,
			},
			lsp = {
				capabilities = require("cmp_nvim_lsp").default_capabilities(),
				settings = {
					showTodos = true,
					completeFunctionCalls = true,
					enableSnippets = true,
					renameFilesWithClasses = "always",
					updateImportsOnRename = true,
				},
			},
		})
	end,
}
