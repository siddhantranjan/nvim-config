-- ================================================================================================
-- TITLE : rustaceanvim
-- ABOUT :
--   Owns rust-analyzer end to end -- it registers and starts the server itself, which is
--   why `rust_analyzer` is deliberately absent from lua/servers/. Also provides Rust
--   debugging (codelldb, auto-detected from Mason), runnables/testables, macro expansion,
--   error explanations and clippy-on-save.
--
-- TOOLCHAIN (not installed by Mason, on purpose):
--   rust-analyzer, rustfmt and clippy come from rustup so they always match your compiler:
--     rustup component add rust-analyzer rustfmt clippy
--   rustaceanvim's author strongly advises against Mason's rust-analyzer for that reason.
--
-- VERSION
--   ^8 is the last major that supports Neovim 0.11 (v9 requires 0.12). On Neovim 0.12+
--   this can be bumped to ^9.
--
-- NOTE
--   Shared LSP maps (gd, K, <leader>ca, ...) come from the global LspAttach autocmd in
--   config/autocmds.lua; the Rust-only extras below are layered on top. rustaceanvim calls
--   on_attach as (client, bufnr), not with an event table, so utils.lsp.on_attach must not be
--   passed as server.on_attach.
-- LINKS :
--   > github : https://github.com/mrcjkb/rustaceanvim
-- ================================================================================================

return {
	"mrcjkb/rustaceanvim",
	version = "^8",
	-- rustaceanvim is itself a filetype plugin; the author explicitly recommends against
	-- wrapping it in lazy loading.
	lazy = false,

	init = function()
		vim.g.rustaceanvim = {
			tools = {
				hover_actions = { auto_focus = true },
				float_win_config = { border = "rounded" },
				-- :RustLsp runnables / run open in a toggleterm split, same as <leader>ex.
				executor = "toggleterm",
			},

			server = {
				default_settings = {
					["rust-analyzer"] = {
						cargo = {
							features = "all",
							buildScripts = { enable = true },
						},
						-- clippy on save instead of plain `cargo check`.
						checkOnSave = true,
						check = { command = "clippy", extraArgs = { "--no-deps" } },
						procMacro = { enable = true },
						inlayHints = {
							bindingModeHints = { enable = false },
							closureReturnTypeHints = { enable = "with_block" },
							lifetimeElisionHints = { enable = "skip_trivial" },
							parameterHints = { enable = true },
							typeHints = { enable = true },
						},
					},
				},
			},

			-- dap.adapter is left unset: rustaceanvim finds codelldb on PATH or in Mason
			-- (installed by mason-tool-installer) on its own.
		}
	end,

	config = function()
		-- Rust-specific extras layered on top of the shared LSP maps in utils/lsp.lua.
		vim.api.nvim_create_autocmd("FileType", {
			group = vim.api.nvim_create_augroup("user_rustaceanvim", { clear = true }),
			pattern = "rust",
			callback = function(args)
				local function map(lhs, cmd, desc)
					vim.keymap.set("n", lhs, function()
						vim.cmd.RustLsp(cmd)
					end, { buffer = args.buf, desc = desc })
				end

				map("<leader>cR", "runnables", "Rust: runnables")
				map("<leader>cT", "testables", "Rust: testables")
				map("<leader>cx", "expandMacro", "Rust: expand macro")
				map("<leader>cp", "parentModule", "Rust: parent module")
				map("<leader>cC", "openCargo", "Rust: open Cargo.toml")
				map("<leader>cj", "joinLines", "Rust: join lines")
				map("<leader>cE", "explainError", "Rust: explain error")
				map("<leader>cr", "renderDiagnostic", "Rust: full compiler diagnostic")
				map("<leader>cD", "openDocs", "Rust: open docs.rs")
				map("<leader>ck", { "hover", "actions" }, "Rust: hover actions")
			end,
		})
	end,
}
