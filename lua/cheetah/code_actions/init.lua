local make_builtin = require("null-ls.helpers").make_builtin
local methods = require("null-ls.methods")
local actions = require('cheetah.code_actions.actions')


return make_builtin({
	name = "cheetah",
	meta = {
		description = "Run code files as an lsp code action",
	},
	method = methods.CODE_ACTION,
	filetypes = { "python", "go" },
	generator = {
		fn = function(params)
			return actions[params.ft] or {}
		end
	}
})
