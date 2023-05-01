require("approot")("/Users/hne/lib/hnetxt-cli/")

local Path = require("hneutil.path")
local Project = require("hnetxt-lua.project")
local Operator = require("hnetxt-lua.project.move.operator")

local M = {}

function M.extend_parser(parser)
    local move = parser:command("move")
    move:argument("source", "what to move"):args(1):convert(Path.resolve)
    move:argument("target", "where to move it to"):args(1):convert(Path.resolve)
    move:option("-d --dir", "project directory", Path.cwd())
    move:option("-p --process", "process", true)
    move:option("-u --update", "update", true)

    return move
end

function M.run(args)
    Operator.operate(args.source, args.target, {
        process = args.process,
        update = args.update,
        dir = Project.root_from_path(source),
    })
end

return M
