local Project = require("hnetxt-lua.project")
local Path = require("hneutil.path")
local Config = require("hnetxt-lua.config")

local M = {}
M.config = Config.get("journal")

function M.extend_parser(parser)
    journal = parser:command("journal", "commands for journals")
    -- journal:option("-n --name", "project name")
    journal:argument("project", "name of the project"):args("?")
    journal:option("-y --year", "year", os.date("%Y"))
    journal:option("-m --month", "month", os.date("%m"))

    return journal
end

function M.run(args)
    local project
    if args.project then
        project = Project(args.project)
    else
        project = Project.from_path()
    end

    local dir = M.config.dir
    if project then
        dir = Path.joinpath(project.root, M.config.project_dir)
    end

    local path = Path.joinpath(dir, string.format("%s%s.md", args.year, args.month))
    print(path)
end

return M
