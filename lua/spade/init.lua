-- Based off of https://github.com/NMAC427/guess-indent.nvim

local M = {}

M.config = {
	lsp_command = "spade-language-server",
}

--- Determines the closest parent directory containing `swim.toml`.
function M.swim_root_dir()
	local current_buffer_path = vim.fn.expand("%:p")
	if current_buffer_path == nil then
		current_buffer_path = vim.uv.cwd()
	end
	return vim.fs.dirname(vim.fs.find({ "swim.toml" }, {
		path = current_buffer_path,
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
		return
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

local function setup_treesitter()
	-- see https://github.com/nvim-treesitter/nvim-treesitter
	require("nvim-treesitter.install").prefer_git = true
	require("nvim-treesitter.parsers").get_parser_configs()["spade"] = {
		install_info = {
			url = "https://gitlab.com/spade-lang/tree-sitter-spade/",
			files = { "src/parser.c" },
			branch = "main",
			generate_requires_npm = false,
			requires_generate_from_grammar = false,
		},
		filetype = "spade",
	}
end

local function setup_lsp()
	-- see https://neovim.discourse.group/t/how-to-add-a-custom-server-to-nvim-lspconfig/3925
	vim.api.nvim_create_autocmd("FileType", {
		pattern = "spade",
		callback = function()
			install_command()

			if M.swim_root_dir() ~= nil then
				vim.lsp.start({
					name = "spade-lsp",
					cmd = { M.config.lsp_command },
					root_dir = M.swim_root_dir(),
				})
			else
				vim.notify("No `swim.toml` configuration found", vim.log.levels.WARN)
			end
		end,
	})
end

function M.setup(opts)
	M.config = vim.tbl_deep_extend("force", M.config, opts or {})

	setup_treesitter()
	setup_lsp()
end

return M
