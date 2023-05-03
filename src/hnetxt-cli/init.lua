require("approot")("/Users/hne/lib/hnetxt-cli/")

local argparse = require("argparse")
local Command = require("hnetxt-cli.command")

local subparsers = {
    project = require("hnetxt-cli.project"),
    journal = require("hnetxt-cli.journal"),
    move = require("hnetxt-cli.move"),
    goals = require("hnetxt-cli.goals"),
}

local parser = argparse("hnetxt", "commands for hnetxt")
for subparser_name, subparser_commands in pairs(subparsers) do
    Command():add(parser, subparser_name, subparser_commands)
end

parser:parse()
