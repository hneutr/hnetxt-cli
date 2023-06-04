rockspec_format= "3.0"
package = "hnetxt-cli"
version = "dev-1"
source = {
   url = "*** please add URL for source tarball, zip or repository here ***"
}
description = {
   homepage = "*** please enter a project homepage ***",
   license = "*** please specify a license ***",
   license = "MIT"
}
dependencies = {
   "lua >= 5.1",
   "lyaml >= 6.2",
   "inspect >= 3.1",
   "lua-cjson >= 2.1",
}
build = {
   type = "builtin",
   modules = {
      ["htc"] = "src/htc/init.lua",
      ["htc.command"] = "src/htc/command.lua",
      ["htc.util"] = "src/htc/util.lua",
      ["htc.journal"] = "src/htc/journal.lua",
      ["htc.project"] = "src/htc/project.lua",
      ["htc.move"] = "src/htc/move.lua",
      ["htc.remove"] = "src/htc/remove.lua",
      ["htc.goals"] = "src/htc/goals.lua",
      ["htc.notes"] = "src/htc/notes.lua",
      ["htc.colors"] = "src/htc/colors.lua",
      ["htc.colorize"] = "src/htc/colorize.lua",
   }
}
test = {
   type = "busted",
   platforms = {
      unix = {
         flags = {
            "--exclude-tags=ssh,git"
         }
      },
      windows = {
         flags = {
            "--exclude-tags=ssh,git,unix"
         }
      }
   }
}
