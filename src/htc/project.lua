local Dict = require("hl.Dict")
local Path = require("hl.path")
local Util = require("htc.util")
local Colors = require("htc.colors")

local Project = require("htl.project")
local Registry = require("htl.project.registry")
local Flag = require("htl.text.flag")
local List = require("htl.text.list")

local args = {
    new_project = {"project", default = Path.name(Path.cwd()), args = "1"},
    project = {"project", description = "project name", default = Util.default_project(), args = "1"},
}

local opts = {
    dir = {"-d --dir", default = Path.cwd(), description = "project directory"},
}

return {
    description = "commands for projects",
    commands = {
        create = {
            args.new_project,
            {"-s --start-date", default = os.date("%Y%m%d")},
            opts.dir,
            action = function(args) Project.create(args.name, args.dir, {start_date = args.start_date}) end,
        },
        register = {
            args.new_project,
            opts.dir,
            action = function(args) Registry():set_entry(args.project, args.dir) end,
        },
        root = {
            args.project,
            action = function(args) print(Project(args.project).root) end,
        },
        flags = {
            args.project,
            {"+f --flag", default = 'question', description = "flag type"},
            action = function(args)
                local instances = Flag.get_instances(args.flag, Project(args.project).root)
                local paths = Dict.keys(instances)
                table.sort(paths)

                for _, path in ipairs(paths) do
                    print(Colors("%{magenta}" .. path .. "%{reset}") .. ":")
                    for _, instance in ipairs(instances[path]) do
                        print("    " .. instance)
                    end
                end
            end,
        },
        list = {
            args.project,
            {"-l --list_type", default = 'question', description = "list type"},
            action = function(args)
                local instances = List.Parser.get_instances(args.list_type, Project(args.project).root)
                local paths = Dict.keys(instances)
                table.sort(paths)

                for _, path in ipairs(paths) do
                    local lines = instances[path]
                    table.sort(lines, function(a, b) return a.line_number < b.line_number end)

                    print(Colors("%{magenta}" .. path .. "%{reset}") .. ":")
                    for _, instance in ipairs(lines) do
                        print(Colors("    %{green}" .. instance.line_number .. "%{reset}: " .. instance.text))
                    end
                end
            end,
        },
    }
}
