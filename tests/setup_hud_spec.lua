-- Tests for setup_hud()
--
-- setup_hud() reads HUD configuration globals, constructs the RUN_info settings
-- table, calls texts.new() to create the Windower text object, initializes it,
-- and calls updatedisplay() to perform the first render.
--
-- Windower's `texts` library and all HUD config globals are stubbed so this
-- can run without a live game client.

local helpers_dir = debug.getinfo(1, "S").source:match("@?(.*/)")
package.path = helpers_dir .. "helpers/?.lua;" ..
               helpers_dir .. "../?.lua;" ..
               package.path

require("mock_windower")
require("runhud")

-- ── helpers ──────────────────────────────────────────────────────────────────

-- Captured args to texts.new()
local last_settings_passed

local function make_window_stub()
    return {
        shown    = false,
        updated  = false,
        cleared  = false,
        appended = nil,
        clear    = function(self) self.cleared = true end,
        append   = function(self, s) self.appended = s end,
        show     = function(self) self.shown = true end,
        update   = function(self, _) self.updated = true end,
    }
end

local function reset_config(overrides)
    overrides = overrides or {}
    hud_x_pos        = overrides.x    or 100
    hud_y_pos        = overrides.y    or 200
    hud_font_size    = overrides.font or 13
    hud_draggable    = (overrides.draggable == nil) and false or overrides.draggable
    hud_transparency = overrides.alpha or 220
    display_hud      = (overrides.display_hud == nil) and true or overrides.display_hud
    update_delay     = 0
    player           = { job = "RUN" }

    last_settings_passed = nil
    local stub = make_window_stub()
    texts = {
        new = function(settings)
            last_settings_passed = settings
            return stub
        end,
    }
    return stub
end

-- ── Tests ─────────────────────────────────────────────────────────────────────

describe("setup_hud", function()

    -- ── RUN_info construction ─────────────────────────────────────────────────

    it("populates RUN_info after call", function()
        reset_config()
        setup_hud()
        assert.is_not_nil(RUN_info)
    end)

    it("sets RUN_info.box.pos.x from hud_x_pos", function()
        reset_config({ x = 350 })
        setup_hud()
        assert.are.equal(350, RUN_info.box.pos.x)
    end)

    it("sets RUN_info.box.pos.y from hud_y_pos", function()
        reset_config({ y = 450 })
        setup_hud()
        assert.are.equal(450, RUN_info.box.pos.y)
    end)

    it("sets RUN_info.box.text.size from hud_font_size", function()
        reset_config({ font = 18 })
        setup_hud()
        assert.are.equal(18, RUN_info.box.text.size)
    end)

    it("sets RUN_info.box.flags.draggable from hud_draggable (false)", function()
        reset_config({ draggable = false })
        setup_hud()
        assert.is_false(RUN_info.box.flags.draggable)
    end)

    it("sets RUN_info.box.flags.draggable from hud_draggable (true)", function()
        reset_config({ draggable = true })
        setup_hud()
        assert.is_true(RUN_info.box.flags.draggable)
    end)

    it("sets RUN_info.box.bg.alpha from hud_transparency", function()
        reset_config({ alpha = 128 })
        setup_hud()
        assert.are.equal(128, RUN_info.box.bg.alpha)
    end)

    it("uses a green-tinted background (red=0, green=15, blue=0)", function()
        reset_config()
        setup_hud()
        local bg = RUN_info.box.bg
        assert.are.equal(0,  bg.red)
        assert.are.equal(15, bg.green)
        assert.are.equal(0,  bg.blue)
    end)

    it("uses Impact font", function()
        reset_config()
        setup_hud()
        assert.are.equal("Impact", RUN_info.box.text.font)
    end)

    -- ── texts.new() interaction ───────────────────────────────────────────────

    it("passes settings to texts.new()", function()
        reset_config()
        setup_hud()
        assert.is_not_nil(last_settings_passed)
    end)

    it("passes the correct pos to texts.new()", function()
        reset_config({ x = 50, y = 75 })
        setup_hud()
        assert.are.equal(50, last_settings_passed.pos.x)
        assert.are.equal(75, last_settings_passed.pos.y)
    end)

    -- ── Post-call state ───────────────────────────────────────────────────────

    it("calls window:show() after setup", function()
        local stub = reset_config()
        setup_hud()
        assert.is_true(stub.shown)
    end)

    it("calls window:update() during initial updatedisplay()", function()
        local stub = reset_config()
        setup_hud()
        assert.is_true(stub.updated)
    end)

    it("calls initialize() so window:clear() is invoked", function()
        local stub = reset_config()
        setup_hud()
        assert.is_true(stub.cleared)
    end)

    it("calls initialize() so window:append() is invoked", function()
        local stub = reset_config()
        setup_hud()
        assert.is_not_nil(stub.appended)
    end)
end)
