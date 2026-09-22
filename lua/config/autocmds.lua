-- ================================================================================================
-- TITLE : auto-commands
-- ABOUT : automatically run code on defined events (e.g. save, yank)
-- ================================================================================================

local function augroup(name)
	return vim.api.nvim_create_augroup("user_" .. name, { clear = true })
end

-- ── Restore last cursor position when reopening a file ──────────────────────────────────────
vim.api.nvim_create_autocmd("BufReadPost", {
	group = augroup("last_cursor"),
	callback = function(args)
		-- Don't restore in commit messages -- you almost always want line 1 there.
		if vim.tbl_contains({ "gitcommit", "gitrebase", "hgcommit" }, vim.bo[args.buf].filetype) then
			return
		end

		local mark = vim.api.nvim_buf_get_mark(args.buf, '"')
		local lcount = vim.api.nvim_buf_line_count(args.buf)

		if mark[1] > 0 and mark[1] <= lcount then
			pcall(vim.api.nvim_win_set_cursor, 0, mark)
			pcall(vim.cmd, "normal! zvzz") -- open folds and center
		end
	end,
})

-- ── Highlight yanked text briefly ───────────────────────────────────────────────────────────
vim.api.nvim_create_autocmd("TextYankPost", {
	group = augroup("highlight_yank"),
	pattern = "*",
	callback = function()
		vim.hl.on_yank({ higroup = "IncSearch", timeout = 200 })
	end,
})

-- ── LSP mappings on attach ──────────────────────────────────────────────────────────────────
vim.api.nvim_create_autocmd("LspAttach", {
	group = augroup("lsp_attach"),
	callback = require("utils.lsp").on_attach,
})

-- NOTE: trailing-whitespace trimming used to live here as an unconditional
-- `require("mini.trailspace").trim()` on every BufWritePre -- including buffers the user
-- never asked to reformat (diffs, commit messages, third-party files). conform.nvim now
-- owns it via the `_` fallback formatter, which respects the same ignore rules and
-- format-on-save toggle as every other formatter. `:lua MiniTrailspace.trim()` still works
-- for a manual one-off.

-- ── Filetype-specific options ───────────────────────────────────────────────────────────────

-- Prose: soft wrap, no rulers or line numbers.
vim.api.nvim_create_autocmd("FileType", {
	group = augroup("prose_options"),
	pattern = { "markdown", "text", "gitcommit", "typst", "tex" },
	callback = function()
		vim.opt_local.wrap = true
		vim.opt_local.linebreak = true
		vim.opt_local.relativenumber = false
		vim.opt_local.number = false
		vim.opt_local.cursorline = false
		vim.opt_local.colorcolumn = ""
		vim.opt_local.signcolumn = "no"
		vim.opt_local.scrollbind = false
		vim.opt_local.cursorbind = false
		vim.opt_local.spell = true
	end,
})

-- Two-space languages. Consolidated from three near-identical autocmds.
-- Value = the colorcolumn to use, or `true` to leave the global one alone.
-- (Careful: a Lua table field set to `nil` simply doesn't exist, so `true` is the
-- placeholder here -- `foo = nil` would drop the key from vim.tbl_keys entirely.)
local two_space = {
	css = true,
	dart = 80, -- dart format's page width
	html = true,
	javascript = true,
	javascriptreact = true,
	json = true,
	jsonc = true,
	ruby = true,
	scss = true,
	svelte = true,
	typescript = true,
	typescriptreact = true,
	vue = true,
	yaml = true,
}

vim.api.nvim_create_autocmd("FileType", {
	group = augroup("two_space_indent"),
	pattern = vim.tbl_keys(two_space),
	callback = function(args)
		vim.opt_local.tabstop = 2
		vim.opt_local.shiftwidth = 2
		vim.opt_local.softtabstop = 2
		vim.opt_local.expandtab = true

		local width = two_space[vim.bo[args.buf].filetype]
		if type(width) == "number" then
			vim.opt_local.colorcolumn = tostring(width)
		end
	end,
})

-- Go uses real tabs, always.
vim.api.nvim_create_autocmd("FileType", {
	group = augroup("go_options"),
	pattern = "go",
	callback = function()
		vim.opt_local.expandtab = false
		vim.opt_local.tabstop = 4
		vim.opt_local.shiftwidth = 4
		vim.opt_local.softtabstop = 4
	end,
})

-- Lua in *this* config is tab-indented (stylua config in conform.lua agrees).
vim.api.nvim_create_autocmd("FileType", {
	group = augroup("lua_options"),
	pattern = "lua",
	callback = function()
		vim.opt_local.expandtab = false
		vim.opt_local.tabstop = 4
		vim.opt_local.shiftwidth = 4
		vim.opt_local.softtabstop = 4
	end,
})

-- ── Quality of life ─────────────────────────────────────────────────────────────────────────

-- Close throwaway windows with plain `q`.
vim.api.nvim_create_autocmd("FileType", {
	group = augroup("close_with_q"),
	pattern = {
		"checkhealth",
		"dap-float",
		"fugitive",
		"gitsigns-blame",
		"help",
		"lspinfo",
		"man",
		"notify",
		"qf",
		"query",
		"startuptime",
		"tsplayground",
	},
	callback = function(args)
		vim.bo[args.buf].buflisted = false
		vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = args.buf, silent = true, desc = "Close window" })
	end,
})

-- Create missing parent directories when writing a new file.
vim.api.nvim_create_autocmd("BufWritePre", {
	group = augroup("auto_mkdir"),
	callback = function(args)
		if args.match:match("^%w%w+://") then
			return -- skip scp://, oil://, fugitive:// and friends
		end

		local file = vim.uv.fs_realpath(args.match) or args.match
		vim.fn.mkdir(vim.fn.fnamemodify(file, ":p:h"), "p")
	end,
})

-- Reload a file changed outside Neovim (pairs with `autoread`, which alone doesn't poll).
vim.api.nvim_create_autocmd({ "FocusGained", "TermClose", "TermLeave" }, {
	group = augroup("checktime"),
	callback = function()
		if vim.o.buftype ~= "nofile" then
			vim.cmd.checktime()
		end
	end,
})

-- Keep split proportions when the terminal window is resized.
vim.api.nvim_create_autocmd("VimResized", {
	group = augroup("resize_splits"),
	callback = function()
		local current_tab = vim.fn.tabpagenr()
		vim.cmd("tabdo wincmd =")
		vim.cmd("tabnext " .. current_tab)
	end,
})

-- Relative numbers are useful for jumping around in normal mode, and pure noise in insert
-- mode or in an unfocused window.
local number_toggle = augroup("number_toggle")

vim.api.nvim_create_autocmd({ "InsertEnter", "WinLeave" }, {
	group = number_toggle,
	callback = function()
		if vim.wo.number and vim.bo.buftype == "" then
			vim.wo.relativenumber = false
		end
	end,
})

vim.api.nvim_create_autocmd({ "InsertLeave", "WinEnter" }, {
	group = number_toggle,
	callback = function()
		if vim.wo.number and vim.bo.buftype == "" then
			vim.wo.relativenumber = true
		end
	end,
})
