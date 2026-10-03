-- ================================================================================================
-- TITLE : toggleterm.nvim
-- ABOUT :
--   Integrated terminal. <C-/> toggles it from normal, insert or terminal mode (like VS Code's
--   Ctrl+`); <leader>t… opens a specific layout. Prefix a count to get a separate terminal:
--   `2<leader>th` opens terminal #2.
--
--   Inside a terminal: <Esc><Esc> drops to normal mode (a single <Esc> still reaches the
--   program, so vim/lazygit/fzf inside the terminal keep working), then <C-h/j/k/l> moves
--   between windows as usual.
--
--   Also used by lua/utils/runner.lua (<leader>ex) and cmake-tools.nvim to run programs.
-- LINKS :
--   > github : https://github.com/akinsho/toggleterm.nvim
-- ================================================================================================

local function toggle(direction)
	return function()
		vim.cmd(("%dToggleTerm direction=%s"):format(vim.v.count1, direction))
	end
end

return {
	"akinsho/toggleterm.nvim",
	version = "*",
	cmd = { "ToggleTerm", "ToggleTermToggleAll", "TermExec", "TermSelect", "TermNew" },

	keys = {
		-- Most terminals send <C-_> for Ctrl+/, so map both.
		{ "<C-/>", toggle("horizontal"), mode = { "n", "i", "t" }, desc = "Toggle terminal" },
		{ "<C-_>", toggle("horizontal"), mode = { "n", "i", "t" }, desc = "which_key_ignore" },

		{ "<leader>tt", toggle("float"), desc = "Terminal (float)" },
		{ "<leader>th", toggle("horizontal"), desc = "Terminal (horizontal)" },
		{ "<leader>tv", toggle("vertical"), desc = "Terminal (vertical)" },
		{ "<leader>tT", toggle("tab"), desc = "Terminal (tab)" },
		{ "<leader>ta", "<cmd>ToggleTermToggleAll<cr>", desc = "Toggle all terminals" },
		{ "<leader>ts", "<cmd>TermSelect<cr>", desc = "Select terminal" },
		{ "<leader>tl", "<cmd>ToggleTermSendCurrentLine<cr>", desc = "Send line to terminal" },
		{
			"<leader>tl",
			":ToggleTermSendVisualSelection<cr>",
			mode = "x",
			desc = "Send selection to terminal",
		},
	},

	opts = {
		size = function(term)
			if term.direction == "horizontal" then
				return math.max(12, math.floor(vim.o.lines * 0.3))
			elseif term.direction == "vertical" then
				return math.floor(vim.o.columns * 0.4)
			end
		end,
		-- No open_mapping: the <C-/> keys above already cover n/i/t modes, and lazy.nvim
		-- needs them declared there to load the plugin on first press.
		shade_terminals = false, -- the colorscheme is transparent; shading looks like a smear
		start_in_insert = true,
		persist_mode = true, -- reopen in whichever mode the terminal was left in
		persist_size = true,
		close_on_exit = true,
		float_opts = {
			border = "rounded",
			width = function()
				return math.floor(vim.o.columns * 0.85)
			end,
			height = function()
				return math.floor(vim.o.lines * 0.8)
			end,
		},
		on_open = function(term)
			vim.keymap.set("t", "<Esc><Esc>", [[<C-\><C-n>]], {
				buffer = term.bufnr,
				desc = "Terminal: normal mode",
			})
		end,
	},
}
