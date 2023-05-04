local Util = require("htc.util")
local Journal = require("htl.journal")

return {
    description = "get the path to a particular project and/or period's journal",
    {"project", description = "project name", default = Util.default_project(), args = "?"},
    ["-y --year"] = {default = os.date("%Y")},
    ["-m --month"] = {default = os.date("%m")},
    action = function(args) print(Journal(args)) end,
}
