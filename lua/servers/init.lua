-- ================================================================================================
-- TITLE : LSP server registry
-- ABOUT :
--   Loads every per-server module in this directory and enables it. Each module returns a
--   function(capabilities) that calls vim.lsp.config(<name>, ...). The module's FILENAME must
--   match the server name passed to vim.lsp.config -- this file enables servers by filename,
--   so a mismatch is caught loudly at startup instead of silently doing nothing.
--
--   A module may return `false` to opt out (e.g. ruby_lsp when the binary isn't installed),
--   in which case it is not enabled.
--
--   Not listed here: dartls (owned by flutter-tools.nvim) and rust_analyzer (owned by
--   rustaceanvim). Both plugins register and start those servers themselves; enabling them
--   here as well would start a duplicate client.
-- ================================================================================================

local capabilities = require("cmp_nvim_lsp").default_capabilities()

-- Language servers, by module/server name.
local servers = {
	"bashls",
	"clangd",
	"cssls",
	"dockerls",
	"emmet_ls",
	"gopls",
	"html",
	"jsonls",
	"lua_ls",
	"pyright",
	"ruby_lsp",
	"solidity_ls_nomicfoundation",
	"sourcekit",
	"tailwindcss",
	"ts_ls",
	"yamlls",
}

-- Linter bridge. Its module is `efm-langserver` but the server name is `efm`.
local extra = {
	["efm-langserver"] = "efm",
}

local enabled = {}

local function register(module, name)
	local ok, setup = pcall(require, "servers." .. module)
	if not ok then
		vim.notify(("[lsp] failed to load servers.%s:\n%s"):format(module, setup), vim.log.levels.ERROR)
		return
	end

	local configured, result = pcall(setup, capabilities)
	if not configured then
		vim.notify(("[lsp] failed to configure %s:\n%s"):format(name, result), vim.log.levels.ERROR)
		return
	end

	-- A module returning exactly `false` is opting out (missing binary, etc.).
	if result == false then
		return
	end

	table.insert(enabled, name)
end

for _, name in ipairs(servers) do
	register(name, name)
end

for module, name in pairs(extra) do
	register(module, name)
end

vim.lsp.enable(enabled)
