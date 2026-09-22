-- ================================================================================================
-- TITLE : dropbar.nvim
-- ABOUT :
--   IDE-style winbar across the top of every window: the file's path, then the symbol trail
--   down to whatever function/class/method the cursor is currently inside.
--
--     lua  plugins  dropbar.lua   config   setup()
--
--   Every segment is interactive. `<leader>;` enters pick mode -- each segment gets a letter,
--   press it to open that level's dropdown (and `i` inside a dropdown to fuzzy-find). So the
--   bar doubles as a symbol navigator.
--
--   Sources are tried in order: LSP documentSymbol first, treesitter as fallback, so the
--   function name still shows in buffers where no language server is attached.
-- LINKS :
--   > github : https://github.com/Bekaboo/dropbar.nvim
-- ================================================================================================

return {
	"Bekaboo/dropbar.nvim",
	event = { "BufReadPost", "BufNewFile" },
	dependencies = {
		"nvim-mini/mini.icons",
		{
			-- Supplies the `fzf_lib` module that dropbar's menu fuzzy-find (`i` inside a
			-- dropdown) requires -- without it that keypress reports "fzf-lib is not
			-- installed". It's a C library, so `make` compiles it on install; everything
			-- else in dropbar works fine if the build fails.
			-- telescope.nvim is already here (xcodebuild depends on it), so this also
			-- speeds up telescope's own sorting.
			"nvim-telescope/telescope-fzf-native.nvim",
			build = "make",
		},
	},

	config = function()
		local dropbar = require("dropbar")
		local utils = require("dropbar.utils")
		local glyphs = require("utils.icons")

		-- Filetypes where a breadcrumb bar is noise rather than signal.
		local exclude_filetypes = {
			"DressingInput",
			"DressingSelect",
			"NvimTree",
			"TelescopePrompt",
			"alpha",
			"checkhealth",
			"dap-repl",
			"dapui_breakpoints",
			"dapui_console",
			"dapui_scopes",
			"dapui_stacks",
			"dapui_watches",
			"diff",
			"fugitive",
			"fzf",
			"gitcommit",
			"gitrebase",
			"help",
			"lazy",
			"lspsagafinder",
			"mason",
			"netrw",
			"oil",
			"qf",
			"snacks_dashboard",
			"toggleterm",
			"trouble",
			"undotree",
		}

		dropbar.setup({
			bar = {
				enable = function(buf, win, _)
					if not vim.api.nvim_buf_is_valid(buf) or not vim.api.nvim_win_is_valid(win) then
						return false
					end

					-- Skip floats, popups, command windows, preview windows.
					if vim.fn.win_gettype(win) ~= "" then
						return false
					end

					-- Diff splits are already visually busy and the bar eats a line
					-- from both sides.
					if vim.wo[win].diff then
						return false
					end

					-- Only real file buffers.
					if vim.bo[buf].buftype ~= "" then
						return false
					end

					if vim.tbl_contains(exclude_filetypes, vim.bo[buf].filetype) then
						return false
					end

					local name = vim.api.nvim_buf_get_name(buf)
					if name == "" then
						return false
					end

					-- Parsing symbols for a huge file is slow and rarely useful.
					local stat = vim.uv.fs_stat(name)
					if stat and stat.size > 1024 * 1024 then
						return false
					end

					-- Require *some* source of structure: a treesitter parser or an
					-- LSP that answers documentSymbol. Otherwise the bar would just
					-- repeat the path already visible in the statusline.
					local has_parser = (function()
						local ok, parser = pcall(vim.treesitter.get_parser, buf)
						return ok and parser ~= nil
					end)()

					if has_parser or vim.bo[buf].filetype == "markdown" then
						return true
					end

					return not vim.tbl_isempty(vim.lsp.get_clients({
						bufnr = buf,
						method = "textDocument/documentSymbol",
					}))
				end,

				sources = function(buf, _)
					local sources = require("dropbar.sources")

					-- Markdown gets a heading trail instead of a symbol trail.
					if vim.bo[buf].filetype == "markdown" then
						return { sources.path, sources.markdown }
					end

					return {
						sources.path,
						utils.source.fallback({
							sources.lsp,
							sources.treesitter,
						}),
					}
				end,

				padding = { left = 1, right = 1 },
				truncate = true,
				update_debounce = 32,
			},

			icons = {
				enable = true,
				ui = {
					bar = {
						separator = " " .. glyphs.separators.thin .. " ",
						extends = glyphs.misc.ellipsis,
					},
				},
			},

			sources = {
				path = {
					-- Show the path relative to the project root rather than $HOME, so
					-- the bar reads as a position inside the project.
					relative_to = function(buf, win)
						for _, client in ipairs(vim.lsp.get_clients({ bufnr = buf })) do
							if client.root_dir then
								return client.root_dir
							end
						end

						local root = vim.fs.root(buf, { ".git", "Cargo.toml", "go.mod", "pubspec.yaml" })
						if root then
							return root
						end

						local ok, cwd = pcall(vim.fn.getcwd, win)
						return ok and cwd or vim.fn.getcwd()
					end,
					max_depth = 4, -- keep the bar short on deeply nested files
				},

				lsp = { max_depth = 6 },
				treesitter = { max_depth = 6 },
			},

			menu = {
				preview = true,
				quick_navigation = true,
				win_configs = { border = "rounded" },
			},
		})

		vim.keymap.set("n", "<leader>;", function()
			require("dropbar.api").pick()
		end, { desc = "Winbar: pick symbol" })

		vim.keymap.set("n", "[;", function()
			require("dropbar.api").goto_context_start()
		end, { desc = "Winbar: go to context start" })

		vim.keymap.set("n", "];", function()
			require("dropbar.api").select_next_context()
		end, { desc = "Winbar: select next context" })
	end,
}
