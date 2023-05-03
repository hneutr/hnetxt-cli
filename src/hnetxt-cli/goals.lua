local Goals = require("hnetxt-lua.goals")
return {
    description = "get the path to a particular period's goals",
    ["-y --year"] = {default = os.date("%Y")},
    ["-m --month"] = {default = os.date("%m")},
    action = function(args) print(Goals(args)) end,
}
