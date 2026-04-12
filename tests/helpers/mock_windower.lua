-- Mock implementations for Windower and GearSwap globals that runhud.lua depends on.
-- Load this before requiring runhud in any test file.

-- Windower L{} list type: a numerically-indexed table with :append() and :concat()
local MockList = {}
MockList.__index = {
    append = function(self, v)
        table.insert(self, v)
    end,
    concat = function(self, sep)
        return table.concat(self, sep or "")
    end,
}
-- L{} syntax means L is callable with a table arg: L({}) or L{}
L = setmetatable({}, {
    __call = function(_, init)
        local list = init or {}
        return setmetatable(list, MockList)
    end,
})

-- Windower texts library stub: texts.new(settings) returns a text object
texts = {
    new = function(settings)
        return {
            _visible  = false,
            _text     = "",
            _info     = nil,
            clear     = function(self) self._text = "" end,
            append    = function(self, s) self._text = self._text .. s end,
            show      = function(self) self._visible = true end,
            hide      = function(self) self._visible = false end,
            update    = function(self, info) self._info = info end,
        }
    end,
}

-- coroutine.sleep stub: do nothing (avoids blocking in tests)
coroutine.sleep = function(_) end

-- Default player stub
player = { job = "RUN" }

-- Default HUD config globals
display_hud   = true
hud_x_pos     = 100
hud_y_pos     = 200
hud_font_size = 13
hud_draggable = false
hud_transparency = 220
