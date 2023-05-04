require("approot")("/Users/hne/lib/hnetxt-cli/")

local Path = require("hl.path")
local Registry = require("htl.project.registry")

local M = {}

function M.default_project()
    return Registry():get_entry_name(Path.cwd())
end

return M
