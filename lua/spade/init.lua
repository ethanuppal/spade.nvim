local M = {}

M.config = {
	lsp_command = "spade-language-server",
}

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
	vim.lsp.start({
		cmd = { M.config.lsp_command },
		root_dir = vim.fn.getcwd(),
	})

	-- vim.api.nvim_create_autocmd("FileType", {
	-- 	pattern = "spade",
	-- 	callback = function()
	-- 		-- Your custom LSP setup for Spade files
	-- 		vim.lsp.start({
	-- 			name = "spade-lsp",
	-- 			cmd = { M.config.lsp_command },
	-- 			root_dir = vim.fs.dirname(vim.fs.find({ "swim.toml" }, { upward = true })[1]),
	-- 		})
	-- 	end,
	-- })
end

function M.setup(opts)
	M.config = vim.tbl_deep_extend("force", M.config, opts or {})

	setup_treesitter()
	setup_lsp()
end

return M
