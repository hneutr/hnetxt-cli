local Path = require("hneutil.path")
local Util = require("hnetxt-cli.util")

local Project = require("hnetxt-lua.project")
local Registry = require("hnetxt-lua.project.registry")
local Flag = require("hnetxt-lua.text.flag")

return {
    description = "commands for projects",
    commands = {
        create = {
            {"project", default = Path.name(Path.cwd()), args = "1"},
            ["-s --start-date"] = {default = os.date("%Y%m%d")},
            ["-d --dir"] = {default = Path.cwd(), description = "project directory"},
            action = function(args)
                Project.create(args.name, args.dir, {start_date = args.start_date})
            end,
        },
        register = {
            {"project", default = Path.name(Path.cwd()), args = "1"},
            ["-d --dir"] = {default = Path.cwd(), description = "project directory"},
            action = function(args)
                Registry():set_entry(args.project, args.dir)
            end,
        },
        root = {
            {"project", description = "project name", default = Util.default_project(), args = "1"},
            action = function(args)
                print(Project(args.project).root)
            end,
        },
        flags = {
            {"project", description = "project name", default = Util.default_project(), args = "1"},
            ["-f --flag"] = {default = 'question', description = "flag type"},
            action = function(args)
                local root = Project(args.project).root
                for _, instance in ipairs(Flag.get_instances(args.flag, root)) do
                    print(instance)
                end
            end,
        }
    }
}
