local M = {}

M.on_attach = function(event)
	if not event.data then
		return
	end

	local ok, client = pcall(vim.lsp.get_client_by_id, event.data.client_id)

	if not ok or not client then
		return
	end
	local bufnr = event.buf
	local keymap = vim.keymap.set

	local opts = {
		noremap = true, -- prevent recursive mapping
		silent = true, -- don't print the command to the cli
		buffer = bufnr, -- restrict the keymap to the local buffer number
	}

	-- native neovim keymaps
	keymap("n", "<leader>gd", "<cmd>Lspsaga peek_definition<CR>", opts) -- goto definition
	keymap("n", "<leader>gD", "<cmd>Lspsaga goto_definition<CR>", opts) -- goto definition
	keymap("n", "<leader>gS", "<cmd>vsplit | Lspsaga goto_definition<CR>", opts) -- goto definition in split
	keymap("n", "<leader>ca", "<cmd>Lspsaga code_action<CR>", opts) -- Code actions
	keymap("n", "<leader>rn", "<cmd>Lspsaga rename<CR>", opts) -- Rename symbol
	keymap("n", "<leader>D", "<cmd>Lspsaga show_line_diagnostics<CR>", opts) -- Line diagnostics (float)
	keymap("n", "<leader>d", "<cmd>Lspsaga show_cursor_diagnostics<CR>", opts) -- Cursor diagnostics
	keymap("n", "<leader>pd", "<cmd>Lspsaga diagnostic_jump_prev<CR>", opts) -- previous diagnostic
	keymap("n", "<leader>nd", "<cmd>Lspsaga diagnostic_jump_next<CR>", opts) -- next diagnostic
	keymap("n", "K", "<cmd>Lspsaga hover_doc<CR>", opts) -- hover documentation

	-- fzf-lua keymaps
	keymap("n", "<leader>fd", "<cmd>FzfLua lsp_finder<CR>", opts) -- LSP Finder (definition + references)
	keymap("n", "<leader>fr", "<cmd>FzfLua lsp_references<CR>", opts) -- Show all references to the symbol under the cursor
	keymap("n", "<leader>ft", "<cmd>FzfLua lsp_typedefs<CR>", opts) -- Jump to the type definition of the symbol under the cursor
	keymap("n", "<leader>fs", "<cmd>FzfLua lsp_document_symbols<CR>", opts) -- List all symbols (functions, classes, etc.) in the current file
	keymap("n", "<leader>fw", "<cmd>FzfLua lsp_workspace_symbols<CR>", opts) -- Search for any symbol across the entire project/workspace
	keymap("n", "<leader>fi", "<cmd>FzfLua lsp_implementations<CR>", opts) -- Go to implementation

	-- Order Imports (if supported by the client LSP)
	if client:supports_method("textDocument/codeAction", bufnr) then
		keymap("n", "<leader>oi", function()
			vim.lsp.buf.code_action({
				context = {
					only = { "source.organizeImports" },
					diagnostics = {},
				},
				apply = true,
				bufnr = bufnr,
			})
			-- format after changing import order
			vim.defer_fn(function()
				vim.lsp.buf.format({ bufnr = bufnr })
			end, 50) -- slight delay to allow for the import order to go first
		end, opts)
	end

	-- Flutter/Dart workflow. These buffer-local mappings intentionally mirror the global Xcode
	-- mobile mappings so the same keys operate on the mobile toolchain for the current file.
	if client.name == "dartls" then
		keymap("n", "<leader>mr", "<cmd>FlutterRun<CR>", vim.tbl_extend("force", opts, { desc = "Flutter Run" }))
		keymap("n", "<leader>mD", "<cmd>FlutterDebug<CR>", vim.tbl_extend("force", opts, { desc = "Flutter Debug" }))
		keymap(
			"n",
			"<leader>mR",
			"<cmd>FlutterReload<CR>",
			vim.tbl_extend("force", opts, { desc = "Flutter Hot Reload" })
		)
		keymap(
			"n",
			"<leader>ms",
			"<cmd>FlutterRestart<CR>",
			vim.tbl_extend("force", opts, { desc = "Flutter Hot Restart" })
		)
		keymap("n", "<leader>mq", "<cmd>FlutterQuit<CR>", vim.tbl_extend("force", opts, { desc = "Flutter Quit" }))
		keymap(
			"n",
			"<leader>md",
			"<cmd>FlutterDevices<CR>",
			vim.tbl_extend("force", opts, { desc = "Flutter Devices" })
		)
		keymap(
			"n",
			"<leader>me",
			"<cmd>FlutterEmulators<CR>",
			vim.tbl_extend("force", opts, { desc = "Flutter Emulators" })
		)
		keymap(
			"n",
			"<leader>mo",
			"<cmd>FlutterOutlineToggle<CR>",
			vim.tbl_extend("force", opts, { desc = "Flutter Outline" })
		)
		keymap("n", "<leader>ml", "<cmd>FlutterLogToggle<CR>", vim.tbl_extend("force", opts, { desc = "Flutter Logs" }))
		keymap(
			"n",
			"<leader>mt",
			"<cmd>FlutterDevTools<CR>",
			vim.tbl_extend("force", opts, { desc = "Flutter DevTools" })
		)
		keymap(
			"n",
			"<leader>mT",
			"<cmd>FlutterOpenDevTools<CR>",
			vim.tbl_extend("force", opts, { desc = "Open Flutter DevTools" })
		)
		keymap(
			"n",
			"<leader>mi",
			"<cmd>FlutterInspectWidget<CR>",
			vim.tbl_extend("force", opts, { desc = "Flutter Inspect Widget" })
		)
		keymap("n", "<leader>mp", "<cmd>FlutterPubGet<CR>", vim.tbl_extend("force", opts, { desc = "Flutter Pub Get" }))
		keymap("n", "<leader>ma", "<cmd>FlutterAttach<CR>", vim.tbl_extend("force", opts, { desc = "Flutter Attach" }))
		keymap("n", "<leader>mx", "<cmd>FlutterDetach<CR>", vim.tbl_extend("force", opts, { desc = "Flutter Detach" }))
	end

	-- === DAP keymaps ===
	if client.name == "rust-analyzer" or client.name == "dartls" then
		local dap = require("dap")
		keymap("n", "<leader>dc", dap.continue, opts) -- Continue / Start
		keymap("n", "<leader>do", dap.step_over, opts) -- Step over
		keymap("n", "<leader>di", dap.step_into, opts) -- Step into
		keymap("n", "<leader>du", dap.step_out, opts) -- Step out
		keymap("n", "<leader>db", dap.toggle_breakpoint, opts) -- Toggle breakpoint
		keymap("n", "<leader>dr", dap.repl.open, opts) -- Open DAP REPL
	end
end

return M
