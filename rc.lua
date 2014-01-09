--- AwesomeWM 3.4.15 rc.lua ---

-- =====================================================================
-- {{{ s_libs
-- =====================================================================

awful = require("awful")
awful.autofocus = require("awful.autofocus")
awful.rules = require("awful.rules")
beautiful = require("beautiful")
naughty = require("naughty")
vicious = require("vicious")
scratch = require("scratch")
vain = require("vain")
vain.widgets.terminal = "urxvt"
require("misc.revelation")

-- }}}

-- =====================================================================
-- {{{ s_vars
-- =====================================================================

-- env
home            = os.getenv("HOME")
config          = awful.util.getdir("config")
local hostname  = io.lines("/proc/sys/kernel/hostname")()

-- apps
exec            = awful.util.spawn
sexec           = awful.util.spawn_with_shell
terminal        = "urxvt"
editor          = "geany"

-- appearance
barheight       = 16
borderwidth     = 0

sharedthemes    = "/usr/share/awesome/themes/"
themelap        = "/redhalo/theme.lua"
themehtpc       = "/redhalo/theme.lua"
theme           = "/zenburn/theme.lua"
themedir        = config .. "/themes"
wicons          = themedir .. "/icons"

-- keys should look neat
winkey  = "Mod4"
altkey  = "Mod1"

if hostname == 'laptop' then
    if not awful.util.file_readable(themedir..themelap) then
        themedir  = sharedthemes
        wicons    = themedir .. "/icons"
    end
    beautiful.init(themedir..themelap)
elseif hostname == 'htpc' then
    if not awful.util.file_readable(themedir..themehtpc) then
        themedir  = sharedthemes
        wicons    = themedir .. "/icons"
    end
    --winkey = "Mod1"
    --altkey = "Mod4"
    beautiful.init(themedir..themehtpc)
else
    if not awful.util.file_readable(themedir..theme) then
        themedir  = sharedthemes
        wicons    = themedir .. "/icons"
    end
    beautiful.init(themedir..theme)
end

k_n     = {}
k_a     = { altkey }
k_as    = { altkey, "Shift" }
k_ac    = { altkey, "Control" }
k_acs   = { altkey, "Control", "Shift" }
k_aw    = { altkey, winkey }
k_aws   = { altkey, winkey, "Shift" }
k_w     = { winkey }
k_ws    = { winkey, "Shift" }
k_wc    = { winkey, "Control" }
k_wcs   = { winkey, "Control", "Shift" }
k_c     = { "Control" }
k_s     = { "Shift" }
k_cs    = { "Control", "Shift" }

-- Notifications
-- blue "#34bdef", green "#a6e22e", red "#f92671"
require("misc.notifications")
naughty.config.default_preset.position     = "top_right"
naughty.config.presets.normal.border_color = "grey" --beautiful.border_focus or '#535d6c'
naughty.config.default_preset.border_width = 1

-- }}}

-- =====================================================================
-- {{{ s_layouts
-- =====================================================================

layouts = {
    awful.layout.suit.tile,             --1
    awful.layout.suit.tile.bottom,      --2
    vain.layout.uselessfair.horizontal, --3
    vain.layout.uselessspiral.dwindle,  --4
    vain.layout.centerwork,             --5
    awful.layout.suit.magnifier,        --6
    awful.layout.suit.floating,         --7
    awful.layout.suit.max,              --8 
}

media = {
    awful.layout.suit.tile,
    awful.layout.suit.max.fullscreen,
    awful.layout.suit.floating,
}

gimp = {
    awful.layout.suit.tile,
    --vain.layout.gimp, -- Single-Window-Mode! yay
    --vain.layout.centerwork,
    awful.layout.suit.floating,
}

-- }}}

-- =====================================================================
-- {{{ s_menu
-- =====================================================================

-- Menu (gathering dust)
mymainmenu = awful.menu({ items = {
        { "edit config", editor .. " " .. awful.util.getdir("config") .. "/rc.lua"},
        { "restart", awesome.restart },
        { "run", function() mypromptbox[mouse.screen]:run() end },
        { "open terminal", terminal }
    }
})

-- Rightclick on Desktop for Menu (more dust)
root.buttons(awful.util.table.join(
    awful.button(k_n, 3, function () mymainmenu:toggle() end)
))

-- Launcher Icon (from dust till dawn)
--~ mylauncher = awful.widget.launcher({    image = image(beautiful.awesome_icon),
                                        --~ menu = mymainmenu
--~ })

-- }}}

-- =====================================================================
-- {{{ s_tags
-- =====================================================================

gold = 0.618
tags = {
    { name = "♏", layout = layouts[1], mwfact = 0.5   },  --dev
    { name = "♐", layout = layouts[1], mwfact = 0.55  },  --www
    { name = "⌘", layout = layouts[1], mwfact = 0.7   },  --irc
    { name = "☊", layout = media[1],   mwfact = 0.6  },  --vlc
    { name = "♓", layout = layouts[7]                 },  --fun
    { name = "⌥", layout = gimp[1],    mwfact = gold  },  --gimp
    { name = "♒", layout = layouts[1], mwfact = gold  },  --work
    --{ name = "✿♉",  layout = layouts[1], mwfact = 0.4, nmaster = 1, ncol = 2 },
}

for s = 1, screen.count() do
    --tags[s] = {}
    for i, v in ipairs(tags) do
        tags[s][i] = tag({ name = v.name })
        tags[s][i].screen = s
        awful.tag.setproperty(tags[s][i], "layout", v.layout)
        awful.tag.setproperty(tags[s][i], "mwfact", v.mwfact)
        awful.tag.setproperty(tags[s][i], "ncol", v.ncol)
        awful.tag.setproperty(tags[s][i], "nmaster", v.nmaster)
        awful.tag.setproperty(tags[s][i], "hide",   v.hide)
    end
    tags[s][1].selected = true
end
-- }}}

-- =====================================================================
-- {{{ s_widgets
-- =====================================================================

-- Separators
spacer      = widget({ type = "textbox" })
spacer.text = " "

-- Register
if hostname == 'htpc' then

    -- HVOLwidget
    volicon = widget({ type = "imagebox" })
    volicon.image = image(wicons .. "/him/vol-red.png")
    volwidget = widget({ type = "textbox" })
    vicious.register(volwidget, vicious.widgets.volume, "$1$2", 1, "Master")
    volwidget:buttons(awful.util.table.join(
    awful.button(k_n, 1, function () sexec("amixer -q set Master toggle") end)
    ))
    -- HMEMwidget
    memwidget = widget({ type = "textbox" })
    vicious.register(memwidget, vicious.widgets.mem, "$1%", 30)

    -- HNETwidget
    dnicon = widget({ type = "imagebox" })
    upicon = widget({ type = "imagebox" })
    dnicon.image = image(wicons .. "/him/downw-red.png")
    upicon.image = image(wicons .. "/him/upw-green.png")
    netwidget = widget({ type = "textbox" })
    vicious.register(netwidget, vicious.widgets.net, "${enp4s0 down_kb} / ${enp4s0 up_kb}", 1)

    -- HCPUwidget
    cpuicon = widget({ type = "imagebox" })
    cpuicon.image = image(wicons .. "/him/cpuinfow-blue.png")
    cpuwidget = widget({ type = "textbox" })
    vicious.register(cpuwidget, vicious.widgets.cpu, "$1%", 1)

    -- HTEMPwidget
    tempwidget = widget({ type = "textbox" })
    vicious.register(tempwidget, vicious.widgets.thermal, "$1°C", 30, { "coretemp.0", "core"})
    --vicious.register(tempwidget, vicious.widgets.thermal, "$1°C", 30, "thermal_zone0")]]

    -- HOSwidget
    --~ osicon = widget({ type = "imagebox" })
    --~ osicon.image = image(wicons .. "/him/cpuinfo-red.png")
    --~ oswidget = widget({ type = "textbox" })
    --~ vicious.register(oswidget, vicious.widgets.os, "$2", 120)

    --[[ HFSwidget
    fswidget = widget({ type = "textbox" })
    vicious.register(fswidget, vicious.widgets.fs, '${/ avail_gb}G', 120)
    disk = require("misc.diskusage")
    -- the first argument is the widget to trigger the diskusage
    -- the second/third is the percentage at which a line gets orange/red
    -- true = show only local filesystems
    disk.addToWidget(fswidget, 75, 90, true)]]
elseif hostname == 'laptop' then
    --[[ NETwidget (TODO)
    neticon = widget({ type = "imagebox" })
    neticon.image = image(wicons .. "/him/wifi-blue.png")
    -- Netcfg widget
    vicious.contrib = require("vicious.contrib")
    netcfgwidget = widget({ type = "textbox" })
    vicious.register(netctlwidget, vicious.contrib.netctl, "$1", 10)]]

    -- BATwidget
    baticon = widget({ type = "imagebox" })
    batwidget = widget({ type = "textbox" })
    --batwidget:set_background_color(beautiful.bg_normal)
    function battery()
        local output = ''
        local batpath = "/sys/devices/platform/smapi/BAT0"

        file = io.open(batpath .. "/state", "r")
        local state = file:read()
        file:close()

        file = io.open(batpath .. "/remaining_percent", "r")
        local percent = file:read("*n")
        file:close()

        if (state == "discharging") then
            if(percent < 5) then
                baticon.image = image(wicons .. "/him/bat-red.png")
                sexec("systemctl suspend")
            elseif(percent < 15) then
                baticon.image = image(wicons .. "/him/bat-red.png")
            elseif(percent < 25) then
                baticon.image = image(wicons .. "/him/bat-orange.png")
            else
                baticon.image = image(wicons .. "/him/bat-green.png")
            end
        elseif (state == "charging") then
            baticon.image = image(wicons .. "/him/bat-blue.png")
        else
            baticon.image = image(wicons .. "/him/bat-white.png")
        end

        file = io.open(batpath .. "/remaining_running_time", "r")
        local time = file:read()
        --local timeh = math.floor(time/60)
        --local timem = time%60
        file:close()

        local file = io.open(batpath .. "/power_now", "r")
        local watt = file:read("*n")
        file:close()

        if(state == "discharging") then
            output = percent .. "% " .. watt .. " "..time.."m"
        elseif (state == "charging") then
            file = io.open(batpath .. "/remaining_charging_time", "r")
            local time = file:read()
            --local timeh = math.floor(time/60)
            --local timem = time%60
            file:close()
            output = percent .. "% "..time.."m"
        elseif (state == "idle") then
            output = percent .. "%"
        else
            output = "N/A"
        end

        return output
    end
    batwidget.text = battery()
    batwidget:add_signal('mouse::enter', function () --TODO: add text
        batinfo =   { naughty.notify({    title      = "BAT0"
                                        , text       = "test"
                                        , timeout    = 6
                                        , position   = "top_right"
                                        , fg         = beautiful.fg_focus
                                        , bg         = beautiful.bg_focus
                                    })
        } 
    end)
    batwidget:add_signal('mouse::leave', function () naughty.destroy(batinfo[1]) end)
    mybatterytimer = timer({ timeout = 6 })
    mybatterytimer:add_signal("timeout", function() batwidget.text = battery() end)
    mybatterytimer:start()

    -- FANwidget
    fanicon = widget({ type = "imagebox" })
    fanicon.image = image(wicons .. "/him/fan-red.png")
    fanwidget = widget({ type = "textbox" })
    function fan()
        local file = io.open("/sys/devices/platform/thinkpad_hwmon/fan1_input", "r")
        local fan = file:read("*n")
        file:close()

        output = fan..'rpm'
        return output
    end
    fanwidget.text = fan()
    myfantimer = timer({ timeout = 6 })
    myfantimer:add_signal("timeout", function() fanwidget.text = fan() end)
    myfantimer:start()

    -- TEMPwidget
    tempicon = widget({ type = "imagebox" })
    tempwidget = widget({ type = "textbox" })
    function temp()
        local file = io.open("/sys/devices/platform/thinkpad_hwmon/temp1_input", "r")
        local temp = file:read("*n")
        temp = tonumber(temp)/1000
        file:close()

        if(temp > 88) then
            naughty.notify({text = ""..temp.."°C! (Suspending)"})
            sexec("sudo beep -f 800 -n -f 500 -n -f 300")
            sexec("sleep 3  && systemctl suspend")
        elseif(temp > 81) then
            naughty.notify({text = "Caution: "..temp.."°C!!"})
            --sexec("sudo beep -f 800 -n -f 500 -n -f 300")]]
            --[[tempicon.image = image(wicons .. "/him/temp-red.png")
        elseif(temp > 75) then
            tempicon.image = image(wicons .. "/him/temp-red.png")
        elseif(temp > 60) then
            tempicon.image = image(wicons .. "/him/temp-orange.png")
        else
            --tempicon.image = image(wicons .. "/him/temp-green.png")]]
        end

        output = temp..'°C'
        return output
    end
    tempwidget.text = temp()
    mytemptimer = timer({ timeout = 6 })
    mytemptimer:add_signal("timeout", function() tempwidget.text = temp() end)
    mytemptimer:start()

    -- CPUwidget
    cpuicon = widget({ type = "imagebox" })
    cpuicon.image = image(wicons .. "/him/cpuinfow-red.png")
    cpuwidget = widget({ type = "textbox" })
    vicious.register(cpuwidget, vicious.widgets.cpu, "$1%", 1)
end

-- CLOCKwidget
clockicon = widget({ type = "imagebox" })
clockicon.image = image(wicons .. "/him/clock-green.png")
mytextclock = awful.widget.textclock({align = "right"}, "%H:%M ",5)

-- Attach Calendar
local calendar = require("misc.calendar")

if hostname == htpc then
    calendar:attach(mytextclock, { font_size = 11 })
else
    calendar:attach(mytextclock)
end

-- Systray
mysystray = widget({ type = "systray" })

--}}}

-- =====================================================================
-- {{{ s_wibox
-- =====================================================================

-- Create a wibox for each screen and add it
mywibox = {}
mypromptbox = {}
mylayoutbox = {}
mytaglist = {}
mytaglist.buttons = awful.util.table.join(
    awful.button(k_n, 1, awful.tag.viewonly),
    awful.button(k_a, 1, awful.client.movetotag),
    awful.button(k_n, 3, awful.tag.viewtoggle),
    awful.button(k_a, 3, awful.client.toggletag),
    awful.button(k_n, 4, awful.tag.viewnext),
    awful.button(k_n, 5, awful.tag.viewprev)
)
mytasklist = {}
mytasklist.buttons =  awful.util.table.join(
    awful.button(k_n, 1, function (c)
        if c == client.focus then
            c.minimized = true
        else
            --~ if not c:isvisible() then
                --~ awful.tag.viewonly(c:tags()[1])
            --~ end
            -- This will also un-minimize
            -- the client, if needed
            client.focus = c
            c:raise()
        end
    end),
    awful.button(k_n, 3, function (c)
        c=awful.client.floating
        c.toggle()
    end),
    awful.button(k_n, 4, function ()
        awful.client.focus.byidx(1)
        if client.focus then client.focus:raise() end
    end),
    awful.button(k_n, 5, function ()
        awful.client.focus.byidx(-1)
        if client.focus then client.focus:raise() end
    end)
)

--???
--mymaster = { awful.tag.attached_cadd_signal(nil, "property::nmaster", function() mymaster.text = awful.tag.getnmaster() end)) }

for s = 1, screen.count() do
    -- Create a promptbox for each screen
    mypromptbox[s] = awful.widget.prompt({ layout = awful.widget.layout.horizontal.leftright })
    -- Create an imagebox widget which will contains an icon indicating which layout we're using.
    -- We need one layoutbox per screen.
    mylayoutbox[s] = awful.widget.layoutbox(s)
    mylayoutbox[s]:buttons(awful.util.table.join(
        awful.button(k_n, 1, function () awful.layout.inc(layouts, 1) end),
        awful.button(k_n, 3, function () awful.layout.inc(layouts, -1) end),
        awful.button(k_n, 4, function () awful.layout.inc(layouts, 1) end),
        awful.button(k_n, 5, function () awful.layout.inc(layouts, -1) end))
    )
    -- Create a taglist widget
    mytaglist[s] = awful.widget.taglist(s, awful.widget.taglist.label.all, mytaglist.buttons)
    -- Create a tasklist widget
    mytasklist[s] = awful.widget.tasklist(
                                        function(c)
                                            return awful.widget.tasklist.label.currenttags(c, s)
                                        end,
                                        mytasklist.buttons
    )
    -- Create the wibox
    mywibox[s] = awful.wibox({ position = "top", screen = s, border_width = borderwidth, height = barheight  })

    -- Add widgets to the wibox - order matters
    if hostname == 'laptop' then
        mywibox[s].widgets = {
            {
                mylauncher,
                mytaglist[s],
                mypromptbox[s], spacer,
                layout = awful.widget.layout.horizontal.leftright
            },
            mylayoutbox[s], spacer,
            mytextclock, spacer, clockicon, spacer,
            fanwidget, spacer, tempwidget, spacer,
            cpuwidget, spacer, cpuicon, spacer,
            batwidget, spacer, baticon,
            --~ spacer, netctlwidget, spacer, neticon,
            s == 1 and mysystray or nil, spacer,
            mytasklist[s],
            layout = awful.widget.layout.horizontal.rightleft,
        }
    else
        mywibox[s].widgets = {
            {
                mylauncher,
                mytaglist[s],
                mypromptbox[s], spacer,
                layout = awful.widget.layout.horizontal.leftright
            },
            mylayoutbox[s],
            mytextclock, clockicon, spacer,
            volwidget, spacer, volicon, spacer,
            --fswidget, spacer, osicon, spacer,
            memwidget, spacer,
            tempwidget, spacer,
            cpuwidget, spacer, cpuicon,
            upicon, netwidget, dnicon,
            s == 1 and mysystray or nil, spacer,
            mytasklist[s],
            layout = awful.widget.layout.horizontal.rightleft
        }
    end
end
-- }}}

-- =====================================================================
-- {{{ s_bindings_keyboard
-- =====================================================================

globalkeys = awful.util.table.join(
    -- run_or_raise
    --awful.key(k_a, "f",         function () run_or_raise("firefox", { class = "Firefox" }) end),
    --awful.key(k_a, "g",       function () run_or_raise("geany", { class = "Geany" }) end),
    awful.key(k_a, "t",         function () run_or_raise("thunderbird", { class = "Thunderbird" }) end),
    awful.key(k_w, "a",         function () run_or_raise("abiword", { class = "Abiword" }) end),
    awful.key(k_w, "g",         function () run_or_raise("gimp", { class = "Gimp" }) end),
    awful.key(k_w, "l",         function () run_or_raise("lowriter", { class = "libreoffice-writer" }) end),
    awful.key(k_w, "p",         function () run_or_raise("pcmanfm", { class = "Pcmanfm" }) end),
    awful.key(k_w, "s",         function () run_or_raise("skype", { class = "Skype" }) end),
    awful.key(k_w, "t",         function () run_or_raise("teamspeak3", { class = "Ts3client_linux_amd64" }) end),
    --awful.key(k_w, "w",       function () run_or_raise("word", { class = "Wine", instance = "WINWORD.EXE" }) end),
    --awful.key(k_w, "v",       function () run_or_raise("teamviewer", { class = "Wine", instance = "TeamViewer.exe" }) end),
    awful.key(k_w, "v",         function () run_or_raise("vnc2", { class = "Vncviewer" }) end),
    awful.key(k_wc, "v",        function () run_or_raise("vnc2 a", { class = "Vncviewer" }) end),
    awful.key(k_ws, "v",        function () run_or_raise("vnc2 k", { class = "Vncviewer" }) end),
    awful.key(k_w, "x",         function () run_or_raise("xchat", { class = "Xchat" }) end),
    -- free: k_a, "r"; k_a, "m"

    -- Scratchdrop
    awful.key(k_a, "a",         function () scratch.drop("urxvt -name urxvt_drop_t -e tmux", "top", "center", 1, 0.35 ) end),
    awful.key(k_a, "d",         function () scratch.drop("urxvt -name urxvt_drop_r -e tmux", "center", "right", 0.35, 1 ) end),
    --awful.key(k_a, "g",       function () scratch.drop("vnc2", "center", "center", 0.76, 0.98 ) end),
    awful.key(k_a, "s",         function () scratch.drop("urxvt -name urxvt_drop -e tmux", "bottom", "center", 1, 0.35 ) end),
    --awful.key(k_a, "t",       function () scratch.drop("thunderbird", "center", "center", 0.7, 0.8 ) end),
    awful.key(k_a, "z",         function () scratch.drop("keepnote", "center", "center", 0.7, 0.8 ) end),
    awful.key(k_w, "c",         function () scratch.drop("clementine", "center", "center", 0.8, 0.9 ) end),
    awful.key(k_w, "d",         function () scratch.drop("deluge", "center", "center", 0.7, 0.8 ) end),
    awful.key(k_w, "f",         function () run_or_raise("firefox", { class = "Firefox" }) end),
    awful.key(k_w, "m",         function () scratch.drop("gmpc", "center", "center", 0.7, 0.8 ) end),
    awful.key(k_w, "n",         function () scratch.drop("urxvt -name urxvt_drop_c -e ncmpcpp", "center", "center", 0.7, 0.8 ) end),
    --awful.key(k_w, "o",       function () scratch.drop("spotify", "center", "center", 0.7, 0.8 ) end),
    awful.key(k_w, "o",         function () run_or_raise("wspotify", { class = "Wine", instance = "spotify.exe" }) end),
    awful.key(k_w, "q",         function () scratch.drop("copyq show", "center", "right", 0.5, 0.7 ) end),
    --awful.key(k_w, "h",       function () scratch.drop("urxvt -name urxvt_ghost -e ghost", "top", "center", 0.5, 0.6 ) end),
    awful.key(k_ac, "d",        function () scratch.pad.toggle() end),

    -- Exec
    awful.key(k_a, "Return",    function () exec("urxvt -e tmux") end),
    awful.key(k_ac, "Return",   function () exec("urxvt") end),
    awful.key(k_a, ",",         function () exec("geany "..home.."/.projects/random/random.geany") end),
    awful.key(k_a, ".",         function () exec("geany "..home.."/.projects/configs/configs.geany") end),
    awful.key(k_a, "-",         function () exec("geany "..home.."/.projects/dev/dev.geany") end),
    awful.key(k_a, "Print",     function () sexec("import -window $(xdotool getwindowfocus) "..home.."/.local/screenshots/w$(date +%m-%d-%Y_%H%M%S).jpg") end),
    --awful.key(k_a, "Print",     function () sexec("(sleep 1 && xdotool click 1) & scrot -q 90 -bs "..home.."/.local/screenshots/w%m.%d.%y_%H-%M-%S.jpg") end),
    awful.key(k_n, "Print",     function () sexec("scrot -q 90 "..home.."/.local/screenshots/%m.%d.%y_%H-%M-%S.jpg") end),
    awful.key(k_w, "Print",     function () sexec("scrot -q 90 -t 30 "..home.."/.local/screenshots/t%m.%d.%y_%H-%M-%S.jpg") end),
    -- Media
    awful.key(k_n,  "XF86AudioLowerVolume",  volume_down),
    awful.key(k_n,  "XF86AudioRaiseVolume",  volume_up),
    awful.key(k_wc, "Down",     function () sexec("mpc -q -h 192.168.0.2 volume -10") end),
    awful.key(k_wc, "Up",       function () sexec("mpc -q -h 192.168.0.2 volume +10") end),
    awful.key(k_wc, "Left",     function () sexec("mpc -q -h 192.168.0.2 seek -10") end),
    awful.key(k_wc, "Right",    function () sexec("mpc -q -h 192.168.0.2 seek +10") end),
    awful.key(k_w,  "Down",     function () sexec("mpc -q -h 192.168.0.2 toggle") end),
    awful.key(k_w,  "Up",       function () sexec("mpc -q -h 192.168.0.2 stop") end),
    awful.key(k_w,  "Left",     function () sexec("mpc -q -h 192.168.0.2 prev") end),
    awful.key(k_w,  "Right",    function () sexec("mpc -q -h 192.168.0.2 next") end),

    -- WM
    awful.key(k_a, "Tab",       awful.tag.history.restore),
    awful.key(k_a, "e",         revelation),
    awful.key(k_a, "n",         awful.tag.viewnext),
    awful.key(k_a, "p",         awful.tag.viewprev),
    awful.key(k_ac, "p",        function () vain.util.tag_view_nonempty(-1) end),
    awful.key(k_ac, "n",        function () vain.util.tag_view_nonempty(1) end),
    awful.key(k_a, "u",         awful.client.urgent.jumpto),
    awful.key(k_a, "q",         function () awful.layout.set(awful.layout.suit.tile)    end),
    awful.key(k_w, "space",     function () awful.layout.set(awful.layout.suit.floating) end),
    awful.key(k_ac, "r",        awesome.restart),

    -- Default stuff (more or less)
    awful.key(k_a, "h",         function () awful.tag.incnmaster( 1)      end),
    awful.key(k_a, "l",         function () awful.tag.incnmaster(-1)      end),
    awful.key(k_ac, "h",        function () awful.tag.incncol( 1)         end),
    awful.key(k_ac, "l",        function () awful.tag.incncol(-1)         end),
    awful.key(k_ac, "0",        function () awful.tag.setncol(1)          end),
    awful.key(k_a, "0",         function () awful.tag.setnmaster(1)       end),
    awful.key(k_as, "+",        function () vain.util.useless_gaps_resize(3) end),
    awful.key(k_as, "-",        function () vain.util.useless_gaps_resize(-3) end),
    awful.key(k_as, "o",        function () mypromptbox[mouse.screen]:run() end),
    awful.key(k_as, "l",        function ()
                                    awful.prompt.run({ prompt = "Run Lua code: " },
                                    mypromptbox[mouse.screen].widget,
                                    awful.util.eval, nil,
                                    awful.util.getdir("cache") .. "/history_eval")
                                end),
    awful.key(k_a, "j",         function ()
                                    awful.client.focus.byidx( 1)
                                    if client.focus then client.focus:raise() end
                                end),
    awful.key(k_a, "k",         function ()
                                    awful.client.focus.byidx(-1)
                                    if client.focus then client.focus:raise() end
                                end),
    awful.key(k_a, "y",         function()
                                    local tags = awful.tag.selectedlist(mouse.screen)
                                    if #tags == 0 then
                                        awful.tag.viewmore(last_tags, mouse.screen)
                                    else
                                        last_tags = tags awful.tag.viewnone()
                                    end
                                end),
    awful.key(k_a, "space",     function ()
                                    local curtag = awful.tag.selected()
                                    if curtag == tags[1][6] then
                                        awful.layout.inc(gimp,  1)
                                    else
                                        awful.layout.inc(layouts,  1)
                                    end
                                end),
    awful.key(k_ac, "space",    function ()
                                    local curtag = awful.tag.selected()
                                    if curtag == tags[1][6] then
                                        awful.layout.inc(gimp,  -1)
                                    else
                                        awful.layout.inc(layouts,  -1)
                                    end
                                end)
)

if hostname == 'laptop' then
    globalkeys = awful.util.table.join(globalkeys,
        awful.key(k_ac, "Down",                  function () sexec("ssh slave@htpc 'amixer -q set Master 7-'") end),
        awful.key(k_ac, "Up",                    function () sexec("ssh slave@htpc 'amixer -q set Master 7+'") end),
        awful.key(k_n,  "XF86AudioPlay",         function () sexec("ssh slave@htpc 'spotifycmd playpause'") end),
        awful.key(k_n,  "XF86AudioPrev",         function () sexec("ssh slave@htpc 'spotifycmd prev'") end),
        awful.key(k_n,  "XF86AudioNext",         function () sexec("ssh slave@htpc 'spotifycmd next'") end),
        awful.key(k_n,  "XF86AudioStop",         function () sexec("ssh slave@htpc 'spotifycmd stop'") end),
        awful.key(k_n,  "XF86ScreenSaver",       function () sexec("sudo theftlock") end),
        awful.key(k_n,  "XF86Battery",           function () sexec("xset dpms force off; slimlock") end),
        awful.key(k_n,  "XF86Launch1",           volume_mute),
        awful.key(k_n,  "XF86MonBrightnessUp",   brightness_up),
        awful.key(k_n,  "XF86MonBrightnessDown", brightness_down)
    )
elseif hostname == 'htpc' then
    globalkeys = awful.util.table.join(globalkeys,
        awful.key(k_n,  "XF86AudioMute",         volume_mute),
        awful.key(k_n,  "XF86AudioPlay",         function () sexec("spotifycmd playpause") end),
        awful.key(k_n,  "XF86AudioPrev",         function () sexec("spotifycmd prev") end),
        awful.key(k_n,  "XF86AudioNext",         function () sexec("spotifycmd next") end),
        awful.key(k_n,  "XF86AudioStop",         function () sexec("spotifycmd stop") end),
        awful.key(k_n,  "XF86Launch1",           function () sexec("mpc toggle") end),
        awful.key(k_n,  "XF86Launch2",           function () sexec("mpc prev") end),
        awful.key(k_n,  "XF86Launch3",           function () sexec("mpc next") end),
        awful.key(k_n,  "XF86Launch4",           function () sexec("mpc stop") end)
    )
end

clientkeys = awful.util.table.join(

    awful.key(k_a, "c",     function (c) c:kill()                         end),
    awful.key(k_a, "f",     function (c) c.fullscreen = not c.fullscreen  end),
    awful.key(k_a, "x",     function (c)
                                c.maximized_horizontal = not c.maximized_horizontal
                                c.maximized_vertical   = not c.maximized_vertical
                                c.above                = not c.above
                            end),
    awful.key(k_a, "r",     function (c) c:swap(awful.client.getmaster()) end),
    awful.key(k_a, "<",     function (c)
                                if c.titlebar then
                                    awful.titlebar.remove(c)
                                    --debug_notify(c.name .. "\ntitlebar " .. colored_off)
                                else
                                    awful.titlebar.add(c, { altkey = "Mod1" })
                                    --debug_notify(c.name .. "\ntitlebar " .. colored_on)
                                end
                            end),
    awful.key(k_ac, "a",    function (c) scratch.pad.set(c, 0.60, 0.60, true) end),
    awful.key(k_ac, "f",    awful.client.floating.toggle                     ),
    awful.key(k_as, "f",    function (c) -- toggle floating but avoid uneven window resolutions for streaming with ffmpeg
                                --[[if twice then
                                    --awful.client.floating.toggle (c, true)
                                    awful.client.floating.set (c, false)
                                    twice = false
                                else
                                    twice = true]]
                                    awful.client.floating.set (c, true)
                                    local g = c:geometry()
                                    g.height = math.floor(g.height/2)*2
                                    g.width = math.floor(g.width/2)*2
                                    c:geometry(g)
                                    --c:geometry( { width = 720 , height = 450 } )
                                --end
                            end),
    awful.key(k_ac, "o",    function (c) c.ontop = not c.ontop            end),
    awful.key(k_ac, "s",    function (c) c.sticky = not c.sticky end),
    awful.key(k_ac, "v",    function (c) c.minimized = not c.minimized    end),
    awful.key(k_as, "m",    function ()  mywibox[mouse.screen].visible = not mywibox[mouse.screen].visible end),
    awful.key(k_as, "r",    function (c) c:redraw()                       end)
)

keynumber = 0
for s = 1, screen.count() do
    keynumber = math.min(9, math.max(#tags[s], keynumber));
end
for i = 1, keynumber do
    globalkeys = awful.util.table.join(globalkeys,
        awful.key(k_a, "#" .. i + 9, function ()
            local screen = mouse.screen
            if tags[screen][i] then
            awful.tag.viewonly(tags[screen][i])
            end
        end),
        awful.key(k_w, "#" .. i + 9, function ()
            local screen = mouse.screen
            if tags[screen][i] then
            awful.tag.viewtoggle(tags[screen][i])
            end
        end),
        awful.key(k_ac, "#" .. i + 9, function ()
            if client.focus and tags[client.focus.screen][i] then
            awful.client.movetotag(tags[client.focus.screen][i])
            end
        end),
        awful.key(k_as, "#" .. i + 9, function ()
            if client.focus and tags[client.focus.screen][i] then
            awful.client.toggletag(tags[client.focus.screen][i])
            end
        end)
    )
end

clientbuttons = awful.util.table.join(
    awful.button(k_n, 1, function (c) client.focus = c; c:raise() end),
    awful.button(k_w, 1, function (c) client.focus = c; c:lower() end),
    awful.button(k_a, 1, awful.mouse.client.move),
    awful.button(k_a, 3, awful.mouse.client.resize)
)

-- set keys
root.keys(globalkeys)
-- }}}

-- =====================================================================
-- {{{ s_rules
-- =====================================================================

awful.rules.rules = {
  -- All clients will match this rule.
    { rule = {},
        properties = {
            border_width         = beautiful.border_width,
            border_color         = beautiful.border_normal,
            buttons              = clientbuttons,
            keys                 = clientkeys,
            maximized_horizontal = false,
            maximized_vertical   = false,
            size_hints_honor     = false,
            focus                = true
        }
    },
    -- 1:dev
    { rule = { class = "Gedit" },
        properties = { tag = tags[1][1], switchtotag = true }
    },
    { rule = { class = "Gvim" },
        properties = { tag = tags[1][1] }
    },
    { rule = { class = "medit" }, except_any = { name = { "Preferences", "Replace", "Find" } },
        properties = { tag = tags[1][1], switchtotag = true }
    },
    { rule = { class = "Geany" }, except_any = { name = { "Preferences", "Replace", "Find", "Go to Line", "Open File", "Save File" } },
        properties = { tag = tags[1][1] }
    },
    { rule = { instance = "urxvt_edit" },
        properties = { tag = tags[1][1], switchtotag = true }
    },
    --[[{ rule = { class = "URxvt" }, except_any = { instance = { "urxvt_drop", "urxvt_edit" } },
        properties = { tag = tags[1][4] }
    },
    { rule = { instance = "urxvt_term" },
        properties = { tag = tags[1][4] }
    },]]


    -- 2:www
    { rule = { class = "Firefox" }, except = { instance = "Navigator" },
        properties = { tag = tags[1][2], floating = true },
        callback = awful.placement.centered
    },
    { rule = { class = "Firefox", instance = "Navigator" },
        properties = { tag = tags[1][2] }
    },
    { rule = { class = "Firefox", instance = "Dialog" },
        properties = { tag = tags[1][2] }
    },

    -- 3:irc
    { rule = { class = "Skype" },
        properties = { minimized = true, floating = true, skip_taskbar = true, geometry = { width = 245, height = 360, x = 1000, y = 16 } }
        --callback = awful.client.movetotag(awful.tag.selected(mouse.screen))
        --callback = awful.client.setslave
    },
    { rule = { class = "Skype", role = 'ConversationsWindow' },
        properties = { minimized = false, above = false, skip_taskbar = false, geometry = { width = 600, height = 450 } },
        callback = awful.placement.centered
    },
    { rule = { class = "Xchat" },
        properties = { tag = tags[1][3] },
        callback = awful.client.setmaster
    },
    { rule = { class = "Ts3client_linux_amd64" },
        properties = { floating = true, tag = tags[1][3], switchtotag = true },
        callback = awful.client.setslave
    },
    { rule = { class = "Ts3client_linux_amd64", name = "TeamSpeak.*" },
        properties = { floating = false },
    },

    -- 4:vlc
    { rule = { class = "Mplayer" },
        properties = { tag = tags[1][4], switchtotag = true }
    },
    --[[{ rule = { class = "Gmpc" },
        properties = { tag = tags[1][4], switchtotag = true }
    },]]
    { rule = { class = "Vlc" }, except = { role = "vlc-main" },
        properties = { tag = tags[1][4], floating = true }
    },
    { rule = { class = "Vlc", role = "vlc-main" },
        properties = { tag = tags[1][4], switchtotag = true },
        callback = awful.client.setmaster
    },
    { rule = { class = "Vlc", role= "vlc-playlist" },
        properties = { geometry = { width = 475, height = 320, x = 0, y=16 } }
    },

    -- 5:play
    { rule = { class = "VirtualBox" },
        properties = { tag = tags[1][5], floating = true },
        callback = awful.placement.centered
    },
    { rules = { class = ".*Frozen.*"},
        properties = { tag = tags[1][5], floating = true },
    },
    { rule = { class = "Wine" },
        properties = { tag = tags[1][5], floating = true, switchtotag = true }
    },
    { rule = { class = "Vncviewer" },
        properties = { tag = tags[1][5], floating = true, switchtotag = true },
        callback = awful.placement.centered
    },

    -- 6:gimp
    { rule = { class = "Gimp" }, except = { role = "gimp-image-window" },
        properties = { tag = tags[1][6] },
        callback = awful.client.setslave
    },

    { rule = { class = "Gimp", role = "gimp-image-window" },
        properties = { tag = tags[1][6], switchtotag = true },
        callback = awful.client.setmaster
    },

    -- 7:work
    { rule = { class = "LibreOffice" },
        properties = { tag = tags[1][7], switchtotag = true }
    },
    { rule = { class = "libreoffice.*" },
        properties = { tag = tags[1][7], switchtotag = true }
    },
    { rule = { class = "AbiWord" },
        properties = { tag = tags[1][7], switchtotag = true }
    },
    { rule = { class = "Wine", instance = "WINWORD.EXE" },
        properties = { tag = tags[1][7], switchtotag = true }
    },

    -- General
    { rule_any = { class = { "Sonata", "Zenity", "Orage", "Gxmessage", "Keepnote" } },
        properties = { floating = true }
    },
    { rule = { class = "Tk", name = "Blockify-UI" },
        properties = { floating = true },
        callback = awful.placement.centered
    },
    { rule_any = { class = { "Xephyr", "Plugin-container" }, instance = { "urxvt_drop" } },
        properties = { floating = true, border_width = 0, above = true }
    },
    { rule = { class = "Thunderbird" }, except = { role = "3pane" },
        properties = { floating = true, geometry = { width = 764, height = 684 } },
        callback = awful.placement.centered
    },
    { rule = { class = "Pcmanfm", name="Execute File" },
        properties = { floating = true, sticky = true, ontop = true, above = true },
        callback = awful.placement.centered
    },
    { rule_any = { class = { "Copyq", "Zenity" } },
        properties = { floating = true, sticky = true, ontop = true, above = true, geometry = { width = 300, height = 400 } },
        callback = awful.placement.centered
    }
}

if hostname == 'htpc' then
    awful.rules.htpc = awful.util.table.join(
        { rule = { class = "Spotify", instance="spotify" },
            properties = { floating = true, tag = tags[1][5], geometry = { width = 1094, height = 866 } },
            callback = awful.placement.centered
        },
        { rule = { class = "Wine", instance="spotify.exe" },
            properties = { geometry = { width = 1094, height = 866 } },
            callback = awful.placement.centered
        }
    )
end

awful.rules.rules = awful.util.table.join(
    awful.rules.rules,
    vain.layout.gimp.rules,
    awful.rules.htpc
)
-- }}}

-- =====================================================================
-- {{{ s_signals
-- =====================================================================

-- Signal function to execute when a new client appears.
client.add_signal("manage",
    function (c, startup)
        -- Add a titlebar
        --awful.titlebar.add(c, { altkey = altkey })

        -- Enable sloppy focus
        c:add_signal("mouse::enter", function(c)
            if awful.layout.get(c.screen) ~= awful.layout.suit.magnifier
            and awful.client.focus.filter(c) then
                 client.focus = c
            end
        end)
    --awful.placement.under_mouse(c)

        -- Client placement
        if not startup then
            -- Set the windows at the slave,
            -- i.e. put it at the end of others instead of setting it master.
            --awful.client.setslave(c)

            -- Put windows in a smart way, only if they does not set an initial position.
            if not c.size_hints.user_position and not c.size_hints.program_position then
                awful.placement.no_overlap(c)
                awful.placement.no_offscreen(c)
            end
        end
    end)
    
-- Focus signal handlers
client.add_signal("focus",
    function (c)
        c.border_color = beautiful.border_focus
        c.opacity = 1
        --c.border_width = 0
    end)

client.add_signal("unfocus",
    function(c)
        c.border_color = beautiful.border_normal
        c.opacity = 1
    end)
-- }}}
--
-- =====================================================================
-- {{{ s_run_or_raise
-- =====================================================================
--- Spawns cmd if no client can be found matching properties
-- If such a client can be found, pop to first tag where it is visible, and give it focus
-- @param cmd the command to execute
-- @param properties a table of properties to match against clients.  Possible entries: any properties of the client object
function run_or_raise(cmd, properties)
    local clients = client.get()
    local focused = awful.client.next(0)
    local findex = 0
    local matched_clients = {}
    local n = 0
    for i, c in pairs(clients) do
        --make an array of matched clients
        if match(properties, c) then
            n = n + 1
            matched_clients[n] = c
            if c == focused then
                findex = n
            end
        end
    end
    if n > 0 then
        local c = matched_clients[1]
        -- if the focused window matched switch focus to next in list
        if 0 < findex and findex < n then
            c = matched_clients[findex+1]
        end
        local ctags = c:tags()
        if table.getn(ctags) == 0 then
            -- ctags is empty, show client on current tag
            local curtag = awful.tag.selected()
            awful.client.movetotag(curtag, c)
        else
            -- Otherwise, pop to first tag client is visible on
            awful.tag.viewonly(ctags[1])
        end
        -- And then focus the client
        client.focus = c
        c:raise()
        return
    end
    awful.util.spawn(cmd)
end

-- Returns true if all pairs in table1 are present in table2
function match (table1, table2)
    for k, v in pairs(table1) do
        if table2[k] ~= v and not table2[k]:find(v) then
        return false
        end
    end
    return true
end
-- =====================================================================
-- {{{ s_autostart
-- =====================================================================
-- kill dropdown terminals
--sexec("for i in $(ps aux | grep 'urxvt_drop' | awk '{print $2}'); do kill $i; done")
sexec("killall -q gmpc")
sexec("pkill -f /usr/bin/zim")
sexec("pkill -f /usr/bin/keepnote")
--exec(home.."/.bin/niceandclean")
-- }}}
