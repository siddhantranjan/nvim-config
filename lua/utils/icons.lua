-- ================================================================================================
-- TITLE : icons
-- ABOUT : Single source of truth for every glyph used across the config.
--
-- WHY THE ESCAPE SEQUENCES
--   Nerd Font glyphs in the Basic Multilingual Plane private-use area (U+E000-U+F8FF) are
--   invisible to a lot of tooling -- editors, terminals, diff viewers, and anything that
--   round-trips a file through a pipeline that doesn't understand them. A glyph silently
--   flattened to an empty string produces failures that are hard to trace: a blank sign
--   column, or `E1511: Wrong number of characters for field "foldclose"` from 'fillchars',
--   which validates length.
--
--   Writing them as `\u{f057}` keeps this file pure ASCII on disk while producing exactly
--   the same bytes at runtime. LuaJIT supports the `\u{XXXX}` escape.
--
--   Codepoints can be looked up at https://www.nerdfonts.com/cheat-sheet
--
-- REQUIRES : a Nerd Font v3+ patched font in the terminal.
-- ================================================================================================

local M = {}

M.diagnostics = {
	error = "\u{f057} ", -- nf-fa-times_circle
	warn = "\u{f071} ", -- nf-fa-warning
	info = "\u{f05a} ", -- nf-fa-info_circle
	hint = "\u{ea61} ", -- nf-cod-lightbulb
}

M.git = {
	branch = "\u{e0a0}", -- nf-pl-branch
	added = "\u{f457} ", -- nf-oct-diff_added
	modified = "\u{f459} ", -- nf-oct-diff_modified
	removed = "\u{f458} ", -- nf-oct-diff_removed
}

M.file = {
	modified = "\u{f0c7}", -- nf-fa-save
	readonly = "\u{f023}", -- nf-fa-lock
	unnamed = "[No Name]",
	newfile = "\u{eafc}", -- nf-cod-new_file
}

M.lsp = {
	server = "\u{f085}", -- nf-fa-gears
	format_off = "\u{f0265} off", -- nf-md-format_text (supplementary plane)
}

-- Powerline separators for the statusline.
M.separators = {
	left = "\u{e0b4}", -- nf-pl-right_half_circle_thick
	right = "\u{e0b6}", -- nf-pl-left_half_circle_thick
	thin = "\u{e0b1}", -- nf-pl-left_soft_divider
}

M.signs = {
	gutter = "\u{2502}", -- box drawing light vertical
	gutter_dashed = "\u{2506}", -- box drawing light triple dash vertical
	topdelete = "\u{203e}", -- overline
	delete = "_",
	changedelete = "~",
}

M.dap = {
	breakpoint = "\u{25cf}", -- black circle
	conditional = "\u{25c6}", -- black diamond
	rejected = "\u{25cb}", -- white circle
	logpoint = "\u{25c7}", -- white diamond
	stopped = "\u{25b6}", -- black right-pointing triangle
}

M.mason = {
	installed = "\u{2713}", -- check mark
	pending = "\u{279c}", -- heavy round-tipped rightwards arrow
	uninstalled = "\u{2717}", -- ballot X
}

-- which-key group icons. These use the supplementary-plane nf-md set (U+F0000+), which
-- survives text pipelines that mangle the BMP private-use area -- but they're escaped here
-- for the same reason as everything else.
M.groups = {
	buffer = "\u{f04e9} ", -- nf-md-buffer
	code = "\u{f0853} ", -- nf-md-code_braces
	debug = "\u{f00e4} ", -- nf-md-bug
	find = "\u{f0349} ", -- nf-md-magnify
	git = "\u{f062c} ", -- nf-md-source_branch
	mobile = "\u{f011c} ", -- nf-md-cellphone
	notes = "\u{f082e} ", -- nf-md-note_text
	organize = "\u{f04ba} ", -- nf-md-sort
	paste = "\u{f0192} ", -- nf-md-clipboard
	rename = "\u{f0455} ", -- nf-md-rename_box
	splits = "\u{f0bce} ", -- nf-md-view_split_vertical
	diagnostics = "\u{f05d6} ", -- nf-md-alert_circle_outline
}

M.misc = {
	colour = "\u{f14fb} ", -- nf-md-square_rounded
	lightbulb = "\u{f0335}", -- nf-md-lightbulb_on
	ellipsis = "\u{2026}", -- horizontal ellipsis
	dot = "\u{25cf}", -- black circle
}

-- 'fillchars' values. EVERY field here must be exactly one character (except `tab`, which
-- takes two or three) -- Neovim raises E1511 otherwise.
M.fillchars = {
	eob = " ",
	fold = " ",
	foldopen = "\u{25be}", -- black down-pointing small triangle
	foldclose = "\u{25b8}", -- black right-pointing small triangle
	foldsep = "\u{2502}",
	diff = "\u{2571}", -- box drawing light diagonal upper right to lower left
}

M.listchars = {
	tab = "\u{2192} ", -- rightwards arrow + space (2 chars, allowed for `tab`)
	trail = "\u{b7}", -- middle dot
	nbsp = "\u{2423}", -- open box
	extends = "\u{203a}", -- single right-pointing angle quotation mark
	precedes = "\u{2039}", -- single left-pointing angle quotation mark
}

return M
