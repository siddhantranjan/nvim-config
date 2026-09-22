-- ================================================================================================
-- TITLE : nvim-treesitter
-- ABOUT : Treesitter configurations and abstraction layer for Neovim.
-- NOTES :
--   Pinned to branch "main" (the rewritten API). `get_installed()` takes a type argument:
--   with no argument it returns the union of the `parser/` AND `queries/` install dirs, so
--   a language that has queries but no compiled parser looks installed. It then never gets
--   installed, and `vim.treesitter.start` fails on it -- silently, since the call is
--   wrapped in pcall. Always pass "parsers".
-- LINKS :
--   > github : https://github.com/nvim-treesitter/nvim-treesitter
-- ================================================================================================

return {
	{
		"nvim-treesitter/nvim-treesitter",
		branch = "main",
		build = ":TSUpdate",
		lazy = false, -- parsers must be queryable before the first FileType fires
		priority = 500,
		config = function()
			local treesitter = require("nvim-treesitter")
			local ts_config = require("nvim-treesitter.config")

			treesitter.setup({})

			local ensure_installed = {
				"bash",
				"c",
				"cpp",
				"css",
				"dart",
				"diff",
				"dockerfile",
				"git_config",
				"git_rebase",
				"gitcommit",
				"gitignore",
				"go",
				"gomod",
				"html",
				"javascript",
				"jsdoc",
				"json",
				"jsonc",
				"lua",
				"luadoc",
				"markdown",
				"markdown_inline",
				"python",
				"query",
				"regex",
				"ruby",
				"rust",
				"solidity",
				"svelte",
				"swift",
				"toml",
				"tsx",
				"typescript",
				"vim",
				"vimdoc",
				"vue",
				"yaml",
			}

			local already_installed = ts_config.get_installed("parsers")
			local parsers_to_install = {}

			for _, parser in ipairs(ensure_installed) do
				if not vim.tbl_contains(already_installed, parser) then
					table.insert(parsers_to_install, parser)
				end
			end

			if #parsers_to_install > 0 then
				treesitter.install(parsers_to_install)
			end

			-- Start highlighting + indent for any buffer whose language has a parser.
			local group = vim.api.nvim_create_augroup("TreeSitterConfig", { clear = true })
			vim.api.nvim_create_autocmd("FileType", {
				group = group,
				callback = function(args)
					local lang = vim.treesitter.language.get_lang(args.match)
					if not lang then
						return
					end

					if not vim.list_contains(ts_config.get_installed("parsers"), lang) then
						return
					end

					pcall(vim.treesitter.start, args.buf)
					vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
				end,
			})
		end,
	},

	-- Treesitter-aware text objects: `vaf` (a function), `vic` (inner class), `]f`/`[f` to
	-- jump between functions, etc. Complements mini.ai rather than replacing it.
	{
		"nvim-treesitter/nvim-treesitter-textobjects",
		branch = "main",
		event = { "BufReadPost", "BufNewFile" },
		dependencies = { "nvim-treesitter/nvim-treesitter" },
		config = function()
			require("nvim-treesitter-textobjects").setup({
				select = { lookahead = true },
				move = { set_jumps = true },
			})

			local select = require("nvim-treesitter-textobjects.select")
			local move = require("nvim-treesitter-textobjects.move")

			-- Only `f` (function) and `c` (class) are claimed here. `a` (argument) and
			-- `l` (last) are mini.ai's own defaults, and loops/conditionals/blocks are
			-- reachable via mini.ai's `o` spec -- see lua/plugins/mini-nvim.lua. Binding
			-- them in both places means whichever plugin loads second wins, and the load
			-- order differs depending on whether nvim was opened with a file.
			local objects = {
				["af"] = "@function.outer",
				["if"] = "@function.inner",
				["ac"] = "@class.outer",
				["ic"] = "@class.inner",
			}

			for key, query in pairs(objects) do
				vim.keymap.set({ "x", "o" }, key, function()
					select.select_textobject(query, "textobjects")
				end, { desc = "Textobject " .. query })
			end

			-- NOTE on the letters chosen: `]c`/`[c` belong to gitsigns (hunks) and
			-- `]t`/`[t` to todo-comments, so classes get `]C`/`[C`.
			local moves = {
				{ "]f", move.goto_next_start, "@function.outer", "Next function" },
				{ "[f", move.goto_previous_start, "@function.outer", "Prev function" },
				{ "]C", move.goto_next_start, "@class.outer", "Next class" },
				{ "[C", move.goto_previous_start, "@class.outer", "Prev class" },
				{ "]A", move.goto_next_start, "@parameter.inner", "Next parameter" },
				{ "[A", move.goto_previous_start, "@parameter.inner", "Prev parameter" },
			}

			for _, m in ipairs(moves) do
				local lhs, fn, query, desc = m[1], m[2], m[3], m[4]
				vim.keymap.set({ "n", "x", "o" }, lhs, function()
					fn(query, "textobjects")
				end, { desc = desc })
			end
		end,
	},
}
