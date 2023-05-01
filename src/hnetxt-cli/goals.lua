local Path = require("hneutil.path")
local Goals = require("hnetxt-lua.goals")
local Config = require("hnetxt-lua.config")

local M = {}
M.config = Config.get("goals")

function M.extend_parser(parser)
    goals = parser:command("goals", "commands for goals")
    goals:option("-y --year", "year", os.date("%Y"))
    goals:option("-m --month", "month", os.date("%m"))

    return goals
end

function M.run(args)
    local path = Path.joinpath(M.config.dir, string.format("%s%s.md", args.year, args.month))
    print(path)
end

return M
