local Goals = require("htl.goals")
return {
    description = "return the path to a set of goals",
    action = function(args) print(Goals(args)) end,
    {"-y --year", default = os.date("%Y")},
    {"-m --month", default = os.date("%m")},
}
