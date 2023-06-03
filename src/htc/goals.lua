local Util = require("htc.util")
local Path = require("hl.path")
local Dict = require("hl.Dict")
local List = require("hl.List")
local Set = require("pl.Set")
local Colors = require("htc.colors")
local GoalSets = require("htl.goals.set")
local WeekSet = require("htl.goals.set.week")

local Link = require("htl.text.link")

return {
    description = "return the path to a journal",
    {
        "--to_touch",
        hidden = true,
        default = os.date("%Y%m%d"),
        action = Util.store_default(os.date("%Y%m%d")),
    },
    {
        "path",
        description = "path to touch",
        args = "?",
        action = function(args, _, raw)
            if raw ~= nil then
                args.to_touch = raw
            end
        end,
    },
    {"+y", description = "touch the year file", action = Util.store_to(os.date("%Y"), "to_touch")},
    {"+m", description = "touch the month file", action = Util.store_to(os.date("%Y%m"), "to_touch")},
    {"+w", description = "touch the week file", action = Util.store_to(WeekSet.current_stem, "to_touch")},
    {
        "-a",
        description = "what to do",
        target = "action",
        default = "touch",
        choices = {"touch", "to_close", "to_create"},
        convert = {
            touch = function(args) print(GoalSets.touch(args.to_touch)) end,
            to_close = function(args) GoalSets.to_close():foreach(print) end,
            to_create = function(args) GoalSets.to_create():foreach(print) end,
        },
    },
    action = function(args)
        args.action(args)
    end,
}
