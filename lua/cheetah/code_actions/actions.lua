local M = {}

local terminal = require("toggleterm.terminal")
local plenary = require("plenary")


local function new_term(opts)
	return terminal.Terminal:new(
		vim.tbl_extend(
			'force',
			{
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
			},
			opts
		)
	)
end

local function action(title, cmd)
	return {
		title = title,
		action = function()
			new_term({ cmd = cmd }):toggle()
		end
	}
end

local function action_with_args(title, cmd)
	local data_path = plenary.Path:new(vim.fn.stdpath('data'), "cheetah")
	data_path:mkdir({ exists_ok = true })
	local file_name = data_path:joinpath(vim.fn.sha256(cmd))
	local actions = {
		{
			title = title,
			action = function()
				vim.ui.input({ prompt = "Enter Args:" }, function(input)
					if input == nil then
						return
					end
					file_name:write(input, 'w')
					new_term({ cmd = string.format("%s %s", cmd, input) }):toggle()
				end)
			end
		},
	}
	if file_name:exists() then
		table.insert(actions, {
			title = string.format("%s - cached", title),
			action = function()
				local contents = file_name:read()
				vim.ui.input({ prompt = "Enter Args:", default = contents }, function(input)
					if input == nil then
						return
					end
					file_name:write(input, 'w')
					new_term({ cmd = string.format("%s %s", cmd, input) }):toggle()
				end)
			end

		})
	end
	return actions
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
				unpack(action_with_args("Go - run file with args", fileCmd)),
				unpack(action_with_args("Go - run module with args", modCmd)),
			}
		end
	end
end

function M.python(params)
	local fileCmd = string.format("python3 %s", params.bufname)
	local actions = {
		action("Python - run file", fileCmd),
		unpack(action_with_args("Python - run file with args", fileCmd)),
	}
	return actions
end

function M.lua(params)
	local fileCmd = string.format("lua %s", params.bufname)
	return {
		action("Lua - run file", fileCmd),
		unpack(action_with_args("Lua - run file with args", fileCmd)),
	}
end

return M
