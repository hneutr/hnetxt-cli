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
   "hneutil-lua",
   "hnetxt-lua"
}
build = {
   type = "builtin",
   modules = {
      ["hnetxt-cli"] = "src/hnetxt-cli/init.lua",
      ["hnetxt-cli.journal"] = "src/hnetxt-cli/journal.lua",
      ["hnetxt-cli.project"] = "src/hnetxt-cli/project.lua",
      ["hnetxt-cli.move"] = "src/hnetxt-cli/move.lua",
      ["hnetxt-cli.goals"] = "src/hnetxt-cli/goals.lua",
      setup = "src/setup.lua"
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
