-- ================================================================================================
-- TITLE : lazy.nvim Bootstrap & Plugin Setup
-- ABOUT :
--   Bootstraps the 'lazy.nvim' plugin manager by cloning it if not present, prepends it to
--   the runtime path, then loads core configuration (globals, options, keymaps, autocmds)
--   and finally the plugin specs in lua/plugins/.
-- LINKS :
--   > lazy.nvim github  : https://github.com/folke/lazy.nvim
--   > lazy.nvim website : https://lazy.folke.io/installation
-- ================================================================================================

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"

if not (vim.uv or vim.loop).fs_stat(lazypath) then
	local lazyrepo = "https://github.com/folke/lazy.nvim.git"
	local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })

	if vim.v.shell_error ~= 0 then
		vim.api.nvim_echo({
			{ "Failed to clone lazy.nvim:\n", "ErrorMsg" },
			{ out, "WarningMsg" },
			{ "\nPress any key to exit..." },
		}, true, {})
		vim.fn.getchar()
		os.exit(1)
	end
end

vim.opt.rtp:prepend(lazypath)

-- Order matters: globals sets <leader>, which every plugin `keys` spec is resolved against.
require("config.globals")
require("config.options")
require("config.keymaps")
require("config.autocmds")

require("lazy").setup({
	spec = {
		{ import = "plugins" },
	},

	defaults = {
		-- Specs opt into lazy loading individually via event/ft/cmd/keys, rather than
		-- everything being lazy by default and then fighting over load order.
		lazy = false,
		version = false, -- use latest commit unless a spec pins a version
	},

	install = {
		colorscheme = { "kanagawa", "habamax" },
	},

	ui = {
		border = "rounded",
		backdrop = 100,
	},

	checker = {
		enabled = true,
		notify = false, -- check for updates quietly; `:Lazy` shows what's pending
		frequency = 86400, -- once a day
	},

	change_detection = {
		enabled = true,
		notify = false, -- don't interrupt to say a config file changed
	},

	performance = {
		rtp = {
			-- Built-in plugins this config replaces or doesn't use. Disabling them
			-- shaves startup and keeps `:checkhealth` relevant.
			-- NOTE: matchit and matchparen are deliberately NOT disabled. `%` on
			-- if/end pairs and the highlight on the matching bracket both come from
			-- them, and nothing else in this config replaces either.
			disabled_plugins = {
				"gzip",
				"netrw",
				"netrwPlugin",
				"netrwSettings",
				"netrwFileHandlers",
				"rplugin",
				"tarPlugin",
				"tohtml",
				"tutor",
				"zipPlugin",
			},
		},
	},
})

-- `:Lazy` is on <leader>rl (see config/keymaps.lua).
