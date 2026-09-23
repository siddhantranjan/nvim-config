-- ================================================================================================
-- TITLE : GitHub Copilot
-- ABOUT :
--   Inline suggestions (copilot.lua) + conversational assistance (CopilotChat.nvim).
--
-- KEY NOTE
--   Copilot's ghost text and nvim-cmp's popup are two separate UIs in the same mode, so they
--   must not share keys. Copilot originally bound accept to <C-y> and dismiss to <C-e> --
--   exactly nvim-cmp's confirm and abort.
--
--   The obvious fix is to move Copilot onto <M-…> (Alt), and that is what most configs do.
--   It does NOT work in Warp: Warp's "Option key is Meta" setting is broken (it treats both
--   Option keys as Meta regardless of the setting, and enabling it breaks Option+arrow word
--   navigation) -- see warpdotdev/warp#8583 and #2364. So these are all Ctrl-based keys that
--   every terminal transmits reliably:
--
--     <C-l>     accept suggestion       <C-y> / <CR>  confirm cmp item
--     <C-]>     dismiss suggestion      <C-e>         abort cmp
--     <C-Down>  next suggestion
--     <C-Up>    previous suggestion
--
--   <C-l> is free in insert mode -- vim-tmux-navigator's <C-l> is normal-mode only, and
--   oil's is buffer-local. <C-Up>/<C-Down> are likewise only mapped in normal mode here
--   (window resizing). <C-[> is deliberately absent: it IS Escape.
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
					accept = "<C-l>",
					accept_word = false,
					accept_line = false,
					next = "<C-Down>",
					prev = "<C-Up>",
					dismiss = "<C-]>",
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
