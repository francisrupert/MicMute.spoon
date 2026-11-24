--- === MicMute ===
---
--- Custom MicMute for Shure MV7.
--- Tracks mute state manually since the MV7 doesn't report it correctly.
--- Supports latch/momentary hotkey behavior: quick press toggles, long press
--- is momentary (unmutes on release). Also syncs mute state with Zoom and
--- Microsoft Teams via their menu items.

local obj = {}
obj.__index = obj

obj.name = "MicMute"
obj.version = "2.0"
obj.author = "Francis Rupert"
obj.license = "MIT"

--- MicMute.muted
--- Variable
--- Current mute state (boolean). Tracked manually since the MV7 doesn't report it.
obj.muted = false

--- MicMute.menu
--- Variable
--- hs.menubar instance showing mic on/off status.
obj.menu = nil

--- MicMute.hotkey
--- Variable
--- hs.hotkey instance bound via :bindHotkeys().
obj.hotkey = nil

--- MicMute.timeSinceMute
--- Variable
--- Epoch timestamp of the last mute toggle, used to distinguish latch vs momentary press.
obj.timeSinceMute = 0

-- Returns the first running app matching any of the given bundle IDs, or nil.
local function runningByBundleID(bundleIDs)
    for _, id in ipairs(bundleIDs) do
        local apps = hs.application.applicationsForBundleID(id)
        if apps and apps[1] then return apps[1] end
    end
    return nil
end

--- MicMute:updateMenu()
--- Method
--- Updates the menubar title to reflect the current mute state.
function obj:updateMenu()
    local red = { red = 255/255, green = 96/255, blue = 93/255 }
    local green = { red = 0/255, green = 255/255, blue = 24/255 }
    local black = { red = 0, green = 0, blue = 0 }
    local pad = " "
    if self.muted then
        local style = { font = { name = ".AppleSystemUIFontBold" }, backgroundColor = red, color = black, kerning = 0 }
        self.menu:setTitle(hs.styledtext.new(pad .. "Muted" .. pad, style))
    else
        local style = { font = { name = ".AppleSystemUIFontBold" }, backgroundColor = green, color = black, kerning = 0 }
        self.menu:setTitle(hs.styledtext.new(pad .. "ON" .. pad, style))
    end
end

--- MicMute:toggle()
--- Method
--- Toggles the mic mute state on the default input device and syncs with
--- Zoom and Microsoft Teams if they are running.
function obj:toggle()
    local mic = hs.audiodevice.defaultInputDevice()
    if mic then
        self.muted = not self.muted
        mic:setInputMuted(self.muted)
        self:updateMenu()

        -- Exact bundle-ID lookups. hs.application.get("Zoom") / find("com.microsoft.teams")
        -- do a name search that blocked the main thread ~4.5s each.
        local zoom = runningByBundleID({ "us.zoom.xos" })
        local teams = runningByBundleID({ "com.microsoft.teams2", "com.microsoft.teams" })

        if self.muted then
            if zoom then zoom:selectMenuItem("Mute Audio") end
            if teams then teams:selectMenuItem("Mute") end
        else
            if zoom then zoom:selectMenuItem("Unmute Audio") end
            if teams then teams:selectMenuItem("Unmute") end
        end
    end
end

--- MicMute:bindHotkeys(mapping, latchTimeout)
--- Method
--- Bind hotkey with latch/momentary behavior.
--- Quick press (< latchTimeout): toggle. Long press: momentary (toggles back on release).
---
--- Parameters:
---  * mapping - A table with a "toggle" key containing {mods, key}, e.g. `{toggle = {{}, "f19"}}`.
---  * latchTimeout - (optional) Seconds to distinguish latch from momentary. Default 0.75.
---
--- Returns:
---  * self
function obj:bindHotkeys(mapping, latchTimeout)
    if self.hotkey then self.hotkey:delete() end
    local mods = mapping["toggle"][1]
    local key = mapping["toggle"][2]
    latchTimeout = latchTimeout or 0.75

    self.hotkey = hs.hotkey.bind(mods, key, function()
        self:toggle()
        self.timeSinceMute = hs.timer.secondsSinceEpoch()
    end, function()
        if hs.timer.secondsSinceEpoch() > self.timeSinceMute + latchTimeout then
            self:toggle()
        end
    end)
    return self
end

--- MicMute:start()
--- Method
--- Creates the menubar item and sends a load notification.
---
--- Returns:
---  * self
function obj:start()
    self.menu = hs.menubar.new()
    self.menu:setClickCallback(function() self:toggle() end)
    self:updateMenu()

    hs.notify.new({
        title = "Hammerspoon",
        informativeText = "MicMute loaded"
    }):send()

    return self
end

--- MicMute:stop()
--- Method
--- Removes the menubar item and deletes the hotkey binding.
---
--- Returns:
---  * self
function obj:stop()
    if self.menu then
        self.menu:removeFromMenuBar()
        self.menu:delete()
        self.menu = nil
    end
    if self.hotkey then
        self.hotkey:delete()
        self.hotkey = nil
    end
    return self
end

return obj
