-- ================================================================================================
-- TITLE : rustaceanvim
-- ABOUT :
--   Owns rust-analyzer end to end -- it registers and starts the server itself, which is
--   why `rust_analyzer` is deliberately absent from lua/servers/.
--
-- NOTE
--   This spec used to pass `server.on_attach = require("utils.lsp").on_attach`. That
--   function takes an LspAttach *event* table, but rustaceanvim calls on_attach with
--   (client, bufnr) -- so it hit the `if not event.data then return end` guard and did
--   nothing on every single attach. The global LspAttach autocmd in config/autocmds.lua
--   already covers rust buffers, so the hook is removed rather than patched.
--
--   vim.g.rustaceanvim is assigned a FUNCTION rather than a table so that the codelldb
--   lookup runs when rustaceanvim first needs it -- by which point Mason has finished
--   installing -- instead of during startup, when the adapter may not exist yet.
-- LINKS :
--   > github : https://github.com/mrcjkb/rustaceanvim
-- ================================================================================================

---Locate the codelldb adapter installed by mason-tool-installer.
---@return table|nil adapter rustaceanvim DAP adapter, or nil if codelldb isn't installed
local function codelldb_adapter()
	local extension = vim.fn.stdpath("data") .. "/mason/packages/codelldb/extension/"
	local adapter_path = extension .. "adapter/codelldb"

	if vim.fn.executable(adapter_path) == 0 then
		return nil
	end

	local suffix = vim.uv.os_uname().sysname == "Linux" and ".so" or ".dylib"
	local liblldb_path = extension .. "lldb/lib/liblldb" .. suffix

	local ok, cfg = pcall(require, "rustaceanvim.config")
	if not ok then
		return nil
	end

	return cfg.get_codelldb_adapter(adapter_path, liblldb_path)
end

return {
	"mrcjkb/rustaceanvim",
	version = "^6",
	-- rustaceanvim is itself a filetype plugin; the author explicitly recommends against
	-- wrapping it in lazy loading.
	lazy = false,

	init = function()
		vim.g.rustaceanvim = function()
			return {
				tools = {
					hover_actions = { auto_focus = true },
					float_win_config = { border = "rounded" },
				},

				server = {
					default_settings = {
						["rust-analyzer"] = {
							cargo = {
								allFeatures = true,
								loadOutDirsFromCheck = true,
								buildScripts = { enable = true },
							},
							checkOnSave = true,
							check = { command = "clippy", extraArgs = { "--no-deps" } },
							procMacro = { enable = true },
							inlayHints = {
								bindingModeHints = { enable = false },
								closureReturnTypeHints = { enable = "with_block" },
								parameterHints = { enable = true },
								typeHints = { enable = true },
							},
						},
					},
				},

				dap = {
					adapter = codelldb_adapter(),
				},
			}
		end
	end,

	config = function()
		-- Rust-specific extras layered on top of the shared LSP maps in utils/lsp.lua.
		vim.api.nvim_create_autocmd("FileType", {
			group = vim.api.nvim_create_augroup("user_rustaceanvim", { clear = true }),
			pattern = "rust",
			callback = function(args)
				local function map(lhs, action, desc)
					vim.keymap.set("n", lhs, function()
						vim.cmd.RustLsp(action)
					end, { buffer = args.buf, desc = desc })
				end

				map("<leader>cR", "runnables", "Rust: runnables")
				map("<leader>cT", "testables", "Rust: testables")
				map("<leader>cx", "expandMacro", "Rust: expand macro")
				map("<leader>cp", "parentModule", "Rust: parent module")
				map("<leader>cj", "joinLines", "Rust: join lines")
				map("<leader>cE", "explainError", "Rust: explain error")
				map("<leader>cD", "openDocs", "Rust: open docs.rs")

				vim.keymap.set("n", "<leader>ck", function()
					vim.cmd.RustLsp({ "hover", "actions" })
				end, { buffer = args.buf, desc = "Rust: hover actions" })
			end,
		})
	end,
}
