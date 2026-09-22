-- luacheck configuration for this Neovim config.
-- Run via efm-langserver (see lua/servers/efm-langserver.lua) or `luacheck .`

std = "luajit"
cache = true
codes = true

globals = {
	"vim",
}

read_globals = {
	"vim",
	-- mini.nvim exposes each module as a global once set up.
	"MiniTrailspace",
	"MiniNotify",
	"MiniIcons",
	"MiniAi",
	"MiniSurround",
}

exclude_files = {
	"lazy-lock.json",
}

ignore = {
	"212", -- unused argument (pervasive in callbacks)
	"213", -- unused loop variable
	"631", -- line is too long (stylua owns width; see .stylua.toml)
	"122", -- setting a read-only field of a global (vim.notify = ... in mini.notify setup)
}

max_line_length = false
