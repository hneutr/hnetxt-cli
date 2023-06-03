local Util = require("htc.util")
local Journal = require("htl.journal")

return {
    description = "return the path to a journal",
    action = function(args) print(Journal(args)) end,
    {"project", description = "project name", default = Util.default_project(), args = "?"},
    {"-y --year", default = os.date("%Y")},
    {"-m --month", default = os.date("%m")},
}
