-- ================================================================================================
-- TITLE : lualine.nvim
-- ABOUT :
--   Statusline. Deliberately does NOT show a winbar -- dropbar.nvim owns the top of the
--   window (path + current function). This keeps the two from fighting over vim.wo.winbar.
-- LINKS :
--   > github : https://github.com/nvim-lualine/lualine.nvim
-- ================================================================================================

return {
	"nvim-lualine/lualine.nvim",
	event = "VeryLazy",
	dependencies = { "nvim-mini/mini.icons" },

	config = function()
		local icons = require("utils.icons")

		-- flutter-tools publishes device / flavour / version into a global table.
		local function flutter_status()
			local decorations = vim.g.flutter_tools_decorations
			if type(decorations) ~= "table" then
				return ""
			end

			local status = {}
			for _, key in ipairs({ "device", "project_config", "app_version" }) do
				local value = decorations[key]
				if value and value ~= "" then
					table.insert(status, value)
				end
			end

			return table.concat(status, " | ")
		end

		-- Names of attached language servers, so it's obvious when one failed to start.
		local function lsp_clients()
			local clients = vim.lsp.get_clients({ bufnr = 0 })
			if #clients == 0 then
				return ""
			end

			local names = {}
			for _, client in ipairs(clients) do
				-- efm is a linter bridge, not something worth a slot in the statusline.
				if client.name ~= "efm" then
					table.insert(names, client.name)
				end
			end

			if #names == 0 then
				return ""
			end

			return table.concat(names, ", ")
		end

		-- Whether format-on-save is currently suppressed (see conform.lua, <leader>ct).
		local function format_status()
			if vim.g.disable_autoformat or vim.b.disable_autoformat then
				return icons.lsp.format_off
			end
			return ""
		end

		require("lualine").setup({
			options = {
				theme = "auto",
				icons_enabled = true,
				globalstatus = true, -- one statusline for the whole editor, not per split
				section_separators = { left = icons.separators.left, right = icons.separators.right },
				component_separators = { left = "|", right = "|" },
				disabled_filetypes = {
					statusline = { "alpha", "dashboard" },
					winbar = {},
				},
			},

			sections = {
				lualine_a = { "mode" },
				lualine_b = {
					{ "branch", icon = icons.git.branch },
					{
						"diff",
						symbols = {
							added = icons.git.added,
							modified = icons.git.modified,
							removed = icons.git.removed,
						},
					},
				},
				lualine_c = {
					{
						"filename",
						path = 1, -- relative path
						symbols = {
							modified = " " .. icons.misc.dot,
							readonly = " " .. icons.file.readonly,
							unnamed = icons.file.unnamed,
						},
					},
					{
						"diagnostics",
						sources = { "nvim_diagnostic" },
						symbols = {
							error = icons.diagnostics.error,
							warn = icons.diagnostics.warn,
							info = icons.diagnostics.info,
							hint = icons.diagnostics.hint,
						},
					},
				},
				lualine_x = {
					{ format_status, color = { fg = "#d19a66" } },
					{
						flutter_status,
						cond = function()
							return vim.bo.filetype == "dart"
						end,
					},
					{ lsp_clients, icon = icons.lsp.server },
					"encoding",
					"fileformat",
					"filetype",
				},
				lualine_y = { "progress" },
				lualine_z = { "location" },
			},

			extensions = { "lazy", "mason", "oil", "quickfix", "trouble", "fugitive", "nvim-dap-ui" },
		})
	end,
}
