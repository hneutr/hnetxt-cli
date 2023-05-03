local Path = require("hneutil.path")
local Operator = require("hnetxt-lua.project.move.operator")

return {
    description = "move things within a project",
    {"source", description = "what to move", args = "1", convert = Path.resolve},
    {"target", description = "where to move it", args = "1", convert = Path.resolve},
    action = function(args)
        Operator.operate(args.source, args.target)
    end,
}
