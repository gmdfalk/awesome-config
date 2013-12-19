---------------------------------------------------
-- Licensed under the GNU General Public License v2
--  * (c) 2010, Radu A. <admiral0@tuxfamily.org>
---------------------------------------------------

-- {{{ Grab environment
local io = { popen = io.popen }
local setmetatable = setmetatable
require("awful.util")
-- }}}


-- netctl: provides active netctl network profiles
-- vicious.contrib.netctl
local netctl = {}


-- {{{ netctl widget type
local function worker(format)
    -- Initialize counters
    local profiles = {}

    local profiles = awful.util.pread("netctl list | awk '/*/ {print 2}'")

    return profiles
end
-- }}}

return setmetatable(netctl, { __call = function(_, ...) return worker(...) end })
