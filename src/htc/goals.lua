local Goals = require("htl.goals")
return {
    description = "get the path to a particular period's goals",
    action = function(args) print(Goals(args)) end,
    opts = {
        {"-y --year", default = os.date("%Y")},
        {"-m --month", default = os.date("%m")},
    },
}
