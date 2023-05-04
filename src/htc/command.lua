require("approot")("/Users/hne/lib/hnetxt-cli/")

table = require("hl.table")
string = require("hl.string")

local Object = require('hl.object')

local Component = Object:extend()
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

function Component.get_subcomponents(settings)
    return {}
end

function Component:add_subcomponents(parent, settings)
    for name, subsettings in pairs(self.get_subcomponents(settings)) do
        self:add(parent, name, subsettings)
    end
end

--------------------------------------------------------------------------------
--                                  Argument                                  --
--------------------------------------------------------------------------------
local Argument = Component:extend()
Argument.type = 'argument'
Argument.keys = table.list_extend({}, Component.keys, {
    'default',
    'convert',
    'args',
})

function Argument.get_subcomponents(settings)
    local subcomponent_settings = {}
    for _, subsettings in ipairs(settings) do
        subcomponent_settings[subsettings[1]] = subsettings
    end
    return subcomponent_settings
end

--------------------------------------------------------------------------------
--                                   Option                                   --
--------------------------------------------------------------------------------
local Option = Component:extend()
Option.type = 'option'
Option.keys = table.list_extend({}, Component.keys, {
    'default',
    'convert',
    'count',
    'args',
})

function Option.get_subcomponents(settings)
    local subcomponent_settings = {}
    for name, subsettings in pairs(settings or {}) do
        if type(name) == 'string' and name:startswith("-") and not subsettings.flag then
            subcomponent_settings[name] = subsettings
        end
    end
    return subcomponent_settings
end

--------------------------------------------------------------------------------
--                                    Flag                                    --
--------------------------------------------------------------------------------
local Flag = Component:extend()
Flag.type = 'flag'
Flag.keys = table.list_extend({}, Component.keys, {
    'default',
    'convert',
    'count',
})

function Flag.get_subcomponents(settings)
    local subcomponent_settings = {}
    for name, subsettings in pairs(settings or {}) do
        if type(name) == 'string' and name:startswith("-") and subsettings.flag == true then
            subcomponent_settings[name] = subsettings
        end
    end
    return subcomponent_settings
end

--------------------------------------------------------------------------------
--                                  Command                                   --
--------------------------------------------------------------------------------
local Command = Component:extend()
Command.type = 'command'
Command.keys = table.list_extend({}, Component.keys, {
    "command_target",
    "require_command",
})

function Command.get_subcomponents(settings)
    return settings.commands or {}
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
