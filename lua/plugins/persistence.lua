-- ================================================================================================
-- TITLE : persistence.nvim
-- ABOUT :
--   Sessions -- reopen a project the way you left it (buffers, splits, tabs, cwd), like
--   VS Code does when you reopen a folder. One session per directory, and per git branch.
--
--   * Saved automatically on exit once at least one real file was opened.
--   * Restored automatically when Neovim starts with no file arguments (`nvim` in a project
--     directory). `nvim main.rs`, `nvim .` and piped stdin are left alone.
--   * <leader>w… for manual control. <leader>wd stops saving for this run, e.g. before
--     quitting from a throwaway layout you don't want remembered.
--
--   What gets saved is controlled by 'sessionoptions' in lua/config/options.lua.
-- LINKS :
--   > github : https://github.com/folke/persistence.nvim
-- ================================================================================================

return {
	"folke/persistence.nvim",
	event = "BufReadPre", -- start tracking as soon as a real file is opened
	opts = {},

	keys = {
		{
			"<leader>ws",
			function()
				require("persistence").load()
			end,
			desc = "Restore session (this directory)",
		},
		{
			"<leader>wl",
			function()
				require("persistence").load({ last = true })
			end,
			desc = "Restore last session",
		},
		{
			"<leader>wS",
			function()
				require("persistence").select()
			end,
			desc = "Select session",
		},
		{
			"<leader>wd",
			function()
				require("persistence").stop()
				vim.notify("Session will not be saved on exit", vim.log.levels.INFO)
			end,
			desc = "Don't save this session",
		},
	},

	init = function()
		local group = vim.api.nvim_create_augroup("user_session_restore", { clear = true })

		vim.api.nvim_create_autocmd("StdinReadPre", {
			group = group,
			callback = function()
				vim.g.started_with_stdin = true
			end,
		})

		vim.api.nvim_create_autocmd("VimEnter", {
			group = group,
			nested = true, -- so restored buffers fire FileType/BufRead (treesitter, LSP, ...)
			callback = function()
				if vim.fn.argc(-1) > 0 or vim.g.started_with_stdin then
					return
				end
				-- load() is a no-op when this directory has no saved session.
				require("persistence").load()
			end,
		})
	end,
}
