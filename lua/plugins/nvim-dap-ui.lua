return {
	"rcarriga/nvim-dap-ui",
	dependencies = {
		"nvim-neotest/nvim-nio",
		{
			"mfussenegger/nvim-dap",
			config = function()
				local dap = require("dap")
				local dapui = require("dapui")

				-- CodeLLDB adapter
				dap.adapters.codelldb = {
					type = "server",
					port = "${port}",
					executable = {
						command = vim.fn.expand("~/.local/share/nvim/mason/bin/codelldb"),
						args = { "--port", "${port}" },
					},
				}

				-- Swift debugging
				dap.configurations.swift = {
					{
						name = "Launch Swift App",
						type = "codelldb",
						request = "launch",
						program = function()
							return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
						end,
						cwd = "${workspaceFolder}",
						stopOnEntry = false,
					},
				}

				-- Auto open/close dap ui
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
	},
	config = function()
		require("dapui").setup()
	end,
}
