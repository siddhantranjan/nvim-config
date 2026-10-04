-- ================================================================================================
-- TITLE : runner
-- ABOUT :
--   One set of keys -- <leader>eb / ex / ed -- that builds, runs or debugs "whatever I'm looking
--   at", the way the build / run / debug buttons do in VS Code. The backend is picked from
--   context:
--
--     Rust file inside a Cargo project   -> cargo build / cargo run / rustaceanvim debuggables
--     standalone .rs file (no Cargo.toml) -> rustc, binary next to the file (main.rs -> main)
--     script (python, go, sh, lua, js, ...) -> run in a toggleterm split
--     anything else                       -> overseer's own templates (make, npm, cargo,
--                                            .vscode/tasks.json, ...)
--
--   Build errors land in the quickfix list (opened only on failure). Programs run in a
--   terminal split so they can read stdin.
--
--   Mapped in lua/plugins/overseer.lua.
-- ================================================================================================

local M = {}

-- rustc / cargo `--error-format=short`:
--   src/main.rs:2:5: error[E0425]: cannot find value `x` in this scope
--   src/main.rs:1:5: warning: unused import: `std::fs`
-- %t takes the e/w of error/warning, %*[^:] skips the rest of that word and any [E0425].
local RUST_EFM = "%f:%l:%c: %t%*[^:]: %m"

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

local function save_if_modified()
	if vim.bo.modified and vim.bo.buftype == "" then
		vim.cmd.write()
	end
end

--- Root of the Cargo project containing the current buffer, or nil.
--- Prefers the workspace root (Cargo.lock) over a member crate's Cargo.toml.
--- @return string|nil
local function cargo_root()
	return vim.fs.root(0, { "Cargo.lock" }) or vim.fs.root(0, { "Cargo.toml" })
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

--- Run a build command through overseer: errors -> quickfix (opened on failure only),
--- quickfix closed again on success, then `on_success()`.
--- @param name string
--- @param cmd string[]
--- @param cwd string
--- @param on_success? fun()
local function build_task(name, cmd, cwd, on_success)
	local overseer = require("overseer")

	local task = overseer.new_task({
		name = name,
		cmd = cmd,
		cwd = cwd,
		components = {
			{ "on_output_quickfix", errorformat = RUST_EFM, open_on_exit = "failure" },
			"default",
		},
	})

	task:subscribe("on_complete", function(_, status)
		if status == overseer.STATUS.SUCCESS then
			vim.schedule(function()
				vim.cmd.cclose() -- drop the problems list from a previous failed build
				if on_success then
					on_success()
				end
			end)
		end
		return true -- one-shot
	end)

	task:start()
end

--- Standalone .rs file: compile with rustc next to itself (main.rs -> main).
--- @param on_success? fun(binary: string)
local function build_rust_file(on_success)
	save_if_modified()
	local file = vim.api.nvim_buf_get_name(0)
	local out = vim.fn.fnamemodify(file, ":r")
	build_task(
		"rustc " .. vim.fn.fnamemodify(file, ":t"),
		{ "rustc", "--edition=2021", "-g", "--error-format=short", file, "-o", out },
		vim.fn.fnamemodify(file, ":h"),
		on_success and function()
			on_success(out)
		end
	)
end

--- <leader>eb
function M.build()
	if vim.bo.filetype == "rust" or vim.fn.expand("%:t") == "Cargo.toml" then
		save_if_modified()
		local root = cargo_root()
		if root then
			build_task("cargo build", { "cargo", "build", "--message-format=short" }, root)
		else
			build_rust_file()
		end
		return
	end

	-- make / npm / tasks.json build tasks. Overseer reports "no matching templates" itself.
	local overseer = require("overseer")
	overseer.run_task({ tags = { overseer.TAG.BUILD } })
end

--- <leader>ex
function M.run()
	local ft = vim.bo.filetype

	if ft == "rust" or vim.fn.expand("%:t") == "Cargo.toml" then
		save_if_modified()
		local root = cargo_root()
		if root then
			-- cargo builds first and prints any compile errors in the same split.
			run_in_terminal("cargo run", root)
		else
			build_rust_file(function(binary)
				run_in_terminal(vim.fn.shellescape(binary), vim.fn.fnamemodify(binary, ":h"))
			end)
		end
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
	if vim.bo.filetype == "rust" then
		save_if_modified()
		if cargo_root() then
			-- rustaceanvim asks rust-analyzer for every debuggable target (bins, tests,
			-- examples), builds the chosen one with debug info and starts codelldb.
			vim.cmd.RustLsp("debuggables")
		else
			build_rust_file(function(binary)
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
		end
		return
	end

	require("dap").continue()
end

return M
