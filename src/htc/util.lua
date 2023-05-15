require("approot")("/Users/hne/lib/hnetxt-cli/")

local Path = require("hl.path")
local Registry = require("htl.project.registry")

local M = {}

function M.default_project()
    return Registry():get_entry_name(Path.cwd())
end

function M.key_val_parse(args, args_key, key_val_list)
    for _, key_val in ipairs(key_val_list) do
        local key, val = unpack(key_val:split('='))

        if val:find(",") then
            val = val:split(',')
        end

        if val == 'true' then
            val = true
        elseif val == 'false' then
            val = false
        end

        args[args_key][key] = val
    end
end

return M
