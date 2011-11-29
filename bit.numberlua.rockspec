package = "bit.numberlua"
version = "$(_VERSION)"
source = {
   url = "https://github.com/davidm/lua-bit-numberlua/zipball/v$(_VERSION)",
}
description = {
   summary    = "'bit.numberlua' Bitwise operators in pure Lua using Lua numbers",
   detailed   = [[
      Note: use a C binding instead for higher performance.
   ]],
   license    =  "MIT/X11",
   homepage   = "https://github.com/davidm/lua-bit-numberlua",
   maintainer = "David Manura <http://lua-users.org/wiki/DavidManura>",
}
dependencies = {
}
build = {
  type = "none",
  install = {
     lua = {
        ["bit.numberlua"] = "lmod/bit/numberlua.lua",
     }
  }
}
