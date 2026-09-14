-- ================================================================================================
-- TITLE : lualine.nvim
-- LINKS :
--   > github : https://github.com/nvim-lualine/lualine.nvim
-- ABOUT : A blazing fast and easy to configure Neovim statusline written in Lua.
-- ================================================================================================

return {
	"nvim-lualine/lualine.nvim",
	dependencies = {
		"nvim-tree/nvim-web-devicons",
	},

	config = function()
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

		require("lualine").setup({
			options = {
				theme = "auto",
				icons_enabled = true,
				section_separators = { left = "", right = "" },
				component_separators = { left = "|", right = "|" },
			},
			sections = {
				lualine_x = {
					{
						flutter_status,
						cond = function()
							return vim.bo.filetype == "dart"
						end,
					},
					"encoding",
					"fileformat",
					"filetype",
				},
			},
		})
	end,
}
