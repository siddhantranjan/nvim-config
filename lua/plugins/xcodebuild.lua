-- ================================================================================================
-- TITLE : xcodebuild.nvim
-- ABOUT :
--   Build, run, test and debug Xcode projects without leaving Neovim. Keymaps live in
--   config/keymaps.lua under <leader>m… (shared with Flutter, which overrides them
--   buffer-locally on dart files).
-- NOTE  :
--   Requires external tooling that Mason cannot install: Xcode itself, plus `xcbeautify`,
--   `xcode-build-server` and `pymobiledevice3` (physical devices). `:XcodebuildSetup`
--   checks for them. `sourcekit-lsp` ships with Xcode and is configured in
--   lua/servers/sourcekit.lua.
--
--   This plugin uses telescope for its pickers -- that's why telescope.nvim is a dependency
--   here even though fzf-lua is the picker everywhere else.
-- LINKS :
--   > github : https://github.com/wojciech-kulik/xcodebuild.nvim
-- ================================================================================================

return {
	"wojciech-kulik/xcodebuild.nvim",
	ft = { "swift", "objc", "objcpp" },
	cmd = {
		"XcodebuildSetup",
		"XcodebuildPicker",
		"XcodebuildBuild",
		"XcodebuildRun",
		"XcodebuildTest",
		"XcodebuildClean",
		"XcodebuildToggleLogs",
	},

	dependencies = {
		"nvim-telescope/telescope.nvim",
		"MunifTanjim/nui.nvim",
		"nvim-mini/mini.icons",
		"mfussenegger/nvim-dap",
	},

	opts = {
		logs = {
			auto_open_on_success_tests = false,
			auto_open_on_failed_tests = true,
			auto_open_on_success_build = false,
			auto_open_on_failed_build = true,
			auto_close_on_app_launch = true,
			only_summary = false,
		},

		code_coverage = { enabled = false },

		integrations = {
			-- oil replaces netrw; xcodebuild can keep the Xcode project file in sync
			-- when files are created or renamed through it.
			oil_nvim = { enabled = true },
			nvim_tree = { enabled = false },
			quickfix = { show_errors_on_quickfix = true },
		},
	},
}
