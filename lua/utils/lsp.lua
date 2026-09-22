-- ================================================================================================
-- TITLE : LSP on_attach
-- ABOUT :
--   Buffer-local mappings and per-client behaviour, applied from the LspAttach autocmd.
--
-- KEY LAYOUT NOTES
--   * Navigation uses the standard `g` motions (gd / gD / gy / gO), NOT <leader>g…, because
--     <leader>g… belongs to git (gitsigns + diffview). The previous config mapped both to
--     <leader>gd / <leader>gD, and whichever attached last silently won.
--   * Neovim 0.11 already ships `grn` (rename), `gra` (code action), `grr` (references),
--     `gri` (implementation) and `<C-s>` (signature help) as defaults. Nothing here maps a
--     bare `gr`, which would make all of those stall for 'timeoutlen'.
--   * Diagnostics under the cursor are on <leader>k / <leader>K so that <leader>d… stays
--     free for the DAP group.
-- ================================================================================================

local M = {}

---Attach buffer-local LSP mappings and capabilities-dependent behaviour.
---@param event table LspAttach autocmd event
M.on_attach = function(event)
	if not event or not event.data then
		return
	end

	local client = vim.lsp.get_client_by_id(event.data.client_id)
	if not client then
		return
	end

	local bufnr = event.buf

	local function map(mode, lhs, rhs, desc)
		vim.keymap.set(mode, lhs, rhs, {
			noremap = true,
			silent = true,
			buffer = bufnr,
			desc = desc,
		})
	end

	-- ── Navigation (Lspsaga UI) ─────────────────────────────────────────────────────────
	map("n", "gd", "<cmd>Lspsaga peek_definition<cr>", "Peek definition")
	map("n", "gD", "<cmd>Lspsaga goto_definition<cr>", "Go to definition")
	map("n", "gy", "<cmd>Lspsaga peek_type_definition<cr>", "Peek type definition")
	map("n", "gO", "<cmd>Lspsaga outline<cr>", "Document outline")
	map("n", "K", "<cmd>Lspsaga hover_doc<cr>", "Hover documentation")

	map("n", "<leader>ss", "<cmd>vsplit | Lspsaga goto_definition<cr>", "Definition in vertical split")

	-- ── Actions ─────────────────────────────────────────────────────────────────────────
	map({ "n", "v" }, "<leader>ca", "<cmd>Lspsaga code_action<cr>", "Code action")
	map("n", "<leader>rn", "<cmd>Lspsaga rename<cr>", "Rename symbol")
	map("n", "<leader>rN", "<cmd>Lspsaga rename ++project<cr>", "Rename symbol (project-wide)")

	-- ── Diagnostics ─────────────────────────────────────────────────────────────────────
	map("n", "<leader>k", "<cmd>Lspsaga show_cursor_diagnostics<cr>", "Diagnostics under cursor")
	map("n", "<leader>K", "<cmd>Lspsaga show_line_diagnostics<cr>", "Diagnostics for line")
	map("n", "<leader>xb", "<cmd>Lspsaga show_buf_diagnostics<cr>", "Diagnostics for buffer")

	-- ── Pickers (fzf-lua) ───────────────────────────────────────────────────────────────
	map("n", "<leader>fr", "<cmd>FzfLua lsp_references<cr>", "References")
	map("n", "<leader>ft", "<cmd>FzfLua lsp_typedefs<cr>", "Type definitions")
	map("n", "<leader>fi", "<cmd>FzfLua lsp_implementations<cr>", "Implementations")
	map("n", "<leader>fd", "<cmd>FzfLua lsp_definitions<cr>", "Definitions")
	map("n", "<leader>fs", "<cmd>FzfLua lsp_document_symbols<cr>", "Document symbols")
	map("n", "<leader>fw", "<cmd>FzfLua lsp_live_workspace_symbols<cr>", "Workspace symbols")
	map("n", "<leader>fc", "<cmd>FzfLua lsp_code_actions<cr>", "Code actions (picker)")

	-- ── Organize imports ────────────────────────────────────────────────────────────────
	-- Runs the code action, then lets conform format the result. Previously this called
	-- vim.lsp.buf.format() on a 50ms timer, which raced conform's own format-on-save and
	-- could apply two different formatters to the same buffer.
	if client:supports_method("textDocument/codeAction", bufnr) then
		map("n", "<leader>oi", function()
			vim.lsp.buf.code_action({
				context = { only = { "source.organizeImports" }, diagnostics = {} },
				apply = true,
			})

			vim.defer_fn(function()
				if vim.api.nvim_buf_is_valid(bufnr) then
					require("conform").format({ bufnr = bufnr, lsp_format = "fallback" })
				end
			end, 100)
		end, "Organize imports")
	end

	-- ── Inlay hints ─────────────────────────────────────────────────────────────────────
	if client:supports_method("textDocument/inlayHint", bufnr) then
		vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })

		map("n", "<leader>ci", function()
			local enabled = vim.lsp.inlay_hint.is_enabled({ bufnr = bufnr })
			vim.lsp.inlay_hint.enable(not enabled, { bufnr = bufnr })
		end, "Toggle inlay hints")
	end

	-- ── Document highlight ──────────────────────────────────────────────────────────────
	-- Underline other occurrences of the symbol under the cursor. mini.cursorword does a
	-- textual version of this; the LSP version is semantic, so prefer it where available.
	if client:supports_method("textDocument/documentHighlight", bufnr) then
		local group = vim.api.nvim_create_augroup("LspDocumentHighlight_" .. bufnr, { clear = true })

		vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
			group = group,
			buffer = bufnr,
			callback = vim.lsp.buf.document_highlight,
		})

		vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
			group = group,
			buffer = bufnr,
			callback = vim.lsp.buf.clear_references,
		})

		vim.api.nvim_create_autocmd("LspDetach", {
			group = group,
			buffer = bufnr,
			callback = function()
				vim.lsp.buf.clear_references()
				pcall(vim.api.nvim_del_augroup_by_name, "LspDocumentHighlight_" .. bufnr)
			end,
		})
	end

	-- ── Flutter / Dart ──────────────────────────────────────────────────────────────────
	-- Buffer-local, and deliberately mirrors the global Xcode <leader>m… mappings so the
	-- same keys drive whichever mobile toolchain the current file belongs to.
	if client.name == "dartls" then
		local flutter = {
			{ "<leader>mr", "FlutterRun", "Flutter: run" },
			{ "<leader>mR", "FlutterReload", "Flutter: hot reload" },
			{ "<leader>ms", "FlutterRestart", "Flutter: hot restart" },
			{ "<leader>mD", "FlutterDebug", "Flutter: debug" },
			{ "<leader>mq", "FlutterQuit", "Flutter: quit" },
			{ "<leader>md", "FlutterDevices", "Flutter: devices" },
			{ "<leader>me", "FlutterEmulators", "Flutter: emulators" },
			{ "<leader>mo", "FlutterOutlineToggle", "Flutter: outline" },
			{ "<leader>ml", "FlutterLogToggle", "Flutter: logs" },
			{ "<leader>mt", "FlutterDevTools", "Flutter: DevTools" },
			{ "<leader>mT", "FlutterOpenDevTools", "Flutter: open DevTools" },
			{ "<leader>mi", "FlutterInspectWidget", "Flutter: inspect widget" },
			{ "<leader>mp", "FlutterPubGet", "Flutter: pub get" },
			{ "<leader>mu", "FlutterPubUpgrade", "Flutter: pub upgrade" },
			{ "<leader>ma", "FlutterAttach", "Flutter: attach" },
			{ "<leader>mx", "FlutterDetach", "Flutter: detach" },
		}

		for _, m in ipairs(flutter) do
			map("n", m[1], ("<cmd>%s<cr>"):format(m[2]), m[3])
		end
	end
end

return M
