require("approot")("/Users/hne/lib/hnetxt-cli/")

local argparse = require("argparse")
local Project = require("hnetxt-cli.project")
local Journal = require("hnetxt-cli.journal")

M = {
    subparsers = {
        project = require("hnetxt-cli.project"),
        journal = require("hnetxt-cli.journal"),
        move = require("hnetxt-cli.move"),
        goals = require("hnetxt-cli.goals"),
    },
}
M.command_target = "command"

function M.parser()
    local parser = argparse("hnetxt", "commands for hnetxt")
    parser:command_target(M.command_target)

    for name, mod in pairs(M.subparsers) do
        mod.extend_parser(parser):command_target(M.subcommand_target(name))
    end

    return parser
end

function M.subcommand_target(name)
    return name .. "_command"
end

function M.run()
    local args = M.parser():parse()

    local command = args.command

    local subparser = M.subparsers[command]
    local subcommand = args[M.subcommand_target(command)]

    if subcommand then
        subparser[subcommand](args)
    else
        subparser.run(args)
    end
end

M.run()
