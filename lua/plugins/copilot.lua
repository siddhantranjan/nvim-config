return {
	-- Copilot (core)
	{
		"nvim-lua/plenary.nvim",
	},
	{
		"zbirenbaum/copilot.lua",
		event = "InsertEnter",
		cmd = "Copilot",
		config = function()
			require("copilot").setup({
				suggestion = {
					enabled = true,
					auto_trigger = true,
					keymap = {
						accept = "<M-l>", -- accept suggestion
						next = "<M-]>",
						prev = "<M-[>",
					},
				},
				panel = {
					enabled = false,
				},
			})
		end,
	},

	-- Copilot Chat
	{
		"CopilotC-Nvim/CopilotChat.nvim",
		dependencies = { "zbirenbaum/copilot.lua" },
		build = "make tiktoken",
		config = function()
			require("CopilotChat").setup({
				debug = false,
			})

			-- Keymaps
			vim.keymap.set("n", "<leader>cc", "<cmd>CopilotChat<CR>", { desc = "Copilot Chat" })
			vim.keymap.set("v", "<leader>cc", "<cmd>CopilotChat<CR>", { desc = "Copilot Chat (selection)" })

			vim.keymap.set("n", "<leader>ce", "<cmd>CopilotChatExplain<CR>", { desc = "Explain code" })
			vim.keymap.set("v", "<leader>ce", "<cmd>CopilotChatExplain<CR>", { desc = "Explain selection" })

			vim.keymap.set("n", "<leader>cf", "<cmd>CopilotChatFix<CR>", { desc = "Fix code" })
			vim.keymap.set("v", "<leader>cf", "<cmd>CopilotChatFix<CR>", { desc = "Fix selection" })

			vim.keymap.set("n", "<leader>co", "<cmd>CopilotChatOptimize<CR>", { desc = "Optimize code" })
			vim.keymap.set("v", "<leader>co", "<cmd>CopilotChatOptimize<CR>", { desc = "Optimize selection" })
		end,
	},
}
