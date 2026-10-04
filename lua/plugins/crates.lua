-- ================================================================================================
-- TITLE : crates.nvim
-- ABOUT :
--   Cargo.toml dependency management: shows the latest version next to every dependency,
--   flags outdated / yanked / invalid versions, completes crate names, versions and feature
--   flags, and offers code actions to upgrade. Runs as a small in-process LSP, so the usual
--   keys already work in Cargo.toml: K (hover: versions, features, docs) and <leader>ca
--   (code actions: upgrade, enable feature, open docs.rs / crates.io).
--
--   Only loads when a Cargo.toml is opened. Needs network access to reach crates.io.
-- LINKS :
--   > github : https://github.com/saecki/crates.nvim
-- ================================================================================================

local function crates(fn)
	return function()
		require("crates")[fn]()
	end
end

return {
	"saecki/crates.nvim",
	tag = "stable",
	event = { "BufRead Cargo.toml" },

	opts = {
		popup = { border = "rounded" },
		completion = {
			crates = { enabled = true }, -- complete crate names, not just versions
		},
		lsp = {
			enabled = true,
			actions = true,
			completion = true, -- surfaces through nvim-cmp's LSP source
			hover = true,
		},
	},

	config = function(_, opts)
		require("crates").setup(opts)

		-- Buffer-local extras on Cargo.toml, under the existing <leader>c… (code) group.
		local function set_keys(buf)
			local function map(lhs, fn, desc)
				vim.keymap.set("n", lhs, crates(fn), { buffer = buf, desc = desc })
			end
			map("<leader>cu", "upgrade_crate", "Crates: upgrade crate")
			map("<leader>cU", "upgrade_all_crates", "Crates: upgrade all")
			map("<leader>cf", "show_features_popup", "Crates: features")
			map("<leader>cv", "show_versions_popup", "Crates: versions")
			map("<leader>co", "open_crates_io", "Crates: open on crates.io")
		end

		vim.api.nvim_create_autocmd("BufRead", {
			group = vim.api.nvim_create_augroup("user_crates_keys", { clear = true }),
			pattern = "Cargo.toml",
			callback = function(args)
				set_keys(args.buf)
			end,
		})

		-- The plugin itself loads on that same BufRead, after the autocmd above would have
		-- fired, so the Cargo.toml that triggered loading gets its keys here.
		local current = vim.api.nvim_get_current_buf()
		if vim.fs.basename(vim.api.nvim_buf_get_name(current)) == "Cargo.toml" then
			set_keys(current)
		end
	end,
}
