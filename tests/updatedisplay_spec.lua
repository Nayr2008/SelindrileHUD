-- Tests for updatedisplay()
--
-- updatedisplay() reads the global `player` table, builds a keybinding info
-- table, pushes it to `window`, and conditionally shows the window depending
-- on the `display_hud` flag.  All globals are replaced with stubs so tests
-- run without a live Windower process.

local helpers_dir = debug.getinfo(1, "S").source:match("@?(.*/)")
package.path = helpers_dir .. "helpers/?.lua;" ..
               helpers_dir .. "../?.lua;" ..
               package.path

require("mock_windower")
require("runhud")

-- ── helpers ──────────────────────────────────────────────────────────────────

local function make_window_spy()
    return {
        shown    = false,
        updated  = false,
        last_info = nil,
        show   = function(self) self.shown = true end,
        hide   = function(self) self.shown = false end,
        update = function(self, info)
            self.updated  = true
            self.last_info = info
        end,
    }
end

-- Reset all relevant globals before every test
local spy
local function reset(opts)
    opts = opts or {}
    spy          = make_window_spy()
    window       = spy
    player       = { job = opts.job or "RUN" }
    display_hud  = (opts.display_hud == nil) and true or opts.display_hud
    update_delay = opts.update_delay or 0
end

-- ── Tests ─────────────────────────────────────────────────────────────────────

describe("updatedisplay", function()

    -- ── window:update() contract ─────────────────────────────────────────────

    it("always calls window:update()", function()
        reset()
        updatedisplay()
        assert.is_true(spy.updated)
    end)

    it("passes a table to window:update()", function()
        reset()
        updatedisplay()
        assert.are.equal("table", type(spy.last_info))
    end)

    -- ── player.job propagation ───────────────────────────────────────────────

    it("sets info.job from player.job", function()
        reset({ job = "RUN" })
        updatedisplay()
        assert.are.equal("RUN", spy.last_info.job)
    end)

    it("reflects a different player job", function()
        reset({ job = "WAR" })
        updatedisplay()
        assert.are.equal("WAR", spy.last_info.job)
    end)

    -- ── Keybinding entries ───────────────────────────────────────────────────
    -- Each entry must be a non-empty string containing both a colour-code and
    -- a human-readable label.

    local keybinding_fields = {
        "weapons", "Engaged", "Hybrid", "AutoRune", "ChangeRune",
        "AutoTank", "AutoDefense", "Defense", "Casting", "Idle",
    }

    for _, field in ipairs(keybinding_fields) do
        it("populates info." .. field, function()
            reset()
            updatedisplay()
            local val = spy.last_info[field]
            assert.is_not_nil(val,              field .. " is nil")
            assert.are.equal("string", type(val), field .. " is not a string")
            assert.is_true(#val > 0,            field .. " is empty")
        end)

        it("info." .. field .. " contains a colour code", function()
            reset()
            updatedisplay()
            assert.is_truthy(
                spy.last_info[field]:find("\\cs(", 1, true),
                field .. " missing opening colour tag"
            )
            assert.is_truthy(
                spy.last_info[field]:find("\\cr", 1, true),
                field .. " missing closing colour tag"
            )
        end)
    end

    -- ── display_hud flag ────────────────────────────────────────────────────

    it("calls window:show() when display_hud is true", function()
        reset({ display_hud = true })
        updatedisplay()
        assert.is_true(spy.shown)
    end)

    it("does NOT call window:show() when display_hud is false", function()
        reset({ display_hud = false })
        updatedisplay()
        assert.is_false(spy.shown)
    end)

    -- ── update_delay / coroutine path ────────────────────────────────────────

    it("still updates the window when update_delay > 0", function()
        -- coroutine.sleep is stubbed to a no-op; update should still proceed
        reset({ update_delay = 5 })
        updatedisplay()
        assert.is_true(spy.updated)
    end)

    it("resets update_delay to 0 after sleeping", function()
        reset({ update_delay = 3 })
        updatedisplay()
        assert.are.equal(0, update_delay)
    end)

    it("skips coroutine.sleep when update_delay is 0", function()
        local sleep_called = false
        coroutine.sleep = function(_) sleep_called = true end
        reset({ update_delay = 0 })
        updatedisplay()
        assert.is_false(sleep_called)
        -- restore stub
        coroutine.sleep = function(_) end
    end)

    it("calls coroutine.sleep when update_delay > 0", function()
        local sleep_called = false
        coroutine.sleep = function(_) sleep_called = true end
        reset({ update_delay = 2 })
        updatedisplay()
        assert.is_true(sleep_called)
        coroutine.sleep = function(_) end
    end)
end)
