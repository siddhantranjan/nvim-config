-- ================================================================================================
-- TITLE : runner
-- ABOUT :
--   One set of keys -- <leader>eb / ex / ed -- that builds, runs or debugs "whatever I'm looking
--   at", the way the build / run / debug buttons do in VS Code. The right backend is picked
--   from context:
--
--     CMake project (CMakeLists.txt in cwd)  -> cmake-tools.nvim  (:CMakeBuild / Run / Debug)
--     single C / C++ file                    -> compiler via overseer, errors -> quickfix
--     script (python, go, sh, lua, js, ...)  -> run in a toggleterm split
--     anything else                          -> overseer's own templates (make, npm, cargo,
--                                               .vscode/tasks.json, ...)
--
--   Mapped in lua/plugins/overseer.lua.
-- ================================================================================================

local M = {}

local C_LIKE = { c = true, cpp = true }

-- clang / gcc diagnostics -> quickfix. %t takes the first letter of error / warning / note.
-- The last entry catches driver/linker errors with no file position
-- ("clang++: error: linker command failed", "collect2: error: ld returned 1").
local GCC_EFM = table.concat({
	"%f:%l:%c: fatal %trror: %m",
	"%f:%l:%c: %trror: %m",
	"%f:%l:%c: %tarning: %m",
	"%f:%l:%c: %tote: %m",
	"%f:%l: %trror: %m",
	"%f:%l: %tarning: %m",
	"%*[^:]: %trror: %m",
}, ",")

-- Filetype -> interpreter argv (the file path is appended).
local INTERPRETERS = {
	python = { "python3" },
	go = { "go", "run" },
	sh = { "bash" },
	bash = { "bash" },
	zsh = { "zsh" },
	lua = { "nvim", "-l" },
	javascript = { "node" },
	ruby = { "ruby" },
	swift = { "swift" },
}

local function is_cmake_project()
	return vim.uv.fs_stat(vim.fs.joinpath(vim.fn.getcwd(), "CMakeLists.txt")) ~= nil
end

local function save_if_modified()
	if vim.bo.modified and vim.bo.buftype == "" then
		vim.cmd.write()
	end
end

--- Compiler argv for a single C/C++ file. Debug info on, optimisation off, so the result is
--- debuggable with <leader>ed as-is.
--- @param file string
--- @param ft string
--- @param out string
--- @return string[]
local function compile_cmd(file, ft, out)
	if ft == "cpp" then
		local cxx = vim.fn.executable("clang++") == 1 and "clang++" or "g++"
		return { cxx, "-std=c++20", "-g", "-O0", "-Wall", "-Wextra", file, "-o", out }
	end
	local cc = vim.fn.executable("clang") == 1 and "clang" or "gcc"
	return { cc, "-std=c17", "-g", "-O0", "-Wall", "-Wextra", file, "-o", out }
end

-- A single reusable "run" terminal, so repeated runs don't pile up splits. It gets a fixed
-- id far above the ones you'd use interactively: without one, toggleterm hands it the next
-- free id (often 1), and then <C-/> / `1ToggleTerm` would toggle the program's output
-- instead of your shell, and shutting it down would unregister your shell.
local RUN_TERM_ID = 99
local run_term

--- Run a shell command in a toggleterm split that stays open after the process exits.
--- @param cmd string already shell-escaped
--- @param cwd string
local function run_in_terminal(cmd, cwd)
	local Terminal = require("toggleterm.terminal").Terminal
	if run_term then
		pcall(function()
			run_term:shutdown()
		end)
	end
	run_term = Terminal:new({
		count = RUN_TERM_ID,
		cmd = cmd,
		dir = cwd,
		direction = "horizontal",
		close_on_exit = false, -- keep the output (and "[Process exited N]") visible
		hidden = true, -- not toggled by plain :ToggleTerm
		display_name = "run",
		-- Leave Terminal-mode once the program exits: a keypress in Terminal-mode on a
		-- finished job closes the buffer, which would throw the output away.
		on_exit = function(term)
			vim.schedule(function()
				if vim.api.nvim_get_current_buf() == term.bufnr then
					vim.cmd.stopinsert()
				end
			end)
		end,
	})
	run_term:open()
end

--- Compile the current C/C++ file next to itself (foo.cpp -> foo).
--- Errors open in the quickfix list; on success `on_success(binary)` is called.
--- @param on_success? fun(binary: string)
function M.build_file(on_success)
	save_if_modified()

	local overseer = require("overseer")
	local file = vim.api.nvim_buf_get_name(0)
	local out = vim.fn.fnamemodify(file, ":r")

	local task = overseer.new_task({
		name = "build " .. vim.fn.fnamemodify(file, ":t"),
		cmd = compile_cmd(file, vim.bo.filetype, out),
		cwd = vim.fn.fnamemodify(file, ":h"),
		components = {
			{
				"on_output_quickfix",
				errorformat = GCC_EFM,
				open_on_exit = "failure", -- quiet on success, full output in quickfix on failure
			},
			"default",
		},
	})

	task:subscribe("on_complete", function(_, status)
		if status == overseer.STATUS.SUCCESS then
			vim.schedule(function()
				vim.cmd.cclose() -- drop the problems list from a previous failed build
				if on_success then
					on_success(out)
				end
			end)
		end
		return true -- one-shot
	end)

	task:start()
end

--- <leader>eb
function M.build()
	local ft = vim.bo.filetype
	if is_cmake_project() and (C_LIKE[ft] or ft == "cmake") then
		vim.cmd("CMakeBuild")
	elseif C_LIKE[ft] then
		M.build_file()
	else
		-- make / npm / cargo / tasks.json build tasks. Overseer reports "no matching
		-- templates" itself.
		local overseer = require("overseer")
		overseer.run_task({ tags = { overseer.TAG.BUILD } })
	end
end

--- <leader>ex
function M.run()
	local ft = vim.bo.filetype

	if is_cmake_project() and (C_LIKE[ft] or ft == "cmake") then
		vim.cmd("CMakeRun")
		return
	end

	if C_LIKE[ft] then
		M.build_file(function(binary)
			run_in_terminal(vim.fn.shellescape(binary), vim.fn.fnamemodify(binary, ":h"))
		end)
		return
	end

	local interpreter = INTERPRETERS[ft]
	if interpreter then
		save_if_modified()
		local file = vim.api.nvim_buf_get_name(0)
		local argv = vim.list_extend(vim.deepcopy(interpreter), { file })
		run_in_terminal(table.concat(vim.tbl_map(vim.fn.shellescape, argv), " "), vim.fn.fnamemodify(file, ":h"))
		return
	end

	vim.cmd("OverseerRun")
end

--- <leader>ed
function M.debug()
	local ft = vim.bo.filetype

	if is_cmake_project() and C_LIKE[ft] then
		vim.cmd("CMakeDebug")
		return
	end

	if C_LIKE[ft] then
		M.build_file(function(binary)
			require("dap").run({
				name = "Debug " .. vim.fn.fnamemodify(binary, ":t"),
				type = "codelldb",
				request = "launch",
				program = binary,
				cwd = vim.fn.fnamemodify(binary, ":h"),
				stopOnEntry = false,
				args = {},
			})
		end)
		return
	end

	require("dap").continue()
end

return M
