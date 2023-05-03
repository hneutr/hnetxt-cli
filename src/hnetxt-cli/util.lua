require("approot")("/Users/hne/lib/hnetxt-cli/")

local Path = require("hneutil.path")
local Registry = require("hnetxt-lua.project.registry")

local M = {}

function M.default_project()
    return Registry():get_entry_name(Path.cwd())
end

return M
