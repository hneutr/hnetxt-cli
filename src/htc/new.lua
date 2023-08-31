local Metadata = require("hd.metadata")

return {
    description = "make a new note",
    action = function()
        local note = Metadata()
        note:write()
        print(note.path)
    end,
}
