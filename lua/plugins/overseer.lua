-- ================================================================================================
-- TITLE : overseer.nvim
-- ABOUT :
--   Task runner -- the equivalent of VS Code's Tasks. Out of the box it finds make, npm,
--   cargo, just, and `.vscode/tasks.json` tasks; `:OverseerRun` lists them.
--
--   <leader>eb / ex / ed are context-aware build / run / debug (see lua/utils/runner.lua):
--   Rust goes through cargo (errors to the quickfix list, programs in a terminal split,
--   debugging via rustaceanvim), scripts run in a terminal split, everything else falls
--   back to overseer's templates.
--
--   `dap = false` so overseer can stay lazy; nvim-dap calls enable_dap() when it loads, which
--   is what makes launch.json `preLaunchTask` work (see lua/plugins/nvim-dap-ui.lua).
-- LINKS :
--   > github : https://github.com/stevearc/overseer.nvim
-- ================================================================================================

return {
	"stevearc/overseer.nvim",
	cmd = {
		"OverseerOpen",
		"OverseerClose",
		"OverseerToggle",
		"OverseerRun",
		"OverseerShell",
		"OverseerTaskAction",
		"OverseerRestartLast", -- defined in config below
	},

	keys = {
		-- Context-aware (lua/utils/runner.lua)
		{
			"<leader>eb",
			function()
				require("utils.runner").build()
			end,
			desc = "Build",
		},
		{
			"<leader>ex",
			function()
				require("utils.runner").run()
			end,
			desc = "Run",
		},
		{
			"<leader>ed",
			function()
				require("utils.runner").debug()
			end,
			desc = "Debug",
		},

		-- Plain overseer
		{ "<leader>er", "<cmd>OverseerRun<cr>", desc = "Run task…" },
		{ "<leader>el", "<cmd>OverseerRestartLast<cr>", desc = "Restart last task" },
		{ "<leader>et", "<cmd>OverseerToggle<cr>", desc = "Task list" },
		{ "<leader>es", "<cmd>OverseerShell<cr>", desc = "Run shell command as task" },
		{ "<leader>ea", "<cmd>OverseerTaskAction<cr>", desc = "Task action…" },
	},

	opts = {
		dap = false,
		task_list = {
			direction = "bottom",
			min_height = 10,
			max_height = { 20, 0.3 },
		},
	},

	config = function(_, opts)
		local overseer = require("overseer")
		overseer.setup(opts)

		-- No built-in "restart last" in overseer v2; this is the recipe from its docs.
		vim.api.nvim_create_user_command("OverseerRestartLast", function()
			local tasks = overseer.list_tasks({
				status = { overseer.STATUS.SUCCESS, overseer.STATUS.FAILURE, overseer.STATUS.CANCELED },
				sort = require("overseer.task_list").sort_finished_recently,
			})
			if vim.tbl_isempty(tasks) then
				vim.notify("No finished tasks to restart", vim.log.levels.WARN)
			else
				overseer.run_action(tasks[1], "restart")
			end
		end, { desc = "Restart the most recently finished task" })
	end,
}
