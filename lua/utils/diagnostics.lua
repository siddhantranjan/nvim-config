-- ================================================================================================
-- TITLE : diagnostics
-- ABOUT : Signs, virtual text, float styling and severity sorting for vim.diagnostic.
-- NOTE  : Glyphs come from lua/utils/icons.lua as \u{...} escapes -- see the explanation in
--         that file for why they are not written literally.
-- ================================================================================================

local icons = require("utils.icons")

local M = {}

local sign_text = {
	[vim.diagnostic.severity.ERROR] = icons.diagnostics.error,
	[vim.diagnostic.severity.WARN] = icons.diagnostics.warn,
	[vim.diagnostic.severity.INFO] = icons.diagnostics.info,
	[vim.diagnostic.severity.HINT] = icons.diagnostics.hint,
}

local virtual_text = {
	severity = { min = vim.diagnostic.severity.WARN },
	spacing = 2,
	prefix = icons.misc.dot,
	source = "if_many",
}

M.setup = function()
	vim.diagnostic.config({
		signs = {
			text = sign_text,
			numhl = {
				[vim.diagnostic.severity.ERROR] = "DiagnosticSignError",
				[vim.diagnostic.severity.WARN] = "DiagnosticSignWarn",
			},
		},

		-- Inline text only for errors and warnings -- hints and info on every line turn
		-- the buffer into noise. The full message is always one <leader>k away.
		virtual_text = virtual_text,

		float = {
			border = "rounded",
			source = "if_many",
			header = "",
			prefix = "",
			focusable = false,
		},

		underline = { severity = { min = vim.diagnostic.severity.HINT } },
		update_in_insert = false, -- don't re-lint mid-keystroke
		severity_sort = true, -- errors win the sign column over warnings
	})

	-- Toggle virtual text when it gets in the way, without losing signs or the float.
	vim.keymap.set("n", "<leader>cd", function()
		local shown = vim.diagnostic.config().virtual_text ~= false
		vim.diagnostic.config({ virtual_text = shown and false or virtual_text })
		vim.notify("Diagnostic virtual text " .. (shown and "hidden" or "shown"), vim.log.levels.INFO)
	end, { desc = "Toggle diagnostic virtual text" })
end

return M
