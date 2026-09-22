-- ================================================================================================
-- TITLE : NeoVim keymaps
-- ABOUT :
--   Global, non-plugin-specific mappings. Plugin mappings live with their plugin spec;
--   LSP mappings live in lua/utils/lsp.lua (buffer-local, on LspAttach).
--
-- LEADER MAP LAYOUT -- no single-key mapping may share a prefix with a group, or every key
-- in that group stalls for 'timeoutlen' before firing:
--
--   <leader>b…  buffers            <leader>n…  notes (obsidian)
--   <leader>c…  code / AI chat     <leader>p…  paste-related
--   <leader>d…  debug (DAP)        <leader>r…  rename / resize / config
--   <leader>f…  find (fzf-lua)     <leader>s…  splits
--   <leader>g…  git                <leader>x…  diagnostics (trouble)
--   <leader>m…  mobile (flutter/xcode)
--
--   Singles deliberately kept OUT of those prefixes: h (nohl), q (oil), z (zen), ; (winbar),
--   D (delete no-yank), k / K (diagnostics under cursor / line).
-- ================================================================================================

local map = vim.keymap.set

-- ── Config ──────────────────────────────────────────────────────────────────────────────────
map("n", "<leader>rc", function()
	vim.cmd.edit(vim.fn.stdpath("config") .. "/init.lua")
end, { desc = "Edit config" })

map("n", "<leader>rl", "<cmd>Lazy<cr>", { desc = "Lazy (plugin manager)" })
map("n", "<leader>rm", "<cmd>Mason<cr>", { desc = "Mason (tool installer)" })

-- ── Movement ────────────────────────────────────────────────────────────────────────────────
-- Wrap-aware j/k, but only for un-counted motions so `5j` still lands on line +5
-- (and still records a jump for `''`).
map("n", "j", function()
	return vim.v.count == 0 and "gj" or "j"
end, { expr = true, silent = true, desc = "Down (wrap-aware)" })

map("n", "k", function()
	return vim.v.count == 0 and "gk" or "k"
end, { expr = true, silent = true, desc = "Up (wrap-aware)" })

map("n", "n", "nzzzv", { desc = "Next search result (centered)" })
map("n", "N", "Nzzzv", { desc = "Prev search result (centered)" })
map("n", "<C-d>", "<C-d>zz", { desc = "Half page down (centered)" })
map("n", "<C-u>", "<C-u>zz", { desc = "Half page up (centered)" })

-- ── Search ──────────────────────────────────────────────────────────────────────────────────
-- WAS <leader>c, which shadowed the entire <leader>c… group (CopilotChat, code action,
-- Trouble symbols) and made every one of them wait 500ms.
map("n", "<leader>h", "<cmd>nohlsearch<cr>", { desc = "Clear search highlights" })
map("n", "<Esc>", "<cmd>nohlsearch<cr>", { desc = "Clear search highlights" })

-- ── Yank / paste / delete ───────────────────────────────────────────────────────────────────
map("x", "<leader>p", '"_dP', { desc = "Paste over without yanking" })

-- WAS <leader>x, which shadowed the <leader>x… Trouble group.
map({ "n", "v" }, "<leader>D", '"_d', { desc = "Delete without yanking" })

map("n", "<leader>pa", function()
	local path = vim.fn.expand("%:p")
	vim.fn.setreg("+", path)
	vim.notify("Copied: " .. path, vim.log.levels.INFO)
end, { desc = "Copy absolute file path" })

map("n", "<leader>pr", function()
	local path = vim.fn.expand("%:.")
	vim.fn.setreg("+", path)
	vim.notify("Copied: " .. path, vim.log.levels.INFO)
end, { desc = "Copy relative file path" })

-- ── Buffers ─────────────────────────────────────────────────────────────────────────────────
map("n", "<leader>bn", "<cmd>bnext<cr>", { desc = "Next buffer" })
map("n", "<leader>bp", "<cmd>bprevious<cr>", { desc = "Previous buffer" })
map("n", "<S-l>", "<cmd>bnext<cr>", { desc = "Next buffer" })
map("n", "<S-h>", "<cmd>bprevious<cr>", { desc = "Previous buffer" })

-- mini.bufremove closes the buffer without destroying the window layout.
map("n", "<leader>bd", function()
	require("mini.bufremove").delete(0, false)
end, { desc = "Delete buffer" })

map("n", "<leader>bD", function()
	require("mini.bufremove").delete(0, true)
end, { desc = "Delete buffer (force)" })

map("n", "<leader>bo", function()
	local current = vim.api.nvim_get_current_buf()
	for _, buf in ipairs(vim.api.nvim_list_bufs()) do
		if buf ~= current and vim.bo[buf].buflisted and not vim.bo[buf].modified then
			pcall(require("mini.bufremove").delete, buf, false)
		end
	end
end, { desc = "Delete other buffers" })

-- ── Windows & splits ────────────────────────────────────────────────────────────────────────
-- NOTE: <leader>q (Oil) is defined in lua/plugins/oil.lua so the mapping lives with the
-- plugin that owns it. Defining it here as well, as this file used to, meant two sources of
-- truth for the same key.
map("n", "<leader>sv", "<cmd>vsplit<cr>", { desc = "Split vertically" })
map("n", "<leader>sh", "<cmd>split<cr>", { desc = "Split horizontally" })
map("n", "<leader>sc", "<cmd>close<cr>", { desc = "Close split" })
map("n", "<leader>so", "<cmd>only<cr>", { desc = "Close other splits" })
map("n", "<leader>s=", "<C-w>=", { desc = "Equalize splits" })

-- Resizing. Also on <C-arrow> so it can be held down rather than re-typed.
map("n", "<leader>rw", "<cmd>resize +2<cr>", { desc = "Increase window height" })
map("n", "<leader>rs", "<cmd>resize -2<cr>", { desc = "Decrease window height" })
map("n", "<leader>ra", "<cmd>vertical resize -2<cr>", { desc = "Decrease window width" })
map("n", "<leader>rd", "<cmd>vertical resize +2<cr>", { desc = "Increase window width" })
map("n", "<C-Up>", "<cmd>resize +2<cr>", { desc = "Increase window height" })
map("n", "<C-Down>", "<cmd>resize -2<cr>", { desc = "Decrease window height" })
map("n", "<C-Left>", "<cmd>vertical resize -2<cr>", { desc = "Decrease window width" })
map("n", "<C-Right>", "<cmd>vertical resize +2<cr>", { desc = "Increase window width" })

-- ── Indentation ─────────────────────────────────────────────────────────────────────────────
-- NOTE: line/selection movement on <A-j>/<A-k> is NOT defined here. mini.move already owns
-- <M-h/j/k/l> in both normal and visual mode (<A-…> and <M-…> are the same notation), and
-- because it loads on VeryLazy -- after this file runs -- it overwrote anything defined
-- here. mini.move also handles horizontal movement, which the hand-rolled version did not.
map("v", "<", "<gv", { desc = "Indent left and reselect" })
map("v", ">", ">gv", { desc = "Indent right and reselect" })

map("n", "J", "mzJ`z", { desc = "Join lines, keep cursor" })

-- ── Diagnostics (non-LSP-specific; buffer-local LSP maps are in utils/lsp.lua) ──────────────
-- `[d` / `]d` are the Neovim conventions and stay out of the <leader>d… DAP group.
map("n", "]d", function()
	vim.diagnostic.jump({ count = 1, float = true })
end, { desc = "Next diagnostic" })

map("n", "[d", function()
	vim.diagnostic.jump({ count = -1, float = true })
end, { desc = "Previous diagnostic" })

map("n", "]e", function()
	vim.diagnostic.jump({ count = 1, float = true, severity = vim.diagnostic.severity.ERROR })
end, { desc = "Next error" })

map("n", "[e", function()
	vim.diagnostic.jump({ count = -1, float = true, severity = vim.diagnostic.severity.ERROR })
end, { desc = "Previous error" })

-- ── Quickfix ────────────────────────────────────────────────────────────────────────────────
map("n", "]q", "<cmd>cnext<cr>zz", { desc = "Next quickfix item" })
map("n", "[q", "<cmd>cprevious<cr>zz", { desc = "Previous quickfix item" })

-- ── Mobile: Xcode ───────────────────────────────────────────────────────────────────────────
-- Flutter reuses this <leader>m… namespace, but buffer-locally on dart files only
-- (see utils/lsp.lua), so the two toolchains never collide in the same buffer.
map("n", "<leader>mb", "<cmd>XcodebuildBuild<cr>", { desc = "Xcode: build" })
map("n", "<leader>mr", "<cmd>XcodebuildRun<cr>", { desc = "Xcode: run" })
map("n", "<leader>mp", "<cmd>XcodebuildPicker<cr>", { desc = "Xcode: picker" })
map("n", "<leader>mc", "<cmd>XcodebuildClean<cr>", { desc = "Xcode: clean" })
map("n", "<leader>mt", "<cmd>XcodebuildTest<cr>", { desc = "Xcode: test" })
map("n", "<leader>ml", "<cmd>XcodebuildToggleLogs<cr>", { desc = "Xcode: toggle logs" })
