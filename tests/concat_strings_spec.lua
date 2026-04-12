-- Tests for concat_strings()
--
-- concat_strings is a pure utility that converts a numerically-indexed table
-- into a newline-joined string.  It has zero external dependencies, making it
-- the ideal entry point for the test suite.
--
-- NOTE: concat_strings is currently defined but never called inside runhud.lua
-- (initialize uses the L{} :concat() method instead).  These tests both verify
-- its correctness and document that dead-code finding so it can be addressed.

local helpers_dir = debug.getinfo(1, "S").source:match("@?(.*/)")
package.path = helpers_dir .. "helpers/?.lua;" ..
               helpers_dir .. "../?.lua;" ..
               package.path

require("mock_windower")   -- set up L, texts, coroutine.sleep, player …
require("runhud")

describe("concat_strings", function()

    it("returns an empty string for an empty table", function()
        assert.are.equal("", concat_strings({}))
    end)

    it("returns the single element unchanged", function()
        assert.are.equal("hello", concat_strings({"hello"}))
    end)

    it("joins two elements with a single newline", function()
        assert.are.equal("a\nb", concat_strings({"a", "b"}))
    end)

    it("joins three or more elements with newlines", function()
        assert.are.equal("x\ny\nz", concat_strings({"x", "y", "z"}))
    end)

    it("converts integer values to strings", function()
        assert.are.equal("1\n2\n3", concat_strings({1, 2, 3}))
    end)

    it("converts boolean values to strings", function()
        assert.are.equal("true\nfalse", concat_strings({true, false}))
    end)

    it("handles mixed string/number/boolean elements", function()
        assert.are.equal("hello\n42\ntrue", concat_strings({"hello", 42, true}))
    end)

    it("ignores hash-keyed entries (ipairs behaviour)", function()
        -- ipairs stops at the first integer gap, so string keys are invisible
        local t = {"a", "b"}
        t.extra = "ignored"
        assert.are.equal("a\nb", concat_strings(t))
    end)

    -- DEAD-CODE ALERT --------------------------------------------------------
    -- concat_strings is never called inside runhud.lua; initialize() uses
    -- properties:concat('\n') (the L{} method) instead.  Either wire up
    -- concat_strings or remove it to avoid confusion.
    it("is not called anywhere in runhud (dead code)", function()
        -- This test will always pass; it exists solely to document the finding.
        -- Recommended action: replace properties:concat('\n') in initialize()
        -- with concat_strings(properties), or delete concat_strings entirely.
        assert.is_true(true)
    end)
end)
