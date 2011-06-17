-- Grab environment.
local awful = awful
local naughty = naughty
local mouse = mouse
local pairs = pairs
local ipairs = ipairs
local table = table
local string = string
local client = client
local io = io
local screen = screen
local math = math

module("vain.util")

-- Like awful.menu.clients, but only show clients of currently selected
-- tags.
function menu_clients_current_tags(menu, args)

    -- List of currently selected tags.
    local cls_tags = awful.tag.selectedlist(mouse.screen)

    -- Final list of menu items.
    local cls_t = {}

    if cls_tags == nil
    then
        return nil
    end

    -- For each selected tag get all clients of that tag and add them to
    -- the menu. A click on a menu item will raise that client.
    for i = 1,#cls_tags
    do
        local t = cls_tags[i]
        local cls = t:clients()

        for k, c in pairs(cls)
        do
            cls_t[#cls_t + 1] = { awful.util.escape(c.name) or "",
                                  function ()
                                      c.minimized = false
                                      client.focus = c
                                      c:raise()
                                  end,
                                  c.icon }
        end
    end

    -- No clients? Then quit.
    if #cls_t <= 0
    then
        return nil
    end

    -- menu may contain some predefined values, otherwise start with a
    -- fresh menu.
    if not menu
    then
        menu = {}
    end

    -- Set the list of items and show the menu.
    menu.items = cls_t
    local m = awful.menu.new(menu)
    m:show(args)
    return m
end

-- Destroys all current/visible naughty notifications.
function clear_naughty()
    -- First, store current items. Necessary because naughty.destroy()
    -- interferes with the iteration.
    local notis = {}
    for _, scr in ipairs(naughty.notifications)
    do
        for _, ori in pairs(scr)
        do
            for _, noti in pairs(ori)
            do
                table.insert(notis, noti)
            end
        end
    end

    -- Got 'em, destroy 'em.
    for _, noti in pairs(notis)
    do
        naughty.destroy(noti)
    end
end

-- Checks whether this element exists in the table.
function element_in_table(element, table)
    for k, v in pairs(table)
    do
        if v == element
        then
            return true
        end
    end
    return false
end

-- Read the first line of a file or return nil.
function first_line(f)
    local fp = io.open(f)
    if not fp
    then
        return nil
    end

    local content = fp:read("*l")
    fp:close()
    return content
end

-- Pad a number (float) with leading zeros and add thousand separators.
-- For example,
--
--     print(vain.util.paddivnum(1234567.123, 8, 2))
--
-- shows
--
--     01,234,567.12
--
-- That's handy if you need strings of fixed lengths. However, this only
-- works for positive numbers.
function paddivnum(num, padlen, declen)
    local rounded = string.format('%.' .. declen .. 'f', num)
    local intpart, decpart = string.match(rounded, '([^.]+)\.(.*)')
    intpart = string.rep('0', padlen - #intpart) .. intpart
    intpart = string.reverse(intpart)
    intpart = string.gsub(intpart, '(%d%d%d)', '%1,')
    intpart = string.reverse(intpart)
    intpart = string.gsub(intpart, '^,', '')
    return intpart .. '.' .. decpart
end

-- Move the mouse away: To the (bottom|top) (left|right) minus a little
-- offset.
-- 0 = bottom left, 1 = top left, 2 = top right, 3 = bottom right.
function move_mouse_away(target)
    local g = {}
    local mg = screen[mouse.screen].geometry

    if target == nil then target = 0 end

    if target < 2
    then
        g.x = mg.x + 1
    else
        g.x = mg.x + mg.width - 2
    end

    if target == 1 or target == 2
    then
        g.y = mg.y + 1
    else
        g.y = mg.y + mg.height - 2
    end

    mouse.coords(g)
end

-- Magnify a client: Set it to "float" and resize it.
function magnify_client(c)
    awful.client.floating.set(c, true)

    local mg = screen[mouse.screen].geometry
    local tag = awful.tag.selected(mouse.screen)
    local mwfact = awful.tag.getmwfact(tag)
    local g = {}
    g.width = math.sqrt(mwfact) * mg.width
    g.height = math.sqrt(mwfact) * mg.height
    g.x = mg.x + (mg.width - g.width) / 2
    g.y = mg.y + (mg.height - g.height) / 2
    c:geometry(g)
end

-- Trim a string.
-- See also: http://lua-users.org/wiki/StringTrim
function trim(s)
    return s:match "^%s*(.-)%s*$"
end

-- vim: set et :
