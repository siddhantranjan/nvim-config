-- ================================================================================================
-- TITLE : clangd (C/C++ Language Server) LSP Setup
-- ABOUT :
--   clangd is the ONLY source of C/C++ diagnostics (efm no longer runs cpplint -- see
--   lua/servers/efm-langserver.lua). Formatting is owned by conform.nvim + clang-format.
--
--   Most "errors that shouldn't be there" in C++ come from clangd guessing the compile
--   flags. This module fixes the three usual culprits:
--
--   1. System headers not found ("'iostream' file not found", `std` is undeclared, ...).
--      Mason's clangd doesn't ship libc++ headers or know where the macOS SDK is. It's
--      given SDKROOT and `--query-driver`, which lets it ask the real compiler (Apple clang,
--      Homebrew GCC/LLVM) for its include paths.
--
--   2. Wrong language standard. Without a compile_commands.json clangd falls back to the
--      compiler default (C++17), so concepts, ranges, `<=>`, std::format... show as errors.
--      C++ files now fall back to -std=c++20. Because one clangd process serves a whole
--      root, C and C++ buffers get separate clangd instances in that fallback mode so a .c
--      file is never parsed with a C++ flag.
--
--   3. Noise. `--log=error` keeps lsp.log small (Neovim logs every line of server stderr
--      as an ERROR), and header auto-insertion is off -- with libc++ it tends to insert
--      private headers like <__vector/vector.h>.
--
--   Projects: the best fix is always real flags --
--     cmake -S . -B build -DCMAKE_EXPORT_COMPILE_COMMANDS=ON
--   `:CppInit` drops a starter .clangd and .clang-format into the project root.
-- LINKS :
--   > website : https://clangd.llvm.org/
--   > config  : https://clangd.llvm.org/config
-- ================================================================================================

local uv = vim.uv
local is_mac = uv.os_uname().sysname == "Darwin"
local template_dir = vim.fs.joinpath(vim.fn.stdpath("config"), "templates", "cpp")

-- Compilers clangd is allowed to execute to discover system include paths. Anything a
-- compile_commands.json names that matches one of these globs gets queried; nothing else
-- does (this is clangd's guard against running arbitrary binaries from a repo).
local query_driver = is_mac
		and {
			"/usr/bin/clang*",
			"/usr/bin/cc",
			"/usr/bin/c++",
			"/usr/bin/gcc*",
			"/usr/bin/g++*",
			"/Library/Developer/CommandLineTools/usr/bin/clang*",
			"/Applications/Xcode*.app/Contents/Developer/Toolchains/*/usr/bin/clang*",
			"/opt/homebrew/bin/clang*",
			"/opt/homebrew/bin/gcc-*",
			"/opt/homebrew/bin/g++-*",
			"/opt/homebrew/opt/llvm*/bin/clang*",
			"/usr/local/bin/clang*",
			"/usr/local/bin/gcc-*",
			"/usr/local/bin/g++-*",
		}
	or {
		"/usr/bin/clang*",
		"/usr/bin/cc",
		"/usr/bin/c++",
		"/usr/bin/gcc*",
		"/usr/bin/g++*",
		"/usr/bin/*-gcc*",
		"/usr/bin/*-g++*",
		"/usr/lib/llvm-*/bin/clang*",
		"/usr/local/bin/clang*",
		"/usr/local/bin/gcc*",
		"/usr/local/bin/g++*",
	}

--- macOS SDK path for clangd. lua/config/lazy.lua already exports SDKROOT when a full
--- Xcode is installed; with only the Command Line Tools it doesn't, so ask xcrun.
--- @return string|nil
local function macos_sdk()
	if not is_mac then
		return nil
	end
	if vim.env.SDKROOT and vim.env.SDKROOT ~= "" then
		return vim.env.SDKROOT
	end
	if vim.fn.executable("xcrun") == 0 then
		return nil
	end
	local out = vim.fn.systemlist({ "xcrun", "--show-sdk-path" })[1]
	if vim.v.shell_error == 0 and out and out ~= "" then
		return out
	end
	return nil
end

--- Does clangd have real compile flags for this root? (It looks in the root and in build/.)
--- @param root string|nil
--- @return boolean
local function has_compile_db(root)
	if not root then
		return false
	end
	for _, rel in ipairs({ "compile_commands.json", "build/compile_commands.json", "compile_flags.txt" }) do
		if uv.fs_stat(vim.fs.joinpath(root, rel)) then
			return true
		end
	end
	return false
end

--- Flags clangd uses for files it has no compile command for.
--- @param ft string
--- @return string[]
local function fallback_flags(ft)
	if ft == "cpp" or ft == "cuda" or ft == "objcpp" then
		return { "-std=c++20" }
	end
	return {} -- C: clang's default (gnu17) is fine
end

--- `:CppInit [dir]` -- copy the starter .clang-format and .clangd into a project.
local function cpp_init(opts)
	local root = opts.args ~= "" and vim.fn.fnamemodify(opts.args, ":p")
		or vim.fs.root(0, { "compile_commands.json", "CMakeLists.txt", "meson.build", "Makefile", ".git" })
		or vim.fn.getcwd()

	local written, skipped = {}, {}
	for _, name in ipairs({ ".clang-format", ".clangd" }) do
		local dest = vim.fs.joinpath(root, name)
		-- excl: never clobber a file the project already has.
		if uv.fs_copyfile(vim.fs.joinpath(template_dir, name), dest, { excl = true }) then
			table.insert(written, name)
		else
			table.insert(skipped, name)
		end
	end

	local msg = ("CppInit in %s"):format(root)
	if #written > 0 then
		msg = msg .. "\n  wrote:   " .. table.concat(written, ", ")
	end
	if #skipped > 0 then
		msg = msg .. "\n  skipped: " .. table.concat(skipped, ", ") .. " (already exists)"
	end
	if #written > 0 then
		msg = msg .. "\nRun :LspRestart clangd to pick it up."
	end
	vim.notify(msg, vim.log.levels.INFO)
end

--- @param capabilities table LSP client capabilities (typically from nvim-cmp or similar)
--- @return nil
return function(capabilities)
	local sdk = macos_sdk()

	vim.lsp.config("clangd", {
		capabilities = capabilities,
		cmd = {
			"clangd",
			"--background-index", -- index the whole project for references / workspace symbols
			"--clang-tidy", -- extra checks; tune per project in .clang-tidy or .clangd
			"--completion-style=detailed", -- one completion item per overload
			"--header-insertion=never", -- see note 3 above
			"--pch-storage=memory", -- faster reparses
			"--offset-encoding=utf-16",
			"--log=error",
			"--query-driver=" .. table.concat(query_driver, ","),
		},
		cmd_env = sdk and { SDKROOT = sdk } or nil,
		filetypes = { "c", "cpp", "cuda" }, -- objc/objcpp belong to sourcekit
		init_options = {
			usePlaceholders = true,
			completeUnimported = true,
			clangdFileStatus = true,
		},

		-- Pick fallback flags from the buffer that started this client. lsp.start runs
		-- inside that buffer's FileType autocmd, so it is the current buffer here.
		before_init = function(params, config)
			local init_options = vim.tbl_extend("force", config.init_options or {}, {
				fallbackFlags = fallback_flags(vim.bo.filetype),
			})
			config.init_options = init_options
			params.initializationOptions = init_options
		end,

		-- Default behaviour (one client per root), except in fallback mode where a C buffer
		-- must not join a client that was started with -std=c++20, or vice versa.
		reuse_client = function(client, config)
			if client.name ~= config.name or client:is_stopped() or client.root_dir ~= config.root_dir then
				return false
			end
			if has_compile_db(config.root_dir) then
				return true
			end
			local have = (client.config.init_options or {}).fallbackFlags or {}
			return vim.deep_equal(have, fallback_flags(vim.bo.filetype))
		end,
	})

	vim.api.nvim_create_user_command("CppInit", cpp_init, {
		nargs = "?",
		complete = "dir",
		desc = "Write starter .clang-format and .clangd into the project root",
	})
end
