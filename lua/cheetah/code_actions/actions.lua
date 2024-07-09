local M = {}

local terminal = require("toggleterm.terminal")
local plenary = require("plenary")

local function term_opts()
	return {
		hidden = true,
		close_on_exit = false,
		direction = "float",
		float_opts = {
			border = "none",
			width = 100000,
			height = 100000,
		},
		on_open = function(_)
			vim.cmd("startinsert!")
		end,
		on_close = function(_) end,
		count = 99,
	}
end

local function action(title, cmd)
	return {
		title = title,
		action = function()
			local Terminal = terminal.Terminal
			local opts = term_opts()
			opts.cmd = cmd
			local term = Terminal:new(opts)
			term:toggle()
		end
	}
end

local function action_with_args(title, cmd)
	return {
		title = title,
		action = function()
			vim.ui.input(
				{ prompt = "Enter Args:" },
				function(input)
					local Terminal = terminal.Terminal
					local opts = term_opts()
					opts.cmd = string.format("%s %s", cmd, input)
					local term = Terminal:new(opts)
					term:toggle()
				end)
		end
	}
end

function M.go(params)
	local main = false
	for _, line in ipairs(params.content) do
		if line == "package main" then
			main = true
		elseif line == "func main() {" and main then
			local fileCmd = string.format("go run %s", params.bufname)
			local modCmd = string.format("go run %s", plenary.Path:new(params.bufname):parent())
			return {
				action("Go - run file", fileCmd),
				action("Go - run module", modCmd),
				action_with_args("Go - run file with args", fileCmd),
				action_with_args("Go - run module with args", modCmd),
			}
		end
	end
end

function M.python(params)
	for _, line in ipairs(params.content) do
		if line == 'if __name__ == "__main__":' or line == "if __name__ == '__main__':" then
			local fileCmd = string.format("python3 %s", params.bufname)
			return {
				action("Python - run file", fileCmd),
				action_with_args("Python - run file with args", fileCmd),
			}
		end
	end
end

return M
