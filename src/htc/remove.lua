local Path = require("hl.path")
local Operator = require("htl.project.move.operator")
local Notes = require("htl.project.")

return {
    description = "remove things from a project",
    args = {{"path", description = "what to remove", args = "1", convert = Path.resolve}},
    action = function(args)
        print(require("inspect")(args))
        -- over here, what we need to do is:
        -- 1. if a path is an entry, move/remove it
        -- 2. move/remove mirrors of the path
        -- Operator.operate(args.source, args.target)
    end,
}
