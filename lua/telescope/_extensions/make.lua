local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local conf = require("telescope.config").values
local action_state = require("telescope.actions.state")
local actions = require("telescope.actions")
local Terminal = require("toggleterm.terminal").Terminal
local config   = require("telescope-makefile.config")

local function get_targets()
    local data
    for _, make_dir in ipairs(config.makefile_priority) do
        local handle = io.popen("make -pRrq -C ".. make_dir .. [[ : 2>/dev/null |
                awk -F: '/^# Files/,/^# Finished Make data base/ {
                    if ($1 == "# Not a target") skip = 1;
                    if ($1 !~ "^[#.\t]") { if (!skip) {if ($1 !~ "^$")print $1}; skip=0 }
                }' 2>/dev/null]])
        if not handle then
            break
        end
        data = handle:read("*a")
        io.close(handle)
        if #data ~= 0 then
            break
        end
    end
    if #data == 0 then
        return
    end
	return vim.split(string.sub(data, 1, #data - 1), '\n')
end

local function run_target(cmd)
	local run_term = Terminal:new({
		cmd = config.toggle_term.cmd .. " " .. cmd[1],
		direction = config.toggle_term.direction,
		close_on_exit = config.toggle_term.close_on_exit,
	})

	run_term:toggle()
end

local telescope_makefile = function(opts)
    local targets = get_targets()
    if not targets then
        vim.notify("No make targets")
        return
    end
	pickers.new(opts, {
		prompt_title = "Make",
		finder = finders.new_table(targets),
		sorter = conf.generic_sorter({}),
		attach_mappings = function(prompt_bufnr, _)
            actions.select_default:replace(function ()
                actions.close(prompt_bufnr)
				local command = action_state.get_selected_entry()
                if not command then
                    return
                end
				run_target(command)
            end)
			return true
		end,
	}):find()
end

return require("telescope").register_extension({
	exports = {
		make = telescope_makefile,
	},
})
