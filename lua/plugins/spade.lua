-- https://github.com/nvim-treesitter/nvim-treesitter
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
