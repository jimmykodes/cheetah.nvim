local make_builtin = require("null-ls.helpers").make_builtin
local methods = require("null-ls.methods")

return make_builtin({
	name = "cheetah",
	meta = {
		description = "Run code files as an lsp code action",
	},
	method = methods.internal.CODE_ACTION,
	filetypes = { "python", "go", "lua" },
	generator = {
		fn = function(params)
			local ft_actions = require('cheetah.code_actions.actions')[params.ft]
			if ft_actions ~= nil then
				return ft_actions(params)
			else
				return {}
			end
		end
	}
})
