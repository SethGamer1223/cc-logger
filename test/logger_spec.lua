describe("logger.new", function()
    it("creates new logger with default name 'root', INFO level, and a default handler", function()
        package.path = "/?.lua;/?/init.lua;" .. package.path
        local logger = require("logger")
        local log = logger.new()
        expect(log.name):equals("root")
        expect(log:getEffectiveLevel()):same(logger.INFO)
        expect(#log.handlers):equals(1)
    end)

    it("creates logger without default handler when RemoveDefaultHandle is true", function()
        package.path = "/?.lua;/?/init.lua;" .. package.path
        local logger = require("logger")
        local log = logger.new("custom", true)
        expect(log.name):equals("custom")
        expect(#log.handlers):equals(0)
    end)

    it("creates logger with custom name", function()
        package.path = "/?.lua;/?/init.lua;" .. package.path
        local logger = require("logger")
        local log = logger.new("myapp")
        expect(log.name):equals("myapp")
    end)
end)

describe("logger.setLevel", function()
    it("returns true for a valid level table", function()
        package.path = "/?.lua;/?/init.lua;" .. package.path
        local logger = require("logger")
        local log = logger.new("test", true)
        expect(log:setLevel(logger.DEBUG)):equals(true)
        expect(log:getEffectiveLevel()):same(logger.DEBUG)
    end)

    it("returns false for an invalid level", function()
        package.path = "/?.lua;/?/init.lua;" .. package.path
        local logger = require("logger")
        local log = logger.new("test", true)
        expect(log:setLevel("not a level")):equals(false)
        expect(log:getEffectiveLevel()):same(logger.INFO)
    end)

    it("returns false for a malformed level table", function()
        package.path = "/?.lua;/?/init.lua;" .. package.path
        local logger = require("logger")
        local log = logger.new("test", true)
        expect(log:setLevel({1})):equals(false)
        expect(log:setLevel({"a", "b"})):equals(false)
        expect(log:setLevel({})):equals(false)
    end)
end)

describe("logger.isEnabledFor", function()
    it("returns true when level meets or exceeds the threshold", function()
        package.path = "/?.lua;/?/init.lua;" .. package.path
        local logger = require("logger")
        local log = logger.new("test", true)
        log:setLevel(logger.WARNING)
        expect(log:isEnabledFor(logger.WARNING)):equals(true)
        expect(log:isEnabledFor(logger.ERROR)):equals(true)
        expect(log:isEnabledFor(logger.CRITICAL)):equals(true)
    end)

    it("returns false when level is below threshold", function()
        package.path = "/?.lua;/?/init.lua;" .. package.path
        local logger = require("logger")
        local log = logger.new("test", true)
        log:setLevel(logger.WARNING)
        expect(log:isEnabledFor(logger.DEBUG)):equals(false)
        expect(log:isEnabledFor(logger.INFO)):equals(false)
    end)

    it("returns false for invalid level", function()
        package.path = "/?.lua;/?/init.lua;" .. package.path
        local logger = require("logger")
        local log = logger.new("test", true)
        expect(log:isEnabledFor("bad")):equals(false)
    end)
end)

describe("logger.getEffectiveLevel", function()
    it("returns the current level", function()
        package.path = "/?.lua;/?/init.lua;" .. package.path
        local logger = require("logger")
        local log = logger.new("test", true)
        expect(log:getEffectiveLevel()):same(logger.INFO)
        log:setLevel(logger.DEBUG)
        expect(log:getEffectiveLevel()):same(logger.DEBUG)
    end)
end)

describe("logger.basicConfig", function()
    it("sets configuration fields on the logger", function()
        package.path = "/?.lua;/?/init.lua;" .. package.path
        local logger = require("logger")
        local log = logger.new("test", true)
        log:basicConfig({ name = "newname", level = logger.DEBUG })
        expect(log.name):equals("newname")
        expect(log:getEffectiveLevel()):same(logger.DEBUG)
    end)
end)

describe("logger.addHandler", function()
    it("adds a handler to the logger", function()
        package.path = "/?.lua;/?/init.lua;" .. package.path
        local logger = require("logger")
        local log = logger.new("test", true)
        expect(#log.handlers):equals(0)
        local h = { handle = function() end }
        log:addHandler(h)
        expect(#log.handlers):equals(1)
        expect(log.handlers[1]):equals(h)
    end)
end)

describe("logger.log", function()
    it("dispatches to all handlers with correct arguments", function()
        package.path = "/?.lua;/?/init.lua;" .. package.path
        local logger = require("logger")
        local calls = {}
        local h1 = {
            handle = function(_, log, extra, level)
                table.insert(calls, { log = log, extra = extra, level = level })
            end
        }
        local h2 = {
            handle = function(_, log, extra, level)
                table.insert(calls, { log = log, extra = extra, level = level })
            end
        }
        local log = logger.new("test", true)
        log:addHandler(h1)
        log:addHandler(h2)
        log:log("hello", logger.INFO, { custom = "val" })
        expect(#calls):equals(2)
        expect(calls[1].log):equals("hello")
        expect(calls[1].extra.message):equals("hello")
        expect(calls[1].extra.level):equals("INFO")
        expect(calls[1].extra.loggername):equals("test")
        expect(calls[1].extra.custom):equals("val")
        expect(calls[1].level):same(logger.INFO)
    end)

    it("filters messages below the threshold", function()
        package.path = "/?.lua;/?/init.lua;" .. package.path
        local logger = require("logger")
        local callCount = 0
        local h = {
            handle = function() callCount = callCount + 1 end
        }
        local log = logger.new("test", true)
        log:setLevel(logger.WARNING)
        log:addHandler(h)
        log:log("debug msg", logger.DEBUG)
        log:log("info msg", logger.INFO)
        log:log("warn msg", logger.WARNING)
        expect(callCount):equals(1)
    end)

    it("returns nil when message is nil", function()
        package.path = "/?.lua;/?/init.lua;" .. package.path
        local logger = require("logger")
        local h = { handle = function() end }
        local log = logger.new("test", true)
        log:addHandler(h)
        local result = log:log(nil, logger.INFO)
        expect(result):equals(nil)
    end)

    it("ignores invalid level", function()
        package.path = "/?.lua;/?/init.lua;" .. package.path
        local logger = require("logger")
        local callCount = 0
        local h = { handle = function() callCount = callCount + 1 end }
        local log = logger.new("test", true)
        log:addHandler(h)
        log:log("msg", "badlevel")
        expect(callCount):equals(0)
    end)

    it("passes level argument to handler.handle", function()
        package.path = "/?.lua;/?/init.lua;" .. package.path
        local logger = require("logger")
        local received = nil
        local h = {
            handle = function(_, log, extra, level)
                received = level
            end
        }
        local log = logger.new("test", true)
        log:addHandler(h)
        log:log("msg", logger.CRITICAL)
        expect(received):same(logger.CRITICAL)
    end)
end)

describe("logger convenience methods", function()
    local function makeTrackingHandler()
        local last = {}
        return {
            handle = function(_, log, extra, level)
                last.log = log
                last.extra = extra
                last.level = level
            end,
            getLast = function() return last end
        }
    end

    it("debug logs at DEBUG level", function()
        package.path = "/?.lua;/?/init.lua;" .. package.path
        local logger = require("logger")
        local h = makeTrackingHandler()
        local log = logger.new("test", true)
        log:setLevel(logger.DEBUG)
        log:addHandler(h)
        log:debug("debug msg")
        expect(h.getLast().level):same(logger.DEBUG)
        expect(h.getLast().extra.level):equals("DEBUG")
    end)

    it("info logs at INFO level", function()
        package.path = "/?.lua;/?/init.lua;" .. package.path
        local logger = require("logger")
        local h = makeTrackingHandler()
        local log = logger.new("test", true)
        log:addHandler(h)
        log:info("info msg")
        expect(h.getLast().level):same(logger.INFO)
    end)

    it("warn logs at WARNING level", function()
        package.path = "/?.lua;/?/init.lua;" .. package.path
        local logger = require("logger")
        local h = makeTrackingHandler()
        local log = logger.new("test", true)
        log:addHandler(h)
        log:warn("warn msg")
        expect(h.getLast().level):same(logger.WARNING)
    end)

    it("error logs at ERROR level", function()
        package.path = "/?.lua;/?/init.lua;" .. package.path
        local logger = require("logger")
        local h = makeTrackingHandler()
        local log = logger.new("test", true)
        log:addHandler(h)
        log:error("error msg")
        expect(h.getLast().level):same(logger.ERROR)
    end)

    it("critical logs at CRITICAL level", function()
        package.path = "/?.lua;/?/init.lua;" .. package.path
        local logger = require("logger")
        local h = makeTrackingHandler()
        local log = logger.new("test", true)
        log:addHandler(h)
        log:critical("critical msg")
        expect(h.getLast().level):same(logger.CRITICAL)
    end)

    it("convenience methods pass extra table to handlers", function()
        package.path = "/?.lua;/?/init.lua;" .. package.path
        local logger = require("logger")
        local h = makeTrackingHandler()
        local log = logger.new("test", true)
        log:setLevel(logger.DEBUG)
        log:addHandler(h)
        log:info("msg with extra", { user = "alice" })
        expect(h.getLast().extra.user):equals("alice")
        expect(h.getLast().extra.message):equals("msg with extra")
    end)

    it("convenience methods are filtered by level threshold", function()
        package.path = "/?.lua;/?/init.lua;" .. package.path
        local logger = require("logger")
        local callCount = 0
        local h = {
            handle = function() callCount = callCount + 1 end
        }
        local log = logger.new("test", true)
        log:setLevel(logger.ERROR)
        log:addHandler(h)
        log:debug("should not pass")
        log:info("should not pass")
        log:warn("should not pass")
        log:error("should pass")
        log:critical("should pass")
        expect(callCount):equals(2)
    end)
end)
