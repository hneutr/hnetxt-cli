table = require("hl.table")
string = require("hl.string")
local Yaml = require("hl.yaml")
local Path = require("hl.path")
local Colors = require("htc.colors")
local Project = require("htl.project")
local NotesRegistry = require("htl.project.notes")
local Util = require("htc.util")

local function set_notes_registry(args, _, project_name)
    print(require("inspect")(args))
    print(require("inspect")(_))
    print(require("inspect")(project_name))
    print(require("inspect")("wumba"))
    project_name = project_name or Util.default_project()
    if not project_name then
        print("Provide a project.")
        os.exit()
    end

    args.notes_registry = NotesRegistry.from_project_name(project_name)
end

local function find_entry_set(args, notes_registry)
    if args.entry_set then
        return args.entry_set
    end

    local path = Path.cwd()
    if Path.is_relative_to(path, notes_registry.root) then
        path = Path.relative_to(path, notes_registry.root)

        local paths = table.list_extend({path}, Path.parents(path))
        for _, p in ipairs(paths) do
            if notes_registry.entry_sets[p] then
                args.entry_set = p
                return args.entry_set
            end
        end
    end
end

local function set_entry_sets(args)
    local entry_set = find_entry_set(args, args.notes_registry)

    local entry_sets = {}
    if entry_set then
        for _, entry_set in ipairs(table.keys(notes_registry.entry_sets)) do
            if entry_set:startswith(args.entry_set) then
                table.insert(entry_sets, entry_set)
            end
        end
    else
        entry_sets = table.keys(notes_registry.entry_sets)
    end

    return entry_sets
end

local function parse_path(args)

    if Path.is_relative_to(Path.cwd(), registry.root) then
        dir = Path.cwd()
    else
        dir = registry.root
    end

end

local function map_field_values(fields, values)
    local map = {}
    for i, field in ipairs(fields) do
        map[field] = values[i]
    end
    return map
end

local function append_to_args(args, key, values)
    for _, value in ipairs(values) do
        table.insert(args[key], value)
    end
end

local function key_val_parse(args, args_key, key_val_list)
    for _, key_val in ipairs(key_val_list) do
        local key, val = unpack(key_val:split('='))

        if val:find(",") then
            val = val:split(',')
        end

        if val == 'true' then
            val = true
        elseif val == 'false' then
            val = false
        end

        args[args_key][key] = val
    end
end

local params = {
    path = {"path", args = "1"},
    project = {
        key = "-p --project",
        val = {
            default = Util.default_project() or "",
            target = 'notes_registry',
            convert = function(project_name)
                print(require("inspect")("111"))
                if #project_name == 0 then
                    print("Provide a project.")
                    os.exit()
                else
                    return NotesRegistry.from_project_name(project_name)
                end
            end,
        },
    },
    entry_set = {
        key = "-e --entry_set",
        val = {
            args = "1",
            default = "",
            action = function(args)
                print(require("inspect")("hi"))
                -- print(require("inspect")(args))
                -- local entry_set = find_entry_set(args, args.notes_registry)
                -- if notes_registry.entry_sets[entry_set] then
                --     return entry_set
                -- end
                -- return nil
            end,
        },
    },
    metadata = {key = "-m --metadata", val = {args = "*", action = key_val_parse, init = {}}},
    field = {key = "-f --field", val = {args = "*", action = append_to_args, init = {}}},
    value = {key = "-v --value", val = {args = "*"}},
    index = {key = "-i --index", val = {description = "index to work on"}},
    to = {key = "-t --to", val = {description = "destination"}},
    date = {key = "-d --date", val = {description = "date", default = os.date("%Y%m%d")}},
    response = {
        key = "-r --response",
        val = {
            flag = true,
            default = false,
            description = "operate on a response",
            action = "store_true",
        },
    },
}

return {
    description = "commands for notes",
    commands = {
        entry = {
            commands = {
                new = {
                    params.path,
                    [params.project.key] = params.project.val,
                    [params.entry_set.key] = params.entry_set.val,
                    [params.metadata.key] = params.metadata.val,
                    action = function(args)
                        -- print(require("inspect")("fuck me"))
                        -- print(require("inspect")(args))
                        -- print(require("inspect")(args))
                        -- local notes_registry = set_project_notes(args)
                        -- local entry_set = get_entry_set(args, notes_registry)
                        -- print(require("inspect")(entry_set))
                        -- local path = parse_path(args)
                        -- local location = args.location
                    end,
                },
            }
        },
        field = {
            commands = {
                -- TODO
                ls = {
                    [params.project.key] = params.project.val,
                    {"entry_set", args = "?"},
                    action = function(args)
                        local notes_registry = set_project_notes(args)
                        local entry_sets = get_entry_sets(args, notes_registry)

                        print(require("inspect")(entry_sets))
                        -- local path = parse_path(args)
                    end,
                },
                --[[
                -- TODO
                rm = {
                    params.field.key = params.field.val,
                    action = function(args)
                        print(require("inspect")("field:remove"))
                        print(require("inspect")(args))
                    end,
                },
                -- TODO
                mv = {
                    params.field.key = params.field.val,
                    params.to.key = params.to.val,
                    action = function(args)
                        print(require("inspect")("field:rename"))
                        print(require("inspect")(args))
                    end,
                },
                --]]
            },
        },
    },
}

--- common params:
--  * `-f --field`: field to set a value for (repeatable: `-f FIELD1 -v VALUE1 -f FIELD2 -v VALUE2`)
--  * `-v --value`: value of the field
--[[
local subparsers = {
    params.location,
    entry = {
        commands = {
            new = {
                params.field.key = params.field.val,
                params.value.key = params.value.val,
                action = function(args)
                    local location = args.location
                    local fields_map = map_field_values(args.fields, args.values)
                    print(require("inspect")(args))
                    -- use :new_entry
                    -- put all things that non-entry-paths will need into metadata dict
                end,
            },
            set = {
                params.field.key = params.field.val,
                params.value.key = params.value.val,
                params.index.key = params.index.val,
                action = function(args)
                    print(require("inspect")("entry:set"))
                    print(require("inspect")(args))
                    -- use :set_metadata
                end,
            },
            mv = {
                action = function(args)
                    print(require("inspect")("entry:mv"))
                    print(require("inspect")(args))
                end,
            },
            rm = {
                params.index.key = params.index.val,
                params.date.key = params.date.val,
                params.response.key = params.response.val,
                action = function(args)
                    print(require("inspect")("entry:rm"))
                    print(require("inspect")(args))
                end,
            },
            path = {
                params.index.key = params.index.val,
                params.date.key = params.date.val,
                params.response.key = params.response.val,
                action = function(args)
                    print(require("inspect")("entry:path"))
                    print(require("inspect")(args))
                    -- put all things that non-entry-paths will need into metadata dict
                end,
            },
            -- this is just an alias for `path`, involves stuff on the shell side
            -- edit = {
            --     params.index.key = params.index.val,
            --     params.date.key = params.date.val,
            --     params.response.key = params.response.val,
            --     action = function(args)
            --         print(require("inspect")("entry:edit"))
            --         print(require("inspect")(args))
            --     end,
            -- },
            paths = {
                action = function(args)
                    print(require("inspect")("entry:paths"))
                    print(require("inspect")(args))
                end,
            },
            ----------------------------------[ prompts ]-----------------------------------
            -- for prompt entries
            close = {
                action = function(args)
                    print(require("inspect")("entry:close"))
                    print(require("inspect")(args))
                    -- use :close
                end,
            },
            reopen = {
                action = function(args)
                    print(require("inspect")("entry:reopen"))
                    print(require("inspect")(args))
                    -- use :reopen
                end,
            },
            response = {
                ["-a --all"] = {flag = true, default = false, description = "show all", action = "store_true"},
                action = function(args)
                    print(require("inspect")("entry:response"))
                    print(require("inspect")(args))
                    -- use :response
                end,
            },
            respond = {
                action = function(args)
                    print(require("inspect")("entry:respond"))
                    print(require("inspect")(args))
                    -- use :respond
                end,
            },
            ---------------------------------[ responses ]----------------------------------
            pin = {
                params.date.key = params.date.val,
                action = function(args)
                    print(require("inspect")("entry:pin"))
                    print(require("inspect")(args))
                    -- use :pin
                end,
            },
            unpin = {
                params.date.key = params.date.val,
                action = function(args)
                    print(require("inspect")("entry:unpin"))
                    print(require("inspect")(args))
                    -- use :unpin
                end,
            },
            -- TODO
            list = {
                params.field.key = params.field.val,
                params.value.key = params.value.val,
                ["--no-date-sort"] = {flag = true, default = true, target = 'date_sort', action = "store_false"},
                ["--by-field"] = {default = 'none', description = "sort by field"},
                action = function(args)
                    print(require("inspect")("entry:list"))
                    print(require("inspect")(args))
                end,
            },
        },
    },
    value = {
        params.field.key = params.field.val,
        params.value.key = params.value.val,
        commands = {
            -- TODO
            rm = {
                action = function(args)
                    print(require("inspect")("val:remove"))
                    print(require("inspect")(args))
                end,
            },
            -- TODO
            mv = {
                params.to.key = params.to.val,
                action = function(args)
                    print(require("inspect")("val:rename"))
                    print(require("inspect")(args))
                end,
            },
        },
    },
}
--]]

--[[

function get_metadata_by_path(dir, topics, active, recursive)
    if recursive == nil then
        recursive = true
    end
    local metadata_by_path = {}
    for _, path in ipairs(Path.iterdir(dir, {recursive = recursive, dirs = false})) do
        local metadata, _ = unpack(Yaml.read_document(path))

        if active_match(metadata, active) and topical_match(metadata, topics) then
            metadata_by_path[path] = metadata
        end
    end

    return metadata_by_path
end

function topical_match(metadata, topics)
    if not topics or #topics == 0 then
        return true
    end

    metadata.topics = metadata.topics or {}

    for _, topic in ipairs(topics) do
        if table.list_contains(metadata.topics, topic) then
            return true
        end
    end

    return false
end

function active_match(metadata, active)
    if active == nil then
        return true
    end

    if metadata.active == nil then
        metadata.active = true
    end

    return metadata.active == active
end

function clean_path(path, dir, indent)
    indent = indent or ''
    path = Path.relative_to(path, dir)
    path = Path.with_suffix(path, '')
    path = path:gsub("-", " ")
    path = path:removeprefix("/")
    return indent .. path
end

function get_entry_list_strings(metadata_by_path, dir, date_sort, indent)
    local paths = table.keys(metadata_by_path)

    if date_sort then
        table.sort(paths, function(a, b)
            return metadata_by_path[a].date < metadata_by_path[b].date
        end)
    end

    local strings = {}
    for _, path in ipairs(paths) do
        local pre = indent or ''
        local str = clean_path(path, dir)

        if date_sort then
            pre = pre .. Colors("%{green}" .. metadata_by_path[path].date .. "%{reset}")
        end

        if #pre > 0 then
            str = string.format("%s: %s", pre, str)
        end
        table.insert(strings, str)
    end

    return strings
end

function dirs_by_level(root)
    indent = indent or ''
    local dirs_by_parent = {}
    local dirs = Path.iterdir(root, {recursive = false, files = false})
    table.sort(dirs, function(a, b) return a < b end)

    local results = {}
    for _, dir in ipairs(dirs) do
        table.insert(results, {path = dir, level = 0})

        local subresults = dirs_by_level(dir)
        table.keys(subresults, function(a, b) return a.path < b.path end)
        for _, subresult in ipairs(subresults) do
            table.insert(results, {path = subresult.path, level = subresult.level + 1})
        end
    end

    return results
end

return {
    description = "commands for yaml stuff",
    commands = {
        list = {
            ["--no-date-sort"] = {flag = true, default = true, target = 'date_sort', action = "store_false"},
            ["-t --topics"] = {args = "*", default = {}, action = "concat"},
            ["--inactive"] = {flag = true, default = true, target = 'active', action = "store_false"},
            ["--not-by-dir"] = {flag = true, default = true, target = 'by_dir', action = "store_false"},
            ["--dir"] = {default = Path.cwd()},
            action = function(args)
                local lines = {}
                if args.by_dir then
                    local results = dirs_by_level(args.dir)
                    for i, result in ipairs(results) do
                        local metadata_by_path = get_metadata_by_path(
                            result.path,
                            args.topics,
                            args.active,
                            false
                        )

                        local result_strings = get_entry_list_strings(
                            metadata_by_path,
                            result.path,
                            args.date_sort,
                            string.rep("    ", result.level + 1)
                        )

                        if #result_strings and #lines > 0 then
                            table.insert(lines, "")
                        end
                        local indent = string.rep("    ", result.level)
                        local relative_path = Path.relative_to(result.path, args.dir)

                        local header = indent .. Colors("%{magenta}" .. relative_path .. "%{reset}:")

                        lines = table.list_extend(lines, {header}, result_strings)
                    end
                else
                    lines = get_entry_list_strings(
                        get_metadata_by_path(args.dir, args.topics, args.active),
                        args.dir,
                        args.date_sort
                    )
                end

                for _, line in ipairs(lines) do
                    print(line)
                end
            end,
        },
        fields = {
            ["--dir"] = {default = Path.cwd()},
            action = function(args)
                local excluded_fields = {'date', 'active'}
                local fields = {}
                for _, metadata in pairs(get_metadata_by_path(args.dir)) do
                    for field, value in pairs(metadata) do
                        if not table.list_contains(excluded_fields, field) then
                            fields[field] = fields[field] or {}

                            if type(value) == 'table' then
                                for _, val in ipairs(value) do
                                    fields[field][tostring(val)] = true
                                end
                            else
                                fields[field][tostring(value)] = true
                            end
                        end
                    end
                end

                local field_names = table.keys(fields)
                table.sort(field_names)

                for _, field in ipairs(field_names) do
                    local values = table.keys(fields[field])
                    table.sort(values)
                    print(string.format("%s: %s", field, string.join(", ", values)))
                end
            end,
        },
        entry = {
            commands = {
                new = {
                    {"name", args = "1"},
                    ["-d --date"] = {default = os.date("%Y%m%d"), convert = tonumber},
                    ["-t --topics"] = {args = "*", action = "concat"},
                    ["--dir"] = {default = Path.cwd()},
                    action = function(args)
                        local path = Path.joinpath(args.dir, args.name)

                        if Path.suffix(path) ~= '.md' then
                            path = Path.with_suffix(".md")
                        end

                        Yaml.write_document(path, {date = args.date, topics = args.topics})
                        print(path)
                    end
                },
            },
        },
    }
}
--]]
