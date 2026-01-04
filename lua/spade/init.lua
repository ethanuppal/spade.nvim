-- Based off of https://github.com/NMAC427/guess-indent.nvim

local M = {}

M.config = {
	lsp_command = "spade-language-server",
	lazy = true,
}

local function current_buffer_path()
	return vim.fn.expand("%:p")
end

local function if_online(callback)
	-- https://stackoverflow.com/a/78354275/10652070
	vim.system({ "ping", "-c", "3", "8.8.8.8" }, { text = true }, function(result)
		-- because have to run on main thread
		vim.schedule(function()
			local is_connected = result.code == 0
			if callback then
				callback(is_connected)
			end
		end)
	end)
end

--- Determines the closest parent directory containing `swim.toml`.
function M.swim_root_dir()
	return vim.fs.dirname(vim.fs.find({ "swim.toml" }, {
		path = current_buffer_path(),
		type = "file",
		upward = true,
	})[1])
end

--- Run when you need to make sure that you're working in a valid Spade project.
function M.check_health()
	if M.swim_root_dir() == nil then
		vim.notify(
			"Spade: cannot find `swim.toml` in parent directory. Are you sure you're currently in a Spade project?",
			vim.log.levels.WARN
		)
	end
end

local function install_command()
	local subcommands = {
		openSwim = function(_)
			M.check_health()

			vim.cmd.edit(vim.fs.joinpath(M.swim_root_dir(), "swim.toml"))
		end,
	}

	vim.api.nvim_create_user_command("Spade", function(args)
		local subcommand = args.fargs[1]

		if not subcommand then
			vim.notify("`:Spade`: no subcommand provided", vim.log.levels.ERROR)
			return
		end

		if subcommands[subcommand] ~= nil then
			subcommands[subcommand](vim.list_slice(args.fargs, 2))
		else
			vim.notify("`:Spade`: invalid subcommand `" .. subcommand .. "`", vim.log.levels.ERROR)
			return
		end
	end, {
		nargs = "*",
		complete = function(_, line)
			if string.match(vim.trim(line), "^Spade") then
				return vim.tbl_keys(subcommands)
			end

			return {}
		end,
		desc = "Spade language support for Neovim",
	})
end

vim.api.nvim_create_autocmd("User", {
	pattern = "TSUpdate",
	callback = function()
		require("nvim-treesitter.parsers").spade = {
			install_info = {
				url = "https://gitlab.com/spade-lang/tree-sitter-spade",
				branch = "main",
				files = { "src/parser.c" },
			},
		}
	end,
})

local function start_lsp()
	if M.swim_root_dir() ~= nil then
		-- see https://neovim.discourse.group/t/how-to-add-a-custom-server-to-nvim-lspconfig/3925
		vim.lsp.start({
			name = "spade-lsp",
			cmd = { M.config.lsp_command },
			root_dir = M.swim_root_dir(),
		})
	else
		vim.notify("No `swim.toml` configuration found", vim.log.levels.WARN)
	end
end

function M.setup(opts)
	M.config = vim.tbl_deep_extend("force", M.config, opts or {})

	if opts.lazy and (not vim.fn.expand("%:e") == "spade") then
		vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
			pattern = "*.spade",
			callback = function()
				install_command()
			end,
			once = true,
		})
		vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
			pattern = "*.spade",
			callback = function()
				start_lsp()
			end,
		})
	else
		install_command()
		start_lsp()
	end
end

return M
