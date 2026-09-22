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

-- Tree-sitter compiles parsers with the environment inherited by Neovim.  On some
-- macOS releases `clang` can pick a Command Line Tools SDK that is newer than its
-- linker and fail while parsing libSystem.tbd.  Prefer the SDK from the selected
-- full Xcode installation when it is available; this also keeps parser builds
-- independent of a stale CLT SDK symlink.
if vim.uv.os_uname().sysname == "Darwin" and vim.fn.executable("xcode-select") == 1 then
	local developer_dir = vim.fn.systemlist({ "xcode-select", "-p" })[1]
	local xcode_sdk = developer_dir
		and developer_dir .. "/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk"
	if xcode_sdk and (vim.uv or vim.loop).fs_stat(xcode_sdk) then
		vim.env.SDKROOT = xcode_sdk
	end
end

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
