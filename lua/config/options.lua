-- ================================================================================================
-- TITLE : NeoVim options
-- ABOUT : basic settings native to neovim
-- ================================================================================================

local opt = vim.opt
local icons = require("utils.icons")

-- ── Basic ───────────────────────────────────────────────────────────────────────────────────
opt.number = true -- Line numbers
opt.relativenumber = true -- Relative line numbers
opt.cursorline = true -- Highlight current line
opt.scrolloff = 10 -- Keep 10 lines above/below cursor
opt.sidescrolloff = 8 -- Keep 8 columns left/right of cursor
opt.wrap = false -- Don't wrap lines
opt.cmdheight = 1 -- Command line height
opt.spelllang = { "en_us" } -- "de" was inherited from a template; removed
opt.spelloptions = "camel" -- Treat camelCase segments as separate words

-- ── Indentation ─────────────────────────────────────────────────────────────────────────────
opt.tabstop = 4 -- Tab width
opt.shiftwidth = 4 -- Indent width
opt.softtabstop = 4 -- Soft tab stop
opt.expandtab = true -- Use spaces instead of tabs
opt.shiftround = true -- Round indent to a multiple of shiftwidth
opt.smartindent = true -- Smart auto-indenting
opt.autoindent = true -- Copy indent from current line
opt.breakindent = true -- Wrapped lines keep their indent

-- ── Grep ────────────────────────────────────────────────────────────────────────────────────
-- ripgrep if it's installed, otherwise leave Neovim's default `grep`. Pointing 'grepprg'
-- at a binary that isn't there makes :grep fail with "command not found" rather than
-- falling back.
if vim.fn.executable("rg") == 1 then
	opt.grepprg = "rg --vimgrep --smart-case"
	opt.grepformat = "%f:%l:%c:%m" -- filename, line, column, content
end

-- ── Search ──────────────────────────────────────────────────────────────────────────────────
opt.ignorecase = true -- Case-insensitive search
opt.smartcase = true -- ...unless the pattern contains an uppercase letter
opt.hlsearch = false -- Don't persist match highlighting
opt.incsearch = true -- Show matches as you type
opt.inccommand = "split" -- Live preview of :substitute, with an off-screen preview pane

-- ── Visual ──────────────────────────────────────────────────────────────────────────────────
opt.termguicolors = true -- 24-bit colour
opt.signcolumn = "yes:1" -- Always show exactly one sign column (prevents text jitter)
opt.colorcolumn = "100" -- Ruler at 100 characters
opt.showmatch = true -- Briefly jump to the matching bracket
opt.matchtime = 2 -- ...for 200ms
opt.completeopt = "menuone,noinsert,noselect" -- Completion behaviour
opt.showmode = false -- Mode is in the statusline already
opt.pumheight = 10 -- Popup menu height
opt.pumblend = 10 -- Popup menu transparency
opt.winblend = 0 -- Floating window transparency
opt.conceallevel = 2 -- Required by obsidian.nvim / markdown rendering
opt.concealcursor = "" -- ...but show raw markup on the cursor line
-- Glyphs come from lua/utils/icons.lua, where they're written as \u{...} escapes. Every
-- 'fillchars' field must be exactly one character or Neovim raises E1511 -- keeping the
-- definitions in one ASCII-safe file is what stops a mangled glyph from breaking startup.
opt.fillchars = icons.fillchars
opt.list = true -- Show invisible characters...
opt.listchars = icons.listchars
opt.laststatus = 3 -- Single global statusline (matches lualine's globalstatus)
opt.splitkeep = "screen" -- Don't scroll the text when a split opens above

-- ── Performance ─────────────────────────────────────────────────────────────────────────────
opt.redrawtime = 10000 -- Timeout for syntax highlighting redraw
opt.maxmempattern = 20000 -- Max memory for pattern matching
opt.synmaxcol = 300 -- Stop syntax highlighting past column 300
opt.lazyredraw = false -- Off: it breaks rendering in noice/notify-style float UIs

-- ── Files & undo ────────────────────────────────────────────────────────────────────────────
opt.backup = false -- No backup files
opt.writebackup = false -- No backup before overwriting
opt.swapfile = false -- No swap files
-- NOTE: 'undofile' is set further down, after the undo directory has been created and
-- verified writable -- see the block below. Setting it here as well would be a second
-- source of truth for the same option.
opt.undolevels = 10000
opt.updatetime = 300 -- CursorHold delay (drives document highlight, gitsigns blame)
opt.timeoutlen = 500 -- Wait for a mapped sequence
opt.ttimeoutlen = 0 -- No wait for terminal key codes
opt.autoread = true -- Reload files changed outside Neovim
opt.autowrite = false -- Don't auto-save
opt.confirm = true -- Prompt to save instead of failing on :q with changes

opt.diffopt:append("vertical") -- Vertical diff splits
opt.diffopt:append("algorithm:histogram") -- Better than patience for most real diffs
opt.diffopt:append("linematch:60") -- Smarter intra-hunk line matching
opt.diffopt:append("indent-heuristic")

-- Undo directory. stdpath("state") is where Neovim expects this to live; the old hardcoded
-- ~/.local/share/nvim/undodir worked by coincidence of that being the default data dir.
--
-- CAREFUL with the permission argument: Lua has no octal literals, so `0700` is the DECIMAL
-- number 700, which as a Unix mode is octal 1274 -- owner gets write but not execute, and a
-- directory without execute cannot have files created in it. That produces
-- "E828: Cannot open undo file for writing" on the first save of every new file.
-- tonumber("700", 8) is the correct way to write an octal mode in Lua.
local undodir = vim.fn.stdpath("state") .. "/undo"

if vim.fn.isdirectory(undodir) == 0 then
	vim.fn.mkdir(undodir, "p", tonumber("700", 8))
end

-- If the directory still isn't usable, fall back to no persistent undo rather than
-- prompting "Press ENTER" on every single write.
if vim.fn.isdirectory(undodir) == 1 and vim.fn.filewritable(undodir) == 2 then
	opt.undodir = undodir
	opt.undofile = true
else
	opt.undofile = false
	vim.schedule(function()
		vim.notify(
			("Persistent undo disabled: %s is not writable"):format(undodir),
			vim.log.levels.WARN
		)
	end)
end

-- ── Behaviour ───────────────────────────────────────────────────────────────────────────────
opt.errorbells = false -- No error sounds
opt.backspace = "indent,eol,start" -- Sane backspace
opt.autochdir = false -- Don't follow the buffer with :cd
opt.iskeyword:append("-") -- Treat dash as part of a word
opt.path:append("**") -- `gf` searches subdirectories
opt.selection = "inclusive"
opt.mouse = "a" -- Mouse support (dropbar's clickable winbar needs this)
opt.mousemoveevent = true -- ...including hover, for dropbar/which-key
opt.clipboard:append("unnamedplus") -- Share the system clipboard
opt.encoding = "UTF-8"
opt.fileencoding = "utf-8"
opt.wildmenu = true
opt.wildmode = "longest:full,full"
opt.wildignorecase = true
opt.wildignore:append({ "*/node_modules/*", "*/.git/*", "*/target/*", "*/build/*", "*/.DS_Store" })
opt.sessionoptions = { "buffers", "curdir", "tabpages", "winsize", "help", "globals", "skiprtp", "folds" }
opt.virtualedit = "block" -- Let visual-block selections go past end of line
opt.jumpoptions = "view" -- Restore the view when jumping back
opt.shortmess:append("cCI") -- Fewer completion messages, no intro screen

-- ── Cursor ──────────────────────────────────────────────────────────────────────────────────
opt.guicursor = {
	"n-v-c:block", -- Normal, Visual, Command-line
	"i-ci-ve:block", -- Insert (block, matching the terminal-style preference here)
	"r-cr:hor20", -- Replace
	"o:hor50", -- Operator-pending
	"a:blinkwait700-blinkoff400-blinkon250-Cursor/lCursor",
	"sm:block-blinkwait175-blinkoff150-blinkon175", -- Showmatch
}

-- ── Folding ─────────────────────────────────────────────────────────────────────────────────
opt.foldmethod = "expr"
opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
opt.foldtext = "" -- Keep syntax highlighting on the fold line (Neovim 0.10+)
opt.foldlevel = 99 -- Everything open by default
opt.foldlevelstart = 99
opt.foldnestmax = 4
opt.foldcolumn = "0" -- Fold markers live in the sign column instead

-- ── Splits ──────────────────────────────────────────────────────────────────────────────────
opt.splitbelow = true -- Horizontal splits open below
opt.splitright = true -- Vertical splits open to the right

-- Diagnostic signs, virtual text and float styling live in lua/utils/diagnostics.lua,
-- which is called from the nvim-lspconfig spec.
