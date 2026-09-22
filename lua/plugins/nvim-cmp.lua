-- ================================================================================================
-- TITLE : nvim-cmp
-- ABOUT :
--   Completion engine. Sources are ordered and grouped by priority -- LSP first, then
--   snippets, then buffer words and paths as a last resort.
--
-- NOTE
--   The `codeium` source and its lspkind entry were removed: Codeium is not installed in
--   this config, so nvim-cmp was being handed a source name it could never resolve.
--   Copilot is the AI completion here and renders as ghost text, not as a cmp source.
-- LINKS :
--   > github                            : https://github.com/hrsh7th/nvim-cmp
--   > lspkind (dep)                     : https://github.com/onsails/lspkind.nvim
--   > cmp_luasnip (dep)                 : https://github.com/saadparwaiz1/cmp_luasnip
--   > luasnip (dep)                     : https://github.com/L3MON4D3/LuaSnip
--   > friendly-snippets (dep)           : https://github.com/rafamadriz/friendly-snippets
--   > cmp-nvim-lsp (dep)                : https://github.com/hrsh7th/cmp-nvim-lsp
--   > cmp-buffer (dep)                  : https://github.com/hrsh7th/cmp-buffer
--   > cmp-path (dep)                    : https://github.com/hrsh7th/cmp-path
--   > cmp-cmdline (dep)                 : https://github.com/hrsh7th/cmp-cmdline
--   > cmp-nvim-lsp-signature-help (dep) : https://github.com/hrsh7th/cmp-nvim-lsp-signature-help
-- ================================================================================================

return {
	"hrsh7th/nvim-cmp",
	event = { "InsertEnter", "CmdlineEnter" },
	dependencies = {
		"onsails/lspkind.nvim",
		"saadparwaiz1/cmp_luasnip",
		{
			"L3MON4D3/LuaSnip",
			version = "v2.*",
			build = "make install_jsregexp",
			dependencies = { "rafamadriz/friendly-snippets" },
		},
		"hrsh7th/cmp-nvim-lsp",
		"hrsh7th/cmp-buffer",
		"hrsh7th/cmp-path",
		"hrsh7th/cmp-cmdline",
		"hrsh7th/cmp-nvim-lsp-signature-help",
	},

	config = function()
		local cmp = require("cmp")
		local luasnip = require("luasnip")
		local lspkind = require("lspkind")

		require("luasnip.loaders.from_vscode").lazy_load()

		local function has_words_before()
			local line, col = unpack(vim.api.nvim_win_get_cursor(0))
			if col == 0 then
				return false
			end
			local text = vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]
			return text:sub(col, col):match("%s") == nil
		end

		cmp.setup({
			snippet = {
				expand = function(args)
					luasnip.lsp_expand(args.body)
				end,
			},

			window = {
				completion = cmp.config.window.bordered({ border = "rounded" }),
				documentation = cmp.config.window.bordered({ border = "rounded" }),
			},

			formatting = {
				fields = { "kind", "abbr", "menu" },
				expandable_indicator = true,
				format = lspkind.cmp_format({
					mode = "symbol_text",
					maxwidth = 50,
					ellipsis_char = "…",
					menu = {
						nvim_lsp = "[LSP]",
						luasnip = "[Snip]",
						buffer = "[Buf]",
						path = "[Path]",
						nvim_lsp_signature_help = "[Sig]",
					},
				}),
			},

			mapping = cmp.mapping.preset.insert({
				["<C-k>"] = cmp.mapping.select_prev_item(),
				["<C-j>"] = cmp.mapping.select_next_item(),
				["<C-b>"] = cmp.mapping.scroll_docs(-4),
				["<C-f>"] = cmp.mapping.scroll_docs(4),
				["<C-Space>"] = cmp.mapping.complete(),
				["<C-e>"] = cmp.mapping.abort(),
				-- `select = false` means <CR> only confirms an item you explicitly
				-- selected, so a stray Enter inserts a newline rather than a symbol.
				["<CR>"] = cmp.mapping.confirm({ select = false }),

				-- Tab drives snippet jumps and menu navigation, but falls through to a
				-- literal Tab at the start of a line so indentation still works.
				["<Tab>"] = cmp.mapping(function(fallback)
					if cmp.visible() then
						cmp.select_next_item()
					elseif luasnip.locally_jumpable(1) then
						luasnip.jump(1)
					elseif has_words_before() then
						cmp.complete()
					else
						fallback()
					end
				end, { "i", "s" }),

				["<S-Tab>"] = cmp.mapping(function(fallback)
					if cmp.visible() then
						cmp.select_prev_item()
					elseif luasnip.locally_jumpable(-1) then
						luasnip.jump(-1)
					else
						fallback()
					end
				end, { "i", "s" }),
			}),

			-- Grouped sources: group 2 is only consulted when group 1 yields nothing,
			-- which keeps buffer-word noise out of LSP results.
			sources = cmp.config.sources({
				{ name = "nvim_lsp", priority = 1000 },
				{ name = "luasnip", priority = 750 },
				{ name = "nvim_lsp_signature_help", priority = 700 },
			}, {
				{ name = "buffer", priority = 500, keyword_length = 3 },
				{ name = "path", priority = 250 },
			}),

			sorting = {
				comparators = {
					cmp.config.compare.offset,
					cmp.config.compare.exact,
					cmp.config.compare.score,
					cmp.config.compare.recently_used,
					cmp.config.compare.locality,
					cmp.config.compare.kind,
					cmp.config.compare.length,
					cmp.config.compare.order,
				},
			},

			experimental = {
				ghost_text = false, -- Copilot already draws ghost text; two would overlap
			},
		})

		-- `/` and `?` search completion from the current buffer.
		cmp.setup.cmdline({ "/", "?" }, {
			mapping = cmp.mapping.preset.cmdline(),
			sources = { { name = "buffer" } },
		})

		-- `:` command completion.
		cmp.setup.cmdline(":", {
			mapping = cmp.mapping.preset.cmdline(),
			sources = cmp.config.sources({
				{ name = "path" },
			}, {
				{ name = "cmdline", option = { ignore_cmds = { "Man", "!" } } },
			}),
		})
	end,
}
