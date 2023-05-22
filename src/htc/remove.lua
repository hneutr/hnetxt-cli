local Path = require("hl.path")
local Operator = require("htl.operator")
local Notes = require("htl.project.")

return {
    description = "remove things from a project",
    action = function(args) Operator.remove(args.source) end,
    {"source", description = "what to remove", args = "1", convert = Path.resolve},
}
