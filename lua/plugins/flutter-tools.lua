-- ================================================================================================
-- TITLE : Flutter and Dart tooling
-- ABOUT :
--   Registers and starts `dartls` itself (which is why dartls is absent from lua/servers/),
--   plus hot reload, DevTools, device selection and DAP.
-- NOTE  :
--   Keymaps are buffer-local on dart files and defined in lua/utils/lsp.lua, under the same
--   <leader>m… namespace as the Xcode mappings.
-- LINKS :
--   > github : https://github.com/nvim-flutter/flutter-tools.nvim
-- ================================================================================================

return {
	"nvim-flutter/flutter-tools.nvim",
	ft = { "dart" },
	cmd = { "FlutterRun", "FlutterDevices", "FlutterEmulators", "FlutterDebug" },

	dependencies = {
		"nvim-lua/plenary.nvim",
		"mfussenegger/nvim-dap",
		"hrsh7th/cmp-nvim-lsp",
	},

	config = function()
		require("flutter-tools").setup({
			ui = { border = "rounded" },

			decorations = {
				statusline = {
					app_version = true,
					device = true,
					project_config = true,
				},
			},

			debugger = {
				enabled = true,
				run_via_dap = true,
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
				-- Plugin-managed `lsp.color` is deprecated upstream in favour of Neovim's
				-- native document-color support and will be removed once flutter-tools
				-- requires nvim 0.12+. The replacement lives in lua/utils/lsp.lua's
				-- on_attach, gated on the documentColor capability, so it covers every
				-- LSP server that advertises it, not just dartls.
				settings = {
					showTodos = true,
					completeFunctionCalls = true,
					enableSnippets = true,
					renameFilesWithClasses = "always",
					updateImportsOnRename = true,
					lineLength = 80,
					-- conform runs `dart format` on save. Leaving the SDK formatter
					-- enabled would have dartls advertise formatting too, giving the
					-- buffer two formatters with separate settings.
					enableSdkFormatter = false,
				},
			},
		})
	end,
}
