local Path = require("hl.path")
local List = require("hl.List")
local GoalSets = require("htl.goals.set")
local WeekSet = require("htl.goals.set.week")
local Colorize = require("htc.colorize")

local shorthands = {
    d = os.date("%Y%m%d"),
    w = WeekSet.current_stem,
    m = os.date("%Y%m"),
    y = os.date("%Y"),
}

local function convert_shorthand(set)
    set = shorthands[set or 'd'] or set

    if #Path.suffix(set) == 0 then
        set = set .. ".md"
    end

    return set
end

local function shorthand_help()
    return "\n" .. List({'d', 'w', 'm', 'y'}):transform(function(s)
        return string.format(" %s = %s", s, convert_shorthand(s))
    end):join("\n") .. "\n"
end

return {
    commands = {
        aim = {
            description = "touch a goalset and return its path.",
            {
                "path",
                description = "a set path or shorthand: " .. shorthand_help(),
                default = convert_shorthand('d'),
                convert = convert_shorthand,
            },
            action = function(args)
                print(GoalSets.touch(args.path))
            end,
        },
        goals = {
            commands = {
                to_close = {
                    description = "list past but unclosed goalsets.",
                    action = function() GoalSets.to_close():foreach(print) end,
                },
                to_create = {
                    description = "list current but empty goalsets.",
                    action = function() GoalSets.to_create():foreach(print) end,
                },
            },
        },
    },
}
