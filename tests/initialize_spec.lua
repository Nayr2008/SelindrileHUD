-- Tests for initialize(text, settings)
--
-- initialize() builds the HUD template by appending property strings to a
-- Windower text object.  It depends on the L{} list type (mocked below) and
-- on the text object's :clear() / :append() API.

local helpers_dir = debug.getinfo(1, "S").source:match("@?(.*/)")
package.path = helpers_dir .. "helpers/?.lua;" ..
               helpers_dir .. "../?.lua;" ..
               package.path

require("mock_windower")
require("runhud")

-- Build a spy text object that records calls made against it.
local function make_text_spy()
    return {
        cleared  = false,
        appended = nil,
        clear    = function(self)    self.cleared = true end,
        append   = function(self, s) self.appended = s   end,
        -- unused by initialize but keeps texts.new() contract intact
        show     = function(self) end,
        update   = function(self, _) end,
    }
end

describe("initialize", function()

    -- ── Interaction with the text object ────────────────────────────────────

    it("calls clear() on the text object", function()
        local spy = make_text_spy()
        initialize(spy, {})
        assert.is_true(spy.cleared)
    end)

    it("calls append() with a non-empty string", function()
        local spy = make_text_spy()
        initialize(spy, {})
        assert.is_not_nil(spy.appended)
        assert.is_true(#spy.appended > 0)
    end)

    -- ── Template content ─────────────────────────────────────────────────────
    -- Each HUD row is a ${token} placeholder rendered by Windower's text lib.
    -- These tests pin the exact set of tokens so that accidental deletions are
    -- caught immediately.

    local function appended_text()
        local spy = make_text_spy()
        initialize(spy, {})
        return spy.appended
    end

    local expected_tokens = {
        "job", "weapons", "Engaged", "Hybrid",
        "AutoDefense", "Defense", "ChangeRune", "AutoRune",
        "AutoTank", "Casting", "Idle",
    }

    for _, token in ipairs(expected_tokens) do
        it("includes ${" .. token .. "} placeholder", function()
            assert.is_truthy(appended_text():find("${" .. token .. "}", 1, true))
        end)
    end

    it("contains exactly " .. #expected_tokens .. " placeholders", function()
        local text  = appended_text()
        local count = 0
        for _ in text:gmatch("%${[^}]+}") do count = count + 1 end
        assert.are.equal(#expected_tokens, count)
    end)

    -- ── Formatting ───────────────────────────────────────────────────────────

    it("separates rows with newlines", function()
        -- Windower text objects render \n as line breaks
        assert.is_truthy(appended_text():find("\n"))
    end)

    it("wraps the job row with colour codes", function()
        -- The job row uses \cs(...) / \cr for colour; verify both are present
        local text = appended_text()
        assert.is_truthy(text:find("\\cs(", 1, true), "opening colour tag missing")
        assert.is_truthy(text:find("\\cr",  1, true), "closing colour tag missing")
    end)

    -- ── Idempotency ───────────────────────────────────────────────────────────

    it("produces the same output on repeated calls", function()
        local spy1 = make_text_spy()
        local spy2 = make_text_spy()
        initialize(spy1, {})
        initialize(spy2, {})
        assert.are.equal(spy1.appended, spy2.appended)
    end)

    it("ignores the settings argument (settings are unused)", function()
        local spy_no_settings  = make_text_spy()
        local spy_with_settings = make_text_spy()
        initialize(spy_no_settings,  {})
        initialize(spy_with_settings, { pos={x=999,y=999}, text={size=99} })
        assert.are.equal(spy_no_settings.appended, spy_with_settings.appended)
    end)
end)
