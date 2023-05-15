require("approot")("/Users/hne/lib/hnetxt-cli/")

table = require("hl.table")
string = require("hl.string")

local Object = require('hl.object')

local Component = Object:extend()
Component.config_key = 'comp'
Component.keys = {
    "description",
    "action",
    "target",
}
Component.type = ''

function Component:add(parent, name, settings)
    local object = parent[self.type](parent, name)

    for _, key in ipairs(self.keys) do
        if settings[key] then
            object[key](object, settings[key])
        end
    end

    return object
end

function Component:add_subcomponents(parent, settings)
    for _, subsettings in ipairs(settings[self.config_key] or {}) do
        self:add(parent, subsettings[1], subsettings)
    end
end

--------------------------------------------------------------------------------
--                                  Argument                                  --
--------------------------------------------------------------------------------
local Argument = Component:extend()
Argument.config_key = 'args'
Argument.type = 'argument'
Argument.keys = table.list_extend({}, Component.keys, {
    'default',
    'convert',
    'args',
})

--------------------------------------------------------------------------------
--                                   Option                                   --
--------------------------------------------------------------------------------
local Option = Component:extend()
Option.type = 'option'
Option.config_key = 'opts'
Option.keys = table.list_extend({}, Component.keys, {
    'default',
    'convert',
    'count',
    'args',
    'init',
})

--------------------------------------------------------------------------------
--                                    Flag                                    --
--------------------------------------------------------------------------------
local Flag = Component:extend()
Flag.config_key = 'flags'
Flag.type = 'flag'
Flag.keys = table.list_extend({}, Component.keys, {
    'default',
    'convert',
    'count',
})

--------------------------------------------------------------------------------
--                                  Command                                   --
--------------------------------------------------------------------------------
local Command = Component:extend()
Command.type = 'command'
Command.config_key = 'commands'
Command.keys = table.list_extend({}, Component.keys, {
    "command_target",
    "require_command",
})

function Command:add_subcomponents(parent, settings)
    for key, subsettings in pairs(settings[self.config_key] or {}) do
        self:add(parent, key, subsettings)
    end
end

function Command:add(parent, name, settings)
    local object = self.super.add(self, parent, name, settings)

    Argument():add_subcomponents(object, settings)
    Option():add_subcomponents(object, settings)
    Flag():add_subcomponents(object, settings)
    self:add_subcomponents(object, settings)

    return object
end

return Command
