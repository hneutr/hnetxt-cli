string = require("hl.string")
local Set = require("pl.Set")
local Dict = require("hl.Dict")
local Path = require("hl.path")
local Colors = require("htc.colors")
local Notes = require("htl.notes")
local Util = require("htc.util")
local Object = require('hl.object')

--------------------------------------------------------------------------------
--                                  Printer                                   --
--------------------------------------------------------------------------------
local Printer = Object:extend()
Printer.color = nil
Printer.indent_size = 4

function Printer:new(notes, args, indent)
    self.notes = notes
    self.args = args
    self.indent = indent or 0

    self:setup()
end

function Printer:setup()
    self.ChildPrinterClass = nil
    self.note_key = nil
end

function Printer:has_group_by_metadata()
    local group_by_metadata = self.args.group_by_metadata or {}
    return #Dict.keys(group_by_metadata) > 0 or #List(group_by_metadata) > 0
end

function Printer:has_metadata()
    return self.args.list_metadata or self:has_group_by_metadata()
end

function Printer:note_value(note)
    return nil
end

function Printer:note_values(note)
    local value = self:note_value(note)
    local values

    if type(value) == 'table' then
        values = value
    else
        values = {value}
    end

    return values
end

function Printer:note_sort_value(note)
    return self:note_value(note)
end

function Printer:values()
    local values = List()
    for _, note in ipairs(self.notes) do
        values:extend(self:note_values(note))
    end

    return Set.values(Set(values))
end

function Printer:notes_by_value()
    local notes_by_value = {}
    for _, note in ipairs(self.notes) do
        for _, value in ipairs(self:note_values(note)) do
            notes_by_value[value] = notes_by_value[value] or List()
            notes_by_value[value]:append(note)
        end
    end

    return notes_by_value
end

function Printer:sorted_values()
    local values = self:values()

    local value_to_sort_value = Dict()
    for _, note in ipairs(self.notes) do
        value_to_sort_value[self:note_value(note)] = tostring(self:note_sort_value(note))
    end

    table.sort(values, function(a, b) return value_to_sort_value[a] < value_to_sort_value[b] end)
    return values
end

function Printer:print()
    local notes_by_value = self:notes_by_value()

    for _, value in ipairs(self:sorted_values()) do
        self:print_value(value, notes_by_value[value])
    end
end

function Printer:print_value(value, value_notes)
    local value_str = self:value_str(value, value_notes)

    if self.ChildPrinterClass and value_notes then
        local child_indent = self.indent

        if #tostring(value) > 0 then
            child_indent = child_indent + 1
            print(value_str .. ":")
        end

        self:print_value_children(value, value_notes, child_indent)
    elseif #tostring(value) > 0 then
        print(value_str)
    end
end

function Printer:print_value_children(value, notes, indent)
    self.ChildPrinterClass(notes, self.args, indent):print()
end

function Printer:colorize(str)
    if self.color then
        str = Colors("%{" .. self.color .. "}" .. str .. "%{reset}")
    end

    return str
end

function Printer:indent_str(str)
    return string.rep(" ", self.indent * self.indent_size) .. str
end

function Printer:value_str(value)
    return self:indent_str(self:colorize(tostring(value)))
end

--------------------------------------------------------------------------------
--                                DatePrinter                                 --
--------------------------------------------------------------------------------
local DatePrinter = Printer:extend()
DatePrinter.color = 'yellow'

function DatePrinter:value(note)
    if note.metadata and note.metadata.date then
        return note.metadata.date
    end

    return nil
end

function DatePrinter:value_str(value)
    if value == nil then
        value = "        "
    end

    return self:colorize(tostring(value))
end

--------------------------------------------------------------------------------
--                                FilePrinter                                 --
--------------------------------------------------------------------------------
local FilePrinter = Printer:extend()

function FilePrinter:setup()
    self.DatePrinter = DatePrinter()
end

function FilePrinter:note_value(note)
    return note[self.args.show_note]
end

function FilePrinter:note_sort_value(note)
    local sort_value

    if self.args.sort_by_date then
        sort_value = self.DatePrinter:value(note)
    end

    return sort_value or self:note_value(note)
end

function FilePrinter:value_str(value, value_notes)
    local str = self:colorize(tostring(value))

    if self.args.show_date then
        local date_str = self.DatePrinter:value_str(self.DatePrinter:value(value_notes[1]))

        if #date_str > 0 then
            str = string.format("%s %s", date_str, str)
        end
    end

    return self:indent_str(str)
end

--------------------------------------------------------------------------------
--                                ValuePrinter                                --
--------------------------------------------------------------------------------
local ValuePrinter = Printer:extend()
-- TODO: color by expected/unexpected
ValuePrinter.color = 'cyan'

function ValuePrinter:setup()
    self.key = self.args.metadata_key

    if self.args.list_metadata then
        if self.args.show_notes then
            self.ChildPrinterClass = FilePrinter
        end
    else
        self.ChildPrinterClass = FilePrinter

        local group_by_metadata = self.args.group_by_metadata or {}
        self.allowed_values = group_by_metadata[self.key]

        if type(self.allowed_values) ~= 'table' then
            self.allowed_values = {self.allowed_values}
        end

        self.allowed_values = List(self.allowed_values)
    end
end

function ValuePrinter:filter_values(values)
    if self.args.list_metadata or #self.allowed_values == 0 then
        return values
    end

    local _values = List()
    for i, value in ipairs(values) do
        if self.allowed_values:contains(value) then
            _values:append(value)
        end
    end

    return _values
end

function ValuePrinter:note_value(note)
    local metadata = note.metadata or {}
    return metadata[self.key]
end

function ValuePrinter:note_values(note)
    local values = self.super.note_values(self, note)
    return self:filter_values(values)
end

function ValuePrinter:sorted_values()
    local values = self:values()
    table.sort(values)
    return values
end

--------------------------------------------------------------------------------
--                                FieldPrinter                                --
--------------------------------------------------------------------------------
local FieldPrinter = Printer:extend()
FieldPrinter.color = 'green'

function FieldPrinter:setup()
    if self:has_metadata() then
        self.ChildPrinterClass = ValuePrinter

        self.allowed_values = List(self.args.group_by_metadata):extend(
            Dict.keys(self.args.group_by_metadata)
        )
    else
        self.ChildPrinterClass = FilePrinter
    end
end

function FieldPrinter:filter_values(values)
    local _values = List()
    for i, value in ipairs(values) do
        if value ~= 'date' then
            _values:append(value)
        end
    end

    values = _values

    if self.args.list_metadata then
        return values
    end

    local _values = List()
    for i, value in ipairs(values) do
        if List.contains(self.allowed_values, value) then
            _values:append(value)
        end
    end

    return _values
end

function FieldPrinter:note_value(note)
    local metadata = note.metadata or {}
    return Dict.keys(metadata)
end

function FieldPrinter:note_values(note)
    local values = self.super.note_values(self, note)
    return self:filter_values(values)
end

function FieldPrinter:sorted_values()
    local values = self:values()
    return values
end

function FieldPrinter:print_value_children(value, notes, indent)
    if self:has_metadata() then
        ValuePrinter(notes, Dict.update({metadata_key = value}, self.args), indent):print()
    else
        FilePrinter(notes, self.args, indent):print()
    end
end

--------------------------------------------------------------------------------
--                                 SetPrinter                                 --
--------------------------------------------------------------------------------
local SetPrinter = Printer:extend()
SetPrinter.color = 'magenta'

function SetPrinter:setup()
    local group_by_metadata = self.args.group_by_metadata
    if self.args.list_metadata or #Dict.keys(group_by_metadata) > 0 or #List(group_by_metadata) > 0 then
        self.ChildPrinterClass = FieldPrinter
    else
        self.ChildPrinterClass = FilePrinter
    end
end

function SetPrinter:note_value(note)
    return note.set_path
end

--------------------------------------------------------------------------------
--                                                                            --
--                                                                            --
--                                  commands                                  --
--                                                                            --
--                                                                            --
--------------------------------------------------------------------------------
return {
    description = "commands for notes",
    commands = {
        touch = {
            description = "make a new note",
            {"path", args = "1", default = '.', convert = Path.resolve},
            {"+d --date", description = "use today's date for the file name", switch = 'on'},
            {"+n --next", description = "use the new available index for the file name", switch = 'on'},
            mutexes = {{"-d --date", "-n --next"}},
            action = function(args)
                local path = args.path
                local note_set = Notes.path_set(path)

                if note_set then
                    path = note_set:touch(args.path, args)
                end

                print(path)
            end,
        },
        list = {
            description = "list note-like things",
            {"path", args = "1", default = '.', convert = Path.resolve},
            {"+m", target = "list_metadata", description = "list metadata", switch = "on"},
            {
                "+u",
                target = "value_type",
                description = "if -m, exclude expected values.",
                action = Util.store("unexpected"),
            },
            {
                "+e",
                target = "value_type",
                description = "if -m, exclude unexpected values.",
                action = Util.store("expected"),
            },
            {
                "-f",
                description = string.join(
                    "\n",
                    {
                        "metadata to filter entries by.",
                        "* -f k=v → {k = v}",
                        "* -f k   → {k}",
                        "* -f k+  → {k = true}",
                        "* -f k-  → {k = false}",
                    }
                ),
                target = "filters",
                init = {},
                args = "*",
                action = Util.key_val_parse,
                argname = "FILTER",
            },
            {
                "-g",
                target = "group_by_metadata",
                description = "metadata to group by. Behaves like -f",
                init = {},
                args = "*",
                action = Util.key_val_parse,
            },
            {"+F", target = "apply_config_filters", description = "don't apply config filters", switch = "off"},
            {"+D", target = "sort_by_date", description = "sort by date.", switch = "off"},
            {"+d", target = "show_date", description = "show note date.", switch = "on"},
            {"--show-note", hidden = true, default = "clean_stem", action = Util.store_default("clean_stem")},
            {"+b", target = "show_note", description = "show note blurb.", action = Util.store('blurb')},
            {"+p", target = "show_note", description = "show raw note path.", action = Util.store('name')},
            {"+n", target = "show_notes", description = "show note content when listing metadata.", switch = "on"},
            mutexes = {
                {"-u", "-e"},
                {"-b", "-p"},
            },
            action = function(args)
                if not args.list_metadata then
                    args.value_type = nil
                end

                local note_sets = Notes.path_sets(args.path)

                local notes = List()
                for _, note_set in pairs(note_sets) do
                    notes:extend(note_set:list(args.path))
                end

                SetPrinter(notes, args):print()
            end,
        },
    },
}
