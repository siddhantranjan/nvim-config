-- ================================================================================================
-- TITLE : nvim-dap + nvim-dap-ui
-- ABOUT :
--   Debug Adapter Protocol client and its UI.
--
-- NOTE
--   Debug keymaps used to be defined inside the LSP on_attach, gated on the client being
--   `rust-analyzer` or `dartls`. That meant the Swift adapter configured below had no keys
--   at all, and none of the keys existed until a language server happened to attach. They
--   are global now -- <leader>d… is a real group, which is why nothing else may be bound to
--   a bare <leader>d (the old "cursor diagnostics" mapping moved to <leader>k).
--
--   codelldb is installed by mason-tool-installer (see nvim-lspconfig.lua); the path below
--   is where Mason puts it.
-- LINKS :
--   > nvim-dap    : https://github.com/mfussenegger/nvim-dap
--   > nvim-dap-ui : https://github.com/rcarriga/nvim-dap-ui
-- ================================================================================================

return {
	{
		"mfussenegger/nvim-dap",

		dependencies = {
			{
				"rcarriga/nvim-dap-ui",
				dependencies = { "nvim-neotest/nvim-nio" },
				opts = {
					layouts = {
						{
							elements = {
								{ id = "scopes", size = 0.35 },
								{ id = "breakpoints", size = 0.20 },
								{ id = "stacks", size = 0.25 },
								{ id = "watches", size = 0.20 },
							},
							size = 45,
							position = "left",
						},
						{
							elements = {
								{ id = "repl", size = 0.5 },
								{ id = "console", size = 0.5 },
							},
							size = 12,
							position = "bottom",
						},
					},
					floating = { border = "rounded" },
				},
			},

			{
				"theHamsta/nvim-dap-virtual-text",
				opts = {
					enabled = true,
					commented = true,
					virt_text_pos = "eol",
				},
			},
		},

		keys = {
			{ "<leader>dc", function() require("dap").continue() end, desc = "Debug: continue / start" },
			{ "<leader>dn", function() require("dap").step_over() end, desc = "Debug: step over" },
			{ "<leader>di", function() require("dap").step_into() end, desc = "Debug: step into" },
			{ "<leader>du", function() require("dap").step_out() end, desc = "Debug: step out" },
			{ "<leader>db", function() require("dap").toggle_breakpoint() end, desc = "Debug: toggle breakpoint" },
			{
				"<leader>dB",
				function()
					vim.ui.input({ prompt = "Breakpoint condition: " }, function(cond)
						if cond and cond ~= "" then
							require("dap").set_breakpoint(cond)
						end
					end)
				end,
				desc = "Debug: conditional breakpoint",
			},
			{ "<leader>dl", function() require("dap").run_last() end, desc = "Debug: run last" },
			{ "<leader>dr", function() require("dap").repl.toggle() end, desc = "Debug: toggle REPL" },
			{ "<leader>dt", function() require("dap").terminate() end, desc = "Debug: terminate" },
			{ "<leader>dC", function() require("dap").run_to_cursor() end, desc = "Debug: run to cursor" },
			{
				"<leader>dx",
				function()
					require("dap").clear_breakpoints()
					vim.notify("All breakpoints cleared", vim.log.levels.INFO)
				end,
				desc = "Debug: clear all breakpoints",
			},
			{ "<leader>dd", function() require("dapui").toggle() end, desc = "Debug: toggle UI" },
			{
				"<leader>de",
				function()
					require("dapui").eval(nil, { enter = true })
				end,
				mode = { "n", "v" },
				desc = "Debug: evaluate expression",
			},
		},

		config = function()
			local dap = require("dap")
			local dapui = require("dapui")

			-- ── Signs ───────────────────────────────────────────────────────────────
			local glyphs = require("utils.icons").dap

			local signs = {
				DapBreakpoint = { text = glyphs.breakpoint, texthl = "DiagnosticError" },
				DapBreakpointCondition = { text = glyphs.conditional, texthl = "DiagnosticWarn" },
				DapBreakpointRejected = { text = glyphs.rejected, texthl = "DiagnosticHint" },
				DapLogPoint = { text = glyphs.logpoint, texthl = "DiagnosticInfo" },
				DapStopped = { text = glyphs.stopped, texthl = "DiagnosticOk", linehl = "Visual" },
			}

			for name, opts in pairs(signs) do
				vim.fn.sign_define(name, opts)
			end

			-- ── codelldb adapter (C, C++, Rust, Swift) ──────────────────────────────
			local codelldb = vim.fn.stdpath("data") .. "/mason/bin/codelldb"

			dap.adapters.codelldb = {
				type = "server",
				port = "${port}",
				executable = {
					command = codelldb,
					args = { "--port", "${port}" },
				},
			}

			local function pick_executable()
				return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
			end

			local codelldb_config = {
				{
					name = "Launch executable",
					type = "codelldb",
					request = "launch",
					program = pick_executable,
					cwd = "${workspaceFolder}",
					stopOnEntry = false,
					args = {},
				},
			}

			dap.configurations.swift = codelldb_config
			dap.configurations.c = codelldb_config
			dap.configurations.cpp = codelldb_config

			-- NOTE: Rust debugging is owned by rustaceanvim, which registers its own
			-- codelldb configuration derived from `cargo metadata`. Don't set
			-- dap.configurations.rust here or the two will both appear in the picker.

			-- ── Auto open/close the UI ──────────────────────────────────────────────
			dap.listeners.before.attach.dapui_config = function()
				dapui.open()
			end

			dap.listeners.before.launch.dapui_config = function()
				dapui.open()
			end

			dap.listeners.before.event_terminated.dapui_config = function()
				dapui.close()
			end

			dap.listeners.before.event_exited.dapui_config = function()
				dapui.close()
			end
		end,
	},
}
