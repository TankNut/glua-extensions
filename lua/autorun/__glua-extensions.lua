require("glua-extensions")

-- Yes you read that correctly, I'm both requiring and including the module.
-- This makes sure the file is loaded as a module and makes it work with autorefresh.
-- There might be side effects, but I haven't noticed any (yet).
include("includes/modules/glua-extensions.lua")
