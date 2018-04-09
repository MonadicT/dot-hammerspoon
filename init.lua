--
---------------------------------------
-- Hotkeys to launch and focus to apps
-- Hotkey to toggle fullscreen mode
-- Hotkey to toggle Hammerspoon console
---------------------------------------
--

local log = hs.logger.new('mymodule','debug')
local hyper = {"ctrl", "alt", "cmd"}
local spaces = require("hs._asm.undocumented.spaces")

-- Toggle fullscreen mode of current window
function toggleFullscreen()
   local win = hs.window.focusedWindow()
   if win ~= nil then
      win:setFullScreen(not win:isFullScreen())
   end
end

-- Return app launching function
function launchApp(app)
   return function()
      hs.application.launchOrFocus(app)
   end
end

-- returns url opener
function gotoUrl(url)
   return function()
      log.i("HERE")
      print (hs.urlevent.openURL(url))
   end
end

-- Return space switching function
function switchToSpace(sp)
   return function()
      local sps = spaces.query()
      spaces.changeToSpace(sps[sp])
      end
end

-- Start tmux
function startTmux()
   local tmux = findWindowAnySpace("tmux")
   log.i("tmux", tmux)
   if tmux[1]
   then
      tmux[1]:focus()
   else
      hs.applescript([[
	tell application "Terminal"
	     activate
	     	do script "/usr/local/bin/tmux new-session \\; split-window -h \\; split-window -v \\;"
                -- set {screen_left, screen_top, screen_width, screen_height} to bounds of window of desktop
	end tell
    ]]
		    )
   end
end

-- Hotkeys to bind to functions
hs.fnutils.each(
   {
      { key = "1", func = switchToSpace(1) },
      { key = "2", func = switchToSpace(2) },
      { key = "3", func = switchToSpace(3) },
      { key = "4", func = switchToSpace(4) },
      { key = "5", func = switchToSpace(5) },
      { key = "6", func = switchToSpace(6) },
      { key = "7", func = switchToSpace(7) },
      { key = "8", func = switchToSpace(8) },
      { key = "9", func = switchToSpace(9) },
      { key = "b", func = launchApp("Google Chrome") },
      { key = "e", func = launchApp("emacs") },
      { key = "f", func = toggleFullscreen },
      { key = "g", func = gotoUrl("https://github.com") },
      { key = "h", func = gotoUrl("https://news.ycombinator.com") },
      { key = "l", func = launchApp("Launchpad") },	
      { key = "r", func = hs.reload },
      { key = "t", func = startTmux },
      { key = "z", func = hs.toggleConsole },
      
   },
   function(obj)
      hs.hotkey.bind(hyper, obj.key, obj.func)
   end)


function findWindowAnySpace(title)
   local spaceIds = spaces.query()
   return hs.fnutils.mapCat(
      spaces.query(),
      function(id)
	 return hs.fnutils.filter(
	    spaces.allWindowsForSpace(id),
	    function(w)
	       return string.find(w:title(), title)
	    end)
      end)
end

hs.notify.show("Hammerspoon", "Loaded!", "")
