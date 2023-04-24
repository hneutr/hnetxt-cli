require("approot")("/Users/hne/lib/hnetxt-cli/")

local Path = require("hneutil.path")
local Project = require("hnetxt-lua.project")
local Registry = require("hnetxt-lua.project.registry")

local M = {}

function M.add_command_to_parser(parser)
    subparser = parser:command("project", "commands for projects")

    local create = subparser:command("create")
    create:option("-n --name", "project name")
    create:option("-s --start-date", "start date of the project", os.date("%Y%m%d"))
    create:option("-d --dir", "project directory", Path.cwd())

    local root = subparser:command("root")
    root:option("-n --name", "project name")
    root:option("-d --dir", "project directory", Path.cwd())

    return subparser
end

function M.create(args)
    Project.create(args.name, args.dir)
end

function M.root(args)
    local name = args.name

    if not name then
        name = Registry():get_entry_name(args.dir)
    end

    local project = Project(name)
    print(project.root)
end

return M
