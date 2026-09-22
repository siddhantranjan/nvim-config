-- ================================================================================================
-- TITLE : fzf-lua
-- ABOUT : Lua fzf wrapper -- the primary picker for files, grep, buffers and LSP results.
-- NOTE  : LSP pickers (<leader>fr, <leader>fs, …) are buffer-local and defined in
--         lua/utils/lsp.lua, so they only appear where a server is attached.
-- LINKS :
--   > github : https://github.com/ibhagwan/fzf-lua
-- ================================================================================================

return {
	"ibhagwan/fzf-lua",
	cmd = "FzfLua",
	dependencies = { "nvim-mini/mini.icons" },

	keys = {
		{ "<leader>ff", "<cmd>FzfLua files<cr>", desc = "Find files" },
		{ "<leader>fg", "<cmd>FzfLua live_grep_native<cr>", desc = "Live grep" },
		{ "<leader>fG", "<cmd>FzfLua grep_cword<cr>", desc = "Grep word under cursor" },
		{ "<leader>fb", "<cmd>FzfLua buffers<cr>", desc = "Buffers" },
		{ "<leader>fh", "<cmd>FzfLua helptags<cr>", desc = "Help tags" },
		{ "<leader>fk", "<cmd>FzfLua keymaps<cr>", desc = "Keymaps" },
		{ "<leader>fo", "<cmd>FzfLua oldfiles<cr>", desc = "Recent files" },
		{ "<leader>fq", "<cmd>FzfLua quickfix<cr>", desc = "Quickfix list" },
		{ "<leader>fR", "<cmd>FzfLua resume<cr>", desc = "Resume last picker" },
		{ "<leader>fx", "<cmd>FzfLua diagnostics_document<cr>", desc = "Diagnostics (document)" },
		{ "<leader>fX", "<cmd>FzfLua diagnostics_workspace<cr>", desc = "Diagnostics (workspace)" },
		{ "<leader>f/", "<cmd>FzfLua blines<cr>", desc = "Search in buffer" },
		{ "<leader>fC", "<cmd>FzfLua commands<cr>", desc = "Commands" },

		-- Git pickers live under <leader>g… with the rest of git.
		{ "<leader>gc", "<cmd>FzfLua git_commits<cr>", desc = "Git commits (repo)" },
		{ "<leader>gC", "<cmd>FzfLua git_bcommits<cr>", desc = "Git commits (buffer)" },
		{ "<leader>gl", "<cmd>FzfLua git_branches<cr>", desc = "Git branches" },
		{ "<leader>gz", "<cmd>FzfLua git_stash<cr>", desc = "Git stash" },

		{
			"<leader>fg",
			function()
				require("fzf-lua").grep_visual()
			end,
			mode = "v",
			desc = "Grep selection",
		},
	},

	opts = function()
		-- Every external tool below is OPTIONAL. fzf-lua has pure-Lua fallbacks for all of
		-- them, so a missing binary should degrade the experience, not break the picker
		-- with `sh: <tool>: command not found`.
		local have = function(bin)
			return vim.fn.executable(bin) == 1
		end

		return {
			"default-title",

			winopts = {
				height = 0.85,
				width = 0.85,
				row = 0.35,
				col = 0.50,
				border = "rounded",
				backdrop = 100, -- opaque; the transparent theme makes a dim backdrop unreadable
				preview = {
					-- `bat` gives syntax-highlighted previews, but it is not installed by
					-- default anywhere. "builtin" is fzf-lua's own previewer: it renders
					-- inside Neovim using treesitter, so it needs no external binary and
					-- actually matches the colorscheme better.
					default = have("bat") and "bat" or "builtin",
					border = "rounded",
					layout = "flex",
					flip_columns = 120,
					scrollbar = "float",
				},
			},

			keymap = {
				builtin = {
					["<C-f>"] = "preview-page-down",
					["<C-b>"] = "preview-page-up",
					["<F1>"] = "toggle-help",
					["<F2>"] = "toggle-fullscreen",
				},
				fzf = {
					["ctrl-q"] = "select-all+accept", -- send everything to the quickfix list
					["ctrl-f"] = "preview-page-down",
					["ctrl-b"] = "preview-page-up",
				},
			},

			files = {
				formatter = "path.filename_first", -- filename first, directory dimmed after
				git_icons = true,
				file_icons = true,
				-- Pick the best available file lister. fd is fastest and respects
				-- .gitignore; rg --files is a close second and is already a dependency
				-- via 'grepprg'. If neither exists fzf-lua falls back to `find` on its own.
				fd_opts = "--color=never --type f --hidden --follow "
					.. "--exclude .git --exclude node_modules",
				rg_opts = "--color=never --files --hidden --follow "
					.. "--glob=!.git/ --glob=!node_modules/",
			},

			grep = {
				rg_opts = table.concat({
					"--column --line-number --no-heading --color=always",
					"--smart-case --max-columns=4096",
					"--hidden --glob=!.git/ --glob=!node_modules/",
				}, " "),
			},

			lsp = {
				jump1 = true, -- a single result jumps straight there instead of opening a picker
				includeDeclaration = false,
				symbols = { symbol_style = 1 },
			},

			diagnostics = { multiline = false },
		}
	end,
}
