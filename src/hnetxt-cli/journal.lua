local Project = require("hnetxt-lua.project")
local Path = require("hneutil.path")
local Config = require("hnetxt-lua.config")

local M = {}

function M.add_command_to_parser(parser)
    subparser = parser:command("journal", "commands for journals")
    subparser:option("-n --name", "project name")

    return subparser
end

function M.run(args)
    local project
    if args.name then
        project = Project(args.name)
    elseif Project.in_project(args.dir) then
        project = Project.from_path(args.dir)
    end

    local path
    if project then
        path = project:get_journal_path()
    else
        path = Path.joinpath(Config.get("journal").dir, os.date("%Y%m") .. ".md")
    end

    print(path)
end

return M
