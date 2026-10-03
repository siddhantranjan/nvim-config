-- ================================================================================================
-- TITLE : grug-far.nvim
-- ABOUT :
--   Project-wide search & replace -- the equivalent of VS Code's search sidebar with the
--   replace box open. Runs ripgrep, shows every match in an editable buffer, previews the
--   replacement live, and applies it across files. Supports regex, capture groups, file
--   globs (`*.cpp`) and path filters.
--
--   Lives under <leader>r… (rename / replace). Inside the grug-far buffer, `g?` shows its
--   keys; the main ones are <localleader>r (replace all) and <localleader>s (sync edits).
-- LINKS :
--   > github : https://github.com/MagicDuck/grug-far.nvim
-- ================================================================================================

return {
	"MagicDuck/grug-far.nvim",
	cmd = { "GrugFar", "GrugFarWithin" },

	keys = {
		{
			"<leader>rg",
			function()
				require("grug-far").open()
			end,
			desc = "Replace in project",
		},
		{
			-- Ex-command form so the '< '> marks are set before grug-far reads them.
			"<leader>rg",
			":<C-u>lua require('grug-far').with_visual_selection()<cr>",
			mode = "x",
			desc = "Replace selection in project",
		},
		{
			"<leader>rG",
			function()
				require("grug-far").open({ prefills = { search = vim.fn.expand("<cword>") } })
			end,
			desc = "Replace word under cursor in project",
		},
		{
			"<leader>rf",
			function()
				-- The paths field is space-separated, so escape spaces in the file name.
				local path = vim.fn.expand("%"):gsub(" ", "\\ ")
				require("grug-far").open({ prefills = { paths = path } })
			end,
			desc = "Replace in current file",
		},
	},

	opts = {
		transient = true, -- unlisted, and wiped when closed: no stray buffers or session entries
	},
}
