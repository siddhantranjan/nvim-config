-- ================================================================================================
-- TITLE : GitHub Copilot
-- ABOUT :
--   Inline suggestions (copilot.lua) + conversational assistance (CopilotChat.nvim).
--
-- KEY NOTE
--   Copilot's ghost text and nvim-cmp's popup are two separate UIs in the same mode, so they
--   must not share keys. This config previously bound Copilot accept to <C-y> and dismiss to
--   <C-e> -- exactly the keys nvim-cmp's `preset.insert` uses for confirm and abort. Copilot
--   now lives on <M-…> (Alt) so the two never contend:
--
--     <M-l>  accept suggestion        <C-y> / <CR>  confirm cmp item
--     <M-;>  accept one word          <C-e>         abort cmp
--     <M-]>  next suggestion
--     <M-[>  previous suggestion
--     <M-h>  dismiss suggestion
-- LINKS :
--   > copilot.lua     : https://github.com/zbirenbaum/copilot.lua
--   > CopilotChat.nvim: https://github.com/CopilotC-Nvim/CopilotChat.nvim
-- ================================================================================================

return {
	{
		"zbirenbaum/copilot.lua",
		cmd = "Copilot",
		event = "InsertEnter",
		opts = {
			suggestion = {
				enabled = true,
				auto_trigger = true,
				hide_during_completion = true, -- get out of the way while cmp is open
				debounce = 75,
				keymap = {
					accept = "<M-l>",
					accept_word = "<M-;>",
					accept_line = false,
					next = "<M-]>",
					prev = "<M-[>",
					dismiss = "<M-h>",
				},
			},

			panel = { enabled = false },

			filetypes = {
				-- Don't send these to Copilot.
				gitcommit = false,
				gitrebase = false,
				hgcommit = false,
				svn = false,
				cvs = false,
				["."] = false,
				["dap-repl"] = false,
			},
		},
	},

	{
		"CopilotC-Nvim/CopilotChat.nvim",
		cmd = {
			"CopilotChat",
			"CopilotChatOpen",
			"CopilotChatToggle",
			"CopilotChatExplain",
			"CopilotChatFix",
			"CopilotChatOptimize",
			"CopilotChatTests",
			"CopilotChatReview",
			"CopilotChatCommit",
		},
		dependencies = {
			"zbirenbaum/copilot.lua",
			"nvim-lua/plenary.nvim",
		},
		build = "make tiktoken",

		opts = {
			debug = false,
			model = "gpt-4o",
			window = {
				layout = "vertical",
				width = 0.35,
				border = "rounded",
			},
			mappings = {
				reset = { normal = "<C-r>", insert = "<C-r>" },
			},
		},

		keys = {
			{ "<leader>cc", "<cmd>CopilotChatToggle<cr>", mode = { "n", "v" }, desc = "Copilot: toggle chat" },
			{ "<leader>ce", "<cmd>CopilotChatExplain<cr>", mode = { "n", "v" }, desc = "Copilot: explain" },
			{ "<leader>cf", "<cmd>CopilotChatFix<cr>", mode = { "n", "v" }, desc = "Copilot: fix" },
			{ "<leader>co", "<cmd>CopilotChatOptimize<cr>", mode = { "n", "v" }, desc = "Copilot: optimize" },
			{ "<leader>cu", "<cmd>CopilotChatTests<cr>", mode = { "n", "v" }, desc = "Copilot: generate tests" },
			{ "<leader>cv", "<cmd>CopilotChatReview<cr>", mode = { "n", "v" }, desc = "Copilot: review" },
			{ "<leader>cm", "<cmd>CopilotChatCommit<cr>", desc = "Copilot: commit message" },
			{
				"<leader>cq",
				function()
					local input = vim.fn.input("Copilot: ")
					if input ~= "" then
						require("CopilotChat").ask(input)
					end
				end,
				mode = { "n", "v" },
				desc = "Copilot: quick question",
			},
		},
	},
}
