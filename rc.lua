-- =====================================================================
-- {{{ s_libs
-- =====================================================================
require("awful")
require("awful.autofocus")
require("awful.rules")
require("beautiful")
require("naughty")
require("vicious")
require("scratch")
require("vain")
vain.widgets.terminal = "urxvt"
require("misc.revelation")
require("misc.eminent")
-- }}}
-- =====================================================================
-- {{{ s_vars
-- =====================================================================
-- main
winkey		= "Mod4"
altkey		= "Mod1"
k_n		= {}
k_a		= { altkey }
k_as		= { altkey, "Shift" }
k_ac		= { altkey, "Control" }
k_acs		= { altkey, "Control", "Shift" }
k_aw		= { altkey, winkey }
k_aws		= { altkey, winkey, "Shift" }
k_w		= { winkey }
k_ws		= { winkey, "Shift" }
k_wc		= { winkey, "Control" }
k_wcs		= { winkey, "Control", "Shift" }
k_c		= { "Control" }
k_s		= { "Shift" }
k_cs		= { "Control", "Shift" }

-- dirs
home		= os.getenv("HOME")
config		= awful.util.getdir("config")
--hostname	= io.popen("hostname"):read()
local hostname = io.lines("/proc/sys/kernel/hostname")()

-- appearance
barheight = 16
borderwidth = 0

sharedthemes    = "/usr/share/awesome/themes/"
wicons		= config .. "/themes/icons"
themedir	= config .. "/themes"
themelap = themedir.."/redhalo/theme.lua"
themehtpc = themedir.."/smoked/theme.lua"

if hostname == 'laptop' then
    if not awful.util.file_readable(themelap) then
        themedir = sharedthemes
    end
    beautiful.init(themelap)
elseif hostname == 'htpc' then
    if not awful.util.file_readable(themehtpc) then
        themedir = sharedthemes
    end
    beautiful.init(themehtpc)
else
    if not awful.util.file_readable(theme) then
        themedir = sharedthemes
    end
    beautiful.init(theme)
end

-- Notifications
require("misc.notifications")
naughty.config.default_preset.border_width     = 0

-- apps
exec		= awful.util.spawn
sexec		= awful.util.spawn_with_shell
scount		= screen.count()
terminal 	= "urxvt"
editor		= os.getenv("EDITOR") or "vim"
editor_cmd	= terminal .. " -name urxvt_edit -e " .. editor

layouts = {
	awful.layout.suit.tile,             --1
	awful.layout.suit.tile.left,        --2
	awful.layout.suit.tile.bottom,      --3
	awful.layout.suit.tile.top,         --4
	--awful.layout.suit.fair,             --5
	--awful.layout.suit.fair.horizontal,  --6
	awful.layout.suit.spiral,           --7
	awful.layout.suit.spiral.dwindle,   --8
	awful.layout.suit.max,              --9
	awful.layout.suit.max.fullscreen,   --10
	awful.layout.suit.magnifier,        --11
	awful.layout.suit.floating,         --12
}

media = {
	awful.layout.suit.tile,
	awful.layout.suit.max.fullscreen,
}

vainouts = {
	vain.layout.browse,
	vain.layout.termfair,
	vain.layout.gimp,
	vain.layout.uselessfair,
}

gimp = {
	vain.layout.gimp,
	awful.layout.suit.floating,
	awful.layout.suit.tile,
}
-- }}}
-- =====================================================================
-- {{{ s_tags
-- =====================================================================

gold = 0.618
tags = {
    --names  = { "♏",	   "⌥",     "⌘",      "♒",      "☊",        "♓",     "♐",      "✿",	 "♉"  },
    --names = {  "1:code", "2:web", "3:chat", "4:term", "5:media", "6:work", "7:mail", "8:gimp", "9:play" },
    { name = "♏",  layout = layouts[1], mwfact = 0.5 },
    { name = "♐",   layout = layouts[1], mwfact = 0.55 },
    { name = "⌘",  layout = layouts[1], mwfact = 0.6 },
    --{ name = "✿♉♒",  layout = layouts[1], mwfact = 0.4, nmaster = 1, ncol = 2 },
    { name = "☊", layout = media[1], mwfact = 0.65 },
    { name = "♒",  layout = layouts[1], mwfact = gold },
    --{ name = "♒",  layout = layouts[1] },
    { name = "⌥",  layout = gimp[1], mwfact = 0.8 },
    { name = "♓",  layout = layouts[12], hide = true },
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
-- {{{ s_menu
-- =====================================================================
mymainmenu = awful.menu({ items = {
					{ "edit config", editor_cmd .. " " .. awful.util.getdir("config") .. "/rc.lua"},
					{ "restart", awesome.restart },
					{ "open terminal", terminal }
                                  }
                        })

mylauncher = awful.widget.launcher({ image = image(beautiful.awesome_icon),
                                     menu = mymainmenu })
-- }}}

-- =====================================================================
-- {{{ s_widgets
-- =====================================================================
-- Separators
spacer = widget({ type = "textbox" })
seperator = widget({ type = "textbox" })
dash = widget({ type = "textbox" })
comma = widget({ type = "textbox" })
spacer.text = " "
seperator.text = "|"
dash.text = "-"
comma.text = ","

if hostname == 'htpc' then
	--Volume widget
	volicon = widget({ type = "imagebox" })
	volicon.image = image(wicons .. "/him/vol.png")
	volwidget = widget({ type = "textbox" })
	vicious.register(volwidget, vicious.widgets.volume, "$1% $2", 5, "Master")
	volwidget:buttons(awful.util.table.join(
	  awful.button(k_n, 1, function () sexec("amixer -q set Master toggle") end)
	))
	-- CPU widget
	cpuicon = widget({ type = "imagebox" })
	cpuicon.image = image(wicons .. "/him/cpuinfow.png")
	cpuwidget = widget({ type = "textbox" })
	vicious.register(cpuwidget, vicious.widgets.cpu, "$1%", 1)
	-- RAM widget
	memwidget = widget({ type = "textbox" })
	vicious.register(memwidget, vicious.widgets.mem, "$1%", 30)
	-- OS widget
	osicon = widget({ type = "imagebox" })
	osicon.image = image(wicons .. "/him/cpuinfo.png")
	oswidget = widget({ type = "textbox" })
	vicious.register(oswidget, vicious.widgets.os, "$2", 120)
	-- FS widget
	fswidget = widget({ type = "textbox" })
	vicious.register(fswidget, vicious.widgets.fs, '${/ avail_gb}/${/ size_gb}GB', 120)
	disk = require("misc.diskusage")
	-- the first argument is the widget to trigger the diskusage
	-- the second/third is the percentage at which a line gets orange/red
	-- true = show only local filesystems
	disk.addToWidget(fswidget, 75, 90, true)
	-- Netusage widget
	dnicon = widget({ type = "imagebox" })
	upicon = widget({ type = "imagebox" })
	dnicon.image = image(wicons .. "/him/down.png")
	upicon.image = image(wicons .. "/him/up.png")
	netwidget = widget({ type = "textbox" })
	vicious.register(netwidget, vicious.widgets.net, "${eth0 down_kb} / ${eth0 up_kb}", 1)
end

if hostname == 'laptop' then
	-- Battery widget
	require("misc.bat_smapi")
	baticon = widget({ type = "imagebox" })
	baticon.image = image(wicons .. "/him/bat.png")
	batwidget = widget({ type = "textbox" })
	--vicious.register(batwidget, vicious.widgets.bat_smapi, "$1$2% $3 $4", 10, "BAT0")
	vicious.register(batwidget, misc.bat_smapi, "$1$2 $3 $4", 2, "BAT0")
	-- from awesome-34's batteryrc
	batwidget:add_signal('mouse::enter', function ()
			   batinfo = { naughty.notify({ title      = "BAT0"
                                , text       = "blu"
                                --[[, timeout    = 5
                                , position   = "top_right"
                                , fg         = beautiful.fg_focus
                                , bg         = beautiful.bg_focus]]
				})
			   } end )
	batwidget:add_signal('mouse::leave', function () naughty.destroy(batinfo[1]) end)
	--[[ WLAN widget
	wlanwidget = widget({ type = "textbox" })
	vicious.register(wlanwidget, vicious.widgets.wifi, "<span color='#A4A39F'>~</span>${link}%", 10, "wlan0")]]
	--[[require("fan")
	fanwidget = widget({ type = "textbox" })
	vicious.register(fanwidget, fan, "$1rpm", 2)]]
	wlanicon = widget({ type = "imagebox" })
	wlanicon.image = image(wicons .. "/him/wifi.png")
end

--[[ Bat Alt
mybatterybox = widget({ type = "textbox" })
function battery()
	local output = ''
	local batpath = "/sys/devices/platform/smapi/BAT0"

	local file = io.open(batpath .. "/power_now", "r")
	local watt = file:read("*n")
	file:close()

	file = io.open(batpath .. "/remaining_percent", "r")
	local percent = file:read("*n")
	file:close()

	file = io.open(batpath .. "/remaining_running_time", "r")
	local time = file:read()
	file:close()
	if(state == "Discharging") then
		if(percentage < 10) then
			output = '<span color="red">' .. percentage .. '%</span>'
		elseif(percentage < 40) then
			output = '<span color="#FFA500">' .. percentage .. '%</span>'
		else
			output = '<span color="green">' .. percentage .. '%</span>'
		end
	else
		output = '<span color="blue">' .. percentage .. '%</span>'
	end

	output = watt .. " " .. percent .. " " .. time
	return output
end 
mybatterybox.text = battery()
mybatterytimer = timer({ timeout = 30 })
mybatterytimer:add_signal("timeout", function() mybatterybox.text = battery() end)
mybatterytimer:start()]]

-- Awesompd
require("awesompd.awesompd")
musicwidget 			= awesompd:create() -- Create awesompd widget
--musicwidget.font		= "MonteCarlo medium 11" -- Set widget font
musicwidget.font		= "MonteCarlo medium 10" -- Set widget font
musicwidget.symbol		= "♪"
musicwidget.symbolfont		= "MonteCarlo medium 9"
musicwidget.symbolcolor		=  "white" -- purple: "#ce2c51"
musicwidget.scrolling 		= true -- If true, the text in the widget will be scrolled
musicwidget.output_size 	= 30 -- Set the size of widget in symbols
musicwidget.update_interval 	= 10 -- Set the update interval in seconds
musicwidget.path_to_icons 	= config .. "/awesompd/icons" -- Set the folder where icons are located (change username to your login name)
musicwidget.servers = {
     { server = "localhost",
          port = 6600 },
     { server = "192.168.0.2",
          port = 6600 }
  }
musicwidget:register_buttons({ { "", awesompd.MOUSE_LEFT, musicwidget:command_toggle() },
     			       { "Control", awesompd.MOUSE_LEFT, musicwidget:command_prev_track() },
  			       { "Control", awesompd.MOUSE_RIGHT, musicwidget:command_next_track() },
  			       { "", awesompd.MOUSE_SCROLL_UP, musicwidget:command_volume_up() },
  			       { "", awesompd.MOUSE_SCROLL_DOWN, musicwidget:command_volume_down() },
  			       { "", awesompd.MOUSE_RIGHT, musicwidget:command_show_menu() } })
musicwidget:run()
-- Netcfg widget
require("vicious.contrib")
netcfgwidget = widget({ type = "textbox" })
vicious.register(netcfgwidget, vicious.contrib.netcfg, "$1", 10)
-- Thermal widget
tempicon = widget({ type = "imagebox" })
tempicon.image = image(wicons .. "/him/temp.png")
tempwidget = widget({ type = "textbox" })
if hostname == 'laptop' then
    vicious.register(tempwidget, vicious.widgets.thermal, "$1°C", 30, "thermal_zone0")
elseif hostname == 'htpc' then
    vicious.register(tempwidget, vicious.widgets.thermal, "$1°C", 30, { "f71882fg.2560", "core"})
end
-- Textclock widget
mytextclock = awful.widget.textclock({ align = "right" })

-- Systray
--mysystray = widget({ type = "systray" })

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
mytasklist.buttons = awful.util.table.join(
                     awful.button(k_n, 1, function (c)
                                              --if c == client.focus then
                                                  --c.minimized = true
                                              --else
                                                  if not c:isvisible() then
                                                      awful.tag.viewonly(c:tags()[1])
                                                  end
                                                  -- This will also un-minimize
                                                  -- the client, if needed
                                                  client.focus = c
                                                  c:raise()
                                              --end
                                          end),
                     awful.button(k_n, 3, function ()
                                              if instance then
                                                  instance:hide()
                                                  instance = nil
                                              else
                                                  instance = awful.menu.clients({ width=250 })
                                              end
                                          end),
                     awful.button(k_n, 4, function ()
                                              awful.client.focus.byidx(1)
                                              if client.focus then client.focus:raise() end
                                          end),
                     awful.button(k_n, 5, function ()
                                              awful.client.focus.byidx(-1)
                                              if client.focus then client.focus:raise() end
                                          end))

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
                           awful.button(k_n, 5, function () awful.layout.inc(layouts, -1) end)))
    -- Create a taglist widget
    mytaglist[s] = awful.widget.taglist(s, awful.widget.taglist.label.all, mytaglist.buttons)

    -- Create a tasklist widget
    mytasklist[s] = awful.widget.tasklist(function(c)
                                              return awful.widget.tasklist.label.currenttags(c, s)
                                          end, mytasklist.buttons)

    -- Create the wibox
    mywibox[s] = awful.wibox({ position = "top", screen = s, border_width = borderwidth, height = barheight  })
    -- Add widgets to the wibox - order matters

  if hostname == 'laptop' then
    mywibox[s].widgets = {
        {
            mylauncher,-- spacer,
	    mytaglist[s],
	    spacer, musicwidget.widget, spacer,
	    mypromptbox[s],
            layout = awful.widget.layout.horizontal.leftright
        },
	mylayoutbox[s],
	s == 1 and mysystray or nil, spacer,
	--mytextclock, seperator, spacer,
	--fanwidget, spacer,
	--wlanwidget, spacer,
	tempwidget, spacer,
	--mybatterybox, baticon, spacer,
        batwidget, baticon, spacer,
	netcfgwidget, spacer, wlanicon, spacer,
	mytasklist[s],
        layout = awful.widget.layout.horizontal.rightleft
    }
  else
    mywibox[s].widgets = {
        {
            mylauncher, spacer,
	    mytaglist[s],
	    spacer, musicwidget.widget, spacer,
	    mypromptbox[s],
            layout = awful.widget.layout.horizontal.leftright
        },
	mylayoutbox[s],
	s == 1 and mysystray or nil, spacer,
	mytextclock, seperator, spacer,
	volwidget, spacer, volicon, spacer, seperator, spacer,
        fswidget, spacer,
	oswidget, spacer, osicon, spacer,
	tempwidget, spacer,
	memwidget, spacer,
	cpuwidget, spacer, cpuicon, spacer, seperator,
	upicon, netwidget, dnicon, seperator, spacer,
	netcfgwidget, spacer, wlanicon, spacer,
	mytasklist[s],
        layout = awful.widget.layout.horizontal.rightleft
    }
  end
end
-- }}}

-- =====================================================================
-- {{{ s_bindings_mouse
-- =====================================================================

root.buttons(awful.util.table.join(
    awful.button(k_n, 3, function () mymainmenu:toggle() end),
    awful.button(k_n, 4, awful.tag.viewnext),
    awful.button(k_n, 5, awful.tag.viewprev)
))
-- }}}

-- =====================================================================
-- {{{ s_bindings_keyboard
-- =====================================================================
globalkeys = awful.util.table.join(
    -- run_or_raise
    --awful.key(k_a,  "g",     function () run_or_raise("gmpc", { class = "Gmpc" }) end),
    awful.key(k_a,  "f",     function () run_or_raise("firefox", { class = "Firefox" }) end),
    awful.key(k_ac, "g",     function () run_or_raise("gimp", { class = "Gimp" }) end),
    awful.key(k_a,  "z",     function () run_or_raise("xchat", { class = "Xchat" }) end),
    awful.key(k_a,  "t",     function () run_or_raise("thunderbird", { class = "Thunderbird" }) end),
    awful.key(k_ac, "z",     function () run_or_raise("zim", { class = "Zim" }) end),
    awful.key(k_w,  "m",     function () run_or_raise("sonata", { class = "Sonata" }) end),
    --awful.key(k_wc, "m",   function () run_or_raise("pragha", { class = "Pragha" }) end),
    -----
    awful.key(k_w,  "space", function () awful.layout.set(awful.layout.suit.floating)     end),
    -- Frequently used
    --awful.key(k_a,  "d",   function () scratch.pad.toggle() end),
    awful.key(k_a,  "s",      function () scratch.drop("urxvt -name urxvt_drop -e tmux", "bottom", "center", 1, 0.35 ) end),
    awful.key(k_a,  "a",      function () scratch.drop("urxvt -name urxvt_drop_l -e tmux", "bottom", "left", 0.4999, 0.37 ) end),
    awful.key(k_a,  "d",      function () scratch.drop("urxvt -name urxvt_drop_r -e tmux", "bottom", "right", 0.4999, 0.37 ) end),
    awful.key(k_ac, "s",      function () scratch.drop("urxvt -name urxvt_drop_c -e ncmpcpp", "center", "center", 0.7, 0.8 ) end),
    awful.key(k_a,  "g",      function () scratch.drop("gmpc", "center", "center", 0.7, 0.8 ) end),
    awful.key(k_a,  "^",      function () scratch.drop("urxvt -name urxvt_drop_t -e tmux", "top", "center", 1, 0.4 ) end),
    -- Mpd
    awful.key(k_ws, "Down",  musicwidget:command_toggle()),
    awful.key(k_ws, "Up",    musicwidget:command_volume_up()),
    awful.key(k_ws, "Down",  musicwidget:command_volume_down()),
    awful.key(k_ws, "Left",  musicwidget:command_prev_track()),
    awful.key(k_ws, "Right", musicwidget:command_next_track()),
    -- Notifications
    awful.key(k_n, "XF86AudioLowerVolume", volume_down),
    awful.key(k_n, "XF86AudioRaiseVolume", volume_up),
    awful.key({ }, "XF86MonBrightnessUp", brightness_up),
    awful.key({ }, "XF86MonBrightnessDown", brightness_down),
    -- Vim
    awful.key(k_w,  "b",     function () exec(editor_cmd .. " " .. home .. "/.zshrc") end),
    awful.key(k_w,  "n",     function () exec(editor_cmd .. " " .. home .. "/.note") end),
    awful.key(k_wc, "n",     function () exec(editor_cmd .. " " .. home .. "/.notemed") end),
    awful.key(k_w,  "o",     function () exec(editor_cmd .. " " .. config .. "/rc.lua") end),
    -- Layout and window control
    awful.key(k_a,  "q",     function () awful.layout.set(awful.layout.suit.tile)     end),
    awful.key(k_ac, "q",     function () awful.layout.set(awful.layout.suit.tile.bottom)     end),
    awful.key(k_a,  "w",     function () awful.layout.set(awful.layout.suit.fair)     end),
    awful.key(k_ac, "w",     function () awful.layout.set(awful.layout.suit.fair.horizontal)     end),
    awful.key(k_ac, "m",     function () awful.layout.set(awful.layout.suit.max)     end),
    awful.key(k_a,  "m",     function () awful.layout.set(awful.layout.suit.max.fullscreen)     end),
    awful.key(k_as, "m",     function () awful.layout.set(awful.layout.suit.magnifier)     end),
    awful.key(k_ac, "r",     function () awful.layout.set(awful.layout.suit.spiral)     end),
    awful.key(k_as, "r",     function () awful.layout.set(awful.layout.suit.spiral.dwindle)     end),
    --awful.key(k_ac, "d",     function () awful.layout.set(vain.layout.browse)     end),
    --awful.key(k_ac, "a",     function () awful.layout.set(vain.layout.uselessfair)     end),
    awful.key(k_a,  "e",     revelation.revelation),
    awful.key(k_as, "l",     function () awful.tag.incmwfact( 0.05)    end),
    awful.key(k_as, "h",     function () awful.tag.incmwfact(-0.05)    end),
    awful.key(k_a,  "h",     function () awful.tag.incnmaster( 1)      end),
    awful.key(k_a,  "l",     function () awful.tag.incnmaster(-1)      end),
    awful.key(k_ac, "h",     function () awful.tag.incncol( 1)         end),
    awful.key(k_ac, "l",     function () awful.tag.incncol(-1)         end),
    awful.key(k_w,  "0",     function () awful.tag.setncol(1)	       end),
    awful.key(k_a,  "0",     function () awful.tag.setnmaster(1)       end),
    awful.key(k_a,  "space",
	function ()
		local curtag = awful.tag.selected()
		if curtag == tags[1][8] then
			awful.layout.inc(gimp,  1)
		else
			awful.layout.inc(layouts,  1)
		end
	end),
    awful.key(k_as,  "space",
	function ()
		local curtag = awful.tag.selected()
		if curtag == tags[1][8] then
			awful.layout.inc(gimp,  -1)
		else
			awful.layout.inc(layouts,  -1)
		end
	end),

    awful.key(k_a,  "y",
	function()
		local tags = awful.tag.selectedlist(mouse.screen)
		if #tags == 0 then
			awful.tag.viewmore(last_tags)
		else
			last_tags = tags awful.tag.viewnone()
		end
	end),

    -- Naughty
   awful.key(k_a,  "F1",     closeLastNaughtyMsg),

    -- Layout manipulation
    awful.key(k_a,  "j",
        function ()
            awful.client.focus.byidx( 1)
            if client.focus then client.focus:raise() end
        end),
    awful.key(k_a,  "k",
        function ()
            awful.client.focus.byidx(-1)
            if client.focus then client.focus:raise() end
        end),
    awful.key(k_ac, "j",     function () awful.client.swap.byidx(  1)    end),
    awful.key(k_ac, "k",     function () awful.client.swap.byidx( -1)    end),
    --awful.key(k_as, "j",   function () awful.screen.focus_relative( 1) end),
    --awful.key(k_as, "k",   function () awful.screen.focus_relative(-1) end),
    awful.key(k_as, "j",     function () awful.client.incwfact(-0.05) end),
    awful.key(k_as, "k",     function () awful.client.incwfact( 0.05) end),
    awful.key(k_a,  "u",     awful.client.urgent.jumpto),
    awful.key(k_ac, "Tab",
        function ()
            awful.client.focus.history.previous()
            if client.focus then
                client.focus:raise()
            end
        end),
    awful.key(k_a,  "n",      awful.tag.viewnext),
    awful.key(k_a,  "p",      awful.tag.viewprev),
    awful.key(k_a,  "Escape", awful.tag.history.restore),
    awful.key(k_a,  "Tab",    awful.tag.history.restore),
    awful.key(k_w,  "Tab",    awful.tag.history.restore),
    -- awesome wm actions
    awful.key(k_a,  "F11",    awesome.restart),
    awful.key(k_a,  "F12",    awesome.quit),
    awful.key(k_ac, "Return", function () mymainmenu:show({keygrabber=true}) end),
    -- prompt
    awful.key(k_as, "z",      function () mypromptbox[mouse.screen]:run() end),
    awful.key(k_ac, "x",
              function ()
                  awful.prompt.run({ prompt = "Run Lua code: " },
                  mypromptbox[mouse.screen].widget,
                  awful.util.eval, nil,
                  awful.util.getdir("cache") .. "/history_eval")
              end)
)

clientkeys = awful.util.table.join(
   -- Toggle titlebar
    awful.key(k_a,  "<",
       function (c)
        if c.titlebar then
            awful.titlebar.remove(c)
            debug_notify(c.name .. "\ntitlebar " .. colored_off)
        else
            awful.titlebar.add(c, { altkey = "Mod1" })
            debug_notify(c.name .. "\ntitlebar " .. colored_on)
        end
    end),
    --awful.key(k_a,  "a",     function (c) scratch.pad.set(c, 0.60, 0.60, true) end),
    awful.key(k_a,  "x",     function (c) c.fullscreen = not c.fullscreen  end),
    awful.key(k_a,  "c",     function (c) c:kill()                         end),
    awful.key(k_a,  "i",     awful.client.floating.toggle                     ),
    awful.key(k_ac, "f",     awful.client.floating.toggle                     ),
    awful.key(k_a,  "r",     function (c) c:swap(awful.client.getmaster()) end),
    awful.key(k_as, "r",     function (c) c:redraw()                       end),
    awful.key(k_a,  "b",     function (c) c.ontop = not c.ontop            end),
    awful.key(k_ac, "b",     function ()  mywibox[mouse.screen].visible = not mywibox[mouse.screen].visible end),
    awful.key(k_a,  "v",     function (c) c.minimized = not c.minimized    end),
    -- All minimized clients are restored
    awful.key(k_ac, "v",
        function()
            local tag = awful.tag.selected()
                for i=1, #tag:clients() do
                    tag:clients()[i].minimized=false
                    tag:clients()[i]:redraw()
            end
        end),
   -- Move window to next/previous tag
    awful.key(k_ac, "p",
    function (c)
        local curidx = awful.tag.getidx(c:tags()[1])
        if curidx == 1 then
            c:tags({screen[mouse.screen]:tags()[7]})
        else
            c:tags({screen[mouse.screen]:tags()[curidx - 1]})
        end
    end),
    awful.key(k_ac, "n",
      function (c)
        local curidx = awful.tag.getidx(c:tags()[1])
        if curidx == 7 then
            c:tags({screen[mouse.screen]:tags()[1]})
        else
            c:tags({screen[mouse.screen]:tags()[curidx + 1]})
        end
      end)
)


-- Compute the maximum number of digit we need, limited to 9
keynumber = 0
for s = 1, screen.count() do
   keynumber = math.min(9, math.max(#tags[s], keynumber));
end

-- Bind all key numbers to F keys.
-- Keep a (semi-)persistant mapping of active multitags
-- This should map on the top row of your keyboard, usually F1 to F9.
extra_tags = {}
for i = 1, keynumber do
    extra_tags[i] = {}
    globalkeys = awful.util.table.join(globalkeys,
        awful.key(k_a, "F" .. i,
                  function ()
		     local screen = mouse.screen
		     local curtag = tags[screen][i]
		     if curtag then
			awful.tag.viewonly(curtag)
		     end
		     for tag,v in pairs(extra_tags[i]) do
			if v then
			   awful.tag.viewtoggle(tags[screen][tag])
			end
		     end
                  end),
        awful.key(k_w, "F" .. i,
                  function ()
		     local screen = mouse.screen
		     local curtag = awful.tag.getidx(awful.tag.selected(screen))
		     local selected = awful.tag.selectedlist(screen)
		     local found = false
		     for i_,v in ipairs(selected) do
			v = awful.tag.getidx(v)
			if v == i then
			   found = true
			   break
			end
		     end
		     if found then
			extra_tags[curtag][i] = false
		     else
			extra_tags[curtag][i] = true
		     end
		     if tags[screen][i] then
			awful.tag.viewtoggle(tags[screen][i])
		     end
                  end),
        awful.key(k_aw, "F" .. i,
                  function ()
                      if client.focus and tags[client.focus.screen][i] then
                          awful.client.movetotag(tags[client.focus.screen][i])
                      end
                  end),
        awful.key(k_aws, "F" .. i,
                  function ()
                      if client.focus and tags[client.focus.screen][i] then
                          awful.client.toggletag(tags[client.focus.screen][i])
                      end
                  end))
end

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it works on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, keynumber do
    globalkeys = awful.util.table.join(globalkeys,
        awful.key(k_a, "#" .. i + 9,
                  function ()
                        local screen = mouse.screen
                        if tags[screen][i] then
                            awful.tag.viewonly(tags[screen][i])
                        end
                  end),
        awful.key(k_w, "#" .. i + 9,
                  function ()
                      local screen = mouse.screen
                      if tags[screen][i] then
                          awful.tag.viewtoggle(tags[screen][i])
                      end
                  end),
        awful.key(k_ac, "#" .. i + 9,
                  function ()
                      if client.focus and tags[client.focus.screen][i] then
                          awful.client.movetotag(tags[client.focus.screen][i])
                      end
                  end))
        --[[awful.key(k_as, "#" .. i + 9,
                  function ()
                      if client.focus and tags[client.focus.screen][i] then
                          awful.client.toggletag(tags[client.focus.screen][i])
                      end
                  end))]]
end

clientbuttons = awful.util.table.join(
    awful.button(k_n, 1, function (c) client.focus = c; c:raise() end),
    awful.button(k_w, 1, function (c) client.focus = c; c:lower() end),
    awful.button(k_a, 1, awful.mouse.client.move),
    awful.button(k_a, 3, awful.mouse.client.resize))

-- set keys
root.keys(globalkeys)
-- }}}

-- =====================================================================
-- {{{ s_rules
-- =====================================================================
awful.rules.rules = {
    -- All clients will match this rule.
    { rule = k_n,
      properties = { border_width = beautiful.border_width,
                     border_color = beautiful.border_normal,
                     focus = true,
                     keys = clientkeys,
		     maximized_vertical   = false,
		     maximized_horizontal = false,
		     size_hints_honor = false,
                     buttons = clientbuttons } },
    -- 1:code
    { rule = { class = "Gedit" },
      properties = { tag = tags[1][1], switchtotag = true }
    },
    { rule = { class = "Gvim" },
      properties = { tag = tags[1][1], switchtotag = true }
    },
    { rule = { class = ".*[Mm]edit.*", name = ".*[Mm]edit.*", instance = ".*[Mm]edit.*" },
      except = { name = "Find" },
      properties = { tag = tags[1][1], switchtotag = true }
    },
   { rule = { class = "medit" },
      except = { name = "Find" },
      properties = { tag = tags[1][1], switchtotag = true }
    },
    { rule = { instance = "medit" },
      except = { name = "Find" },
      properties = { tag = tags[1][1], switchtotag = true }
    },
    { rule = { instance = "medit.*" },
      except = { name = "Find" },
      properties = { tag = tags[1][1], switchtotag = true }
    },
    { rule = { name = "^medit\ %-.*" },
      except = { name = "Find" },
      properties = { tag = tags[1][1], switchtotag = true }
    },
    { rule = { name = "medit.*" },
      except = { name = "Find" },
      properties = { tag = tags[1][1], switchtotag = true }
    },
    { rule = { instance = "urxvt_edit" },
      properties = { tag = tags[1][1], switchtotag = true }
    },

    -- 2:web
    { rule = { class = "Firefox" },
      except = { instance = "Navigator" },
      properties = { tag = tags[1][2], floating = true },
      callback = awful.placement.centered
    },
    { rule = { class = "Firefox", instance = "Navigator" },
      properties = { tag = tags[1][2], switchtotag = true }
    },
    { rule = { class = "Firefox", instance = "Dialog" },
      properties = { tag = tags[1][2], switchtotag = true }
    },

    -- 3:chat
    { rule = { class = "Skype", instance = 'skype' },
      properties = { tag = tags[1][3], switchtotag = true }
    },
    { rule = { class = "Skype", instance = 'skype', name = 'Chat' },
      properties = { tag = tags[1][3], floating = true }
    },
    { rule = { class = "Xchat" },
      properties = { tag = tags[1][3] }
    },

    -- 4:term
    --[[{ rule = { class = "URxvt" }, except_any = { instance = { "urxvt_drop", "urxvt_edit" } },
      properties = { tag = tags[1][4] }
    },
    { rule = { instance = "urxvt_term" },
      properties = { tag = tags[1][4] }
    },]]

    -- 4:media
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
      properties = { tag = tags[1][4], switchtotag = true }
    },

    -- 5:work
    { rule = { class = "LibreOffice" },
      properties = { tag = tags[1][5], switchtotag = true }
    },
    { rule = { class = "libreoffice.*" },
      properties = { tag = tags[1][5], switchtotag = true }
    },
    { rule = { class = "AbiWord" },
      properties = { tag = tags[1][5], switchtotag = true }
    },

    --[[ 7:mail
    { rule = { class = "Thunderbird" },
      properties = { tag = tags[1][7], switchtotag = true }
    },]]

    -- 6:gimp
    --[[{ rule = { class = "Eterm" },
      properties = { geometry = { width = 300, height = 300, y = 400, x = 500 }, below = true, floating = true },
      callback = awful.placement.centered
    },]]
    { rule = { class = "Gimp" },
      properties = { tag = tags[1][6], switchtotag = true }
    },

    -- 7:play
    { rule = { class = "VirtualBox" },
      properties = { tag = tags[1][7], floating = true },
      callback = awful.placement.centered
    },

    -- All
    --[[{ rule = { class = "Apvlv"},
      properties = { maximized_horizontal = true, maximized_vertical = true },
      callback = awful.placement.centered
    },]]
    { rule_any = { class = { "Sonata", "Zenity", "Orage" } },
      properties = { floating = true }
    },
    { rule = { class = "Xephyr" },
      properties = { above = true },
    },
    { rule = { class = "Zenity" },
      properties = { floating = true, sticky = true, ontop = true, above = true, geometry = { width = 500, height = 500, y=450, x=720 }},
      callback = awful.placement.centered
    }
}

awful.rules.rules = awful.util.table.join(
    awful.rules.rules,
    vain.layout.gimp.rules
)
-- }}}

-- =====================================================================
-- {{{ s_signals
-- =====================================================================
-- Signal function to execute when a new client appears.
client.add_signal("manage", function (c, startup)
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
client.add_signal("focus",   function (c) c.border_color = beautiful.border_focus
                               c.border_color = beautiful.border_focus
                               --c.opacity = 1
                             end)

client.add_signal("unfocus", function(c)
                               c.border_color = beautiful.border_normal
                               --c.opacity = 0.9
                             end)
-- Tag signal handler - selection
-- - ASCII tags 1 [2] 3 4...
--   - start with tag 1 named [1] in tag setup
--[[for s = 1, screen.count() do
    for t = 1, #tags[s] do
        tags[s][t]:add_signal("property::selected", function ()
           if tags[s][t].selected then
                tags[s][t].name = "[" .. tags[s][t].name .. "]"
           else]]
--                tags[s][t].name = tags[s][t].name:gsub("[%[%]]", "")
--           end
--        end)
--    end
--end
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

-- close naughty
function closeLastNaughtyMsg()
    screen = 1
    -- destroy first notification, that is found
    for p,pos in pairs(naughty.notifications[screen]) do
        for i,n in pairs(naughty.notifications[screen][p]) do
            naughty.destroy(n)
            break
        end
    end
end
-- =====================================================================
-- {{{ s_autostart
-- =====================================================================
-- kill dropdown terminals
sexec("for i in $(ps aux | grep 'urxvt_drop_' | awk '{print $2}'); do kill $i; done")
sexec("killall -q gmpc")
--exec(home .. "/.bin/niceandclean")
-- }}}
