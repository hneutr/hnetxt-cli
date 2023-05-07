table = require("hl.table")
string = require("hl.string")
local Yaml = require("hl.yaml")
local Path = require("hl.path")
local Colors = require("htc.colors")

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
