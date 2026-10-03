-- ================================================================================================
-- TITLE : cmake-tools.nvim
-- ABOUT :
--   CMake integration -- the equivalent of VS Code's CMake Tools. Configure, build, pick
--   targets, run and debug, all from Neovim. <leader>eb / ex / ed use it automatically when
--   the cwd has a CMakeLists.txt (lua/utils/runner.lua); the CMake-specific actions live under
--   <leader>ec….
--
--   Wiring with the rest of the config:
--     * compile_commands.json is exported on every configure and symlinked into the project
--       root, which is where clangd looks for it (lua/servers/clangd.lua).
--     * Build output goes to the quickfix list, opened only when the build fails.
--     * Programs run in a toggleterm split (lua/plugins/toggleterm.lua).
--     * :CMakeDebug uses the `codelldb` adapter defined in lua/plugins/nvim-dap-ui.lua.
-- LINKS :
--   > github : https://github.com/Civitasv/cmake-tools.nvim
-- ================================================================================================

return {
	"Civitasv/cmake-tools.nvim",
	ft = { "c", "cpp", "cmake" },
	cmd = {
		"CMakeGenerate",
		"CMakeBuild",
		"CMakeRun",
		"CMakeDebug",
		"CMakeClean",
		"CMakeSelectBuildType",
		"CMakeSelectBuildTarget",
		"CMakeSelectLaunchTarget",
		"CMakeLaunchArgs",
		"CMakeRunTest",
		"CMakeSettings",
		"CMakeQuickStart",
	},
	dependencies = {
		"nvim-lua/plenary.nvim",
		"akinsho/toggleterm.nvim",
	},

	keys = {
		{ "<leader>ecg", "<cmd>CMakeGenerate<cr>", desc = "CMake: configure" },
		{ "<leader>ecb", "<cmd>CMakeSelectBuildType<cr>", desc = "CMake: build type (Debug/Release…)" },
		{ "<leader>ect", "<cmd>CMakeSelectBuildTarget<cr>", desc = "CMake: build target" },
		{ "<leader>ecl", "<cmd>CMakeSelectLaunchTarget<cr>", desc = "CMake: launch target" },
		{ "<leader>eca", "<cmd>CMakeLaunchArgs<cr>", desc = "CMake: launch arguments" },
		{ "<leader>ecT", "<cmd>CMakeRunTest<cr>", desc = "CMake: run tests (ctest)" },
		{ "<leader>ecc", "<cmd>CMakeClean<cr>", desc = "CMake: clean" },
		{ "<leader>ecs", "<cmd>CMakeSettings<cr>", desc = "CMake: settings" },
	},

	opts = {
		cmake_build_directory = "build/${variant:buildType}",
		cmake_generate_options = { "-DCMAKE_EXPORT_COMPILE_COMMANDS=1" },
		cmake_regenerate_on_save = true, -- re-configure when CMakeLists.txt is saved
		cmake_compile_commands_options = {
			action = "soft_link", -- build/<type>/compile_commands.json -> <root>/compile_commands.json
		},
		cmake_executor = {
			name = "quickfix",
			opts = {
				show = "only_on_error",
				auto_close_when_success = true,
			},
		},
		cmake_runner = {
			name = "toggleterm",
			opts = {
				direction = "horizontal",
				close_on_exit = false,
				auto_focus = true,
			},
		},
	},
}
