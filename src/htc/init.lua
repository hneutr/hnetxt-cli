require("approot")("/Users/hne/lib/hnetxt-cli/")

local argparse = require("argparse")
local Command = require("htc.command")

local subparsers = {
    project = require("htc.project"),
    journal = require("htc.journal"),
    move = require("htc.move"),
    remove = require("htc.remove"),
    goals = require("htc.goals"),
    notes = require("htc.notes"),
}

local parser = argparse("hnetxt", "commands for hnetxt")
for subparser_name, subparser_commands in pairs(subparsers) do
    Command():add(parser, subparser_commands, subparser_name)
end

parser:parse()
