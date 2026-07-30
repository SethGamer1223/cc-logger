describe("TerminalHandler", function()
    local function makeFakeTerm()
        local buf = ""
        local cx, cy = 1, 1
        return {
            write = function(text)
                buf = buf .. text
                cx = cx + #text
            end,
            getCursorPos = function() return cx, cy end,
            setCursorPos = function(x, y) cx, cy = x, y end,
            getSize = function() return 51, 19 end,
            scroll = function() end,
            clear = function() buf = ""; cx, cy = 1, 1 end,
            getBuffer = function() return buf end,
        }
    end

    it("format returns correctly formatted string with all placeholders", function()
        package.path = "/?.lua;/?/init.lua;" .. package.path
        local logger = require("logger")
        local h = logger.TerminalHandler()
        local result = h:format("hello", {
            asctime = "2000/01/01 00:00:00",
            level = "DEBUG",
            loggername = "test"
        })
        expect(result):equals("[test] 2000/01/01 00:00:00 [DEBUG] hello")
    end)

    it("handle writes formatted output to the terminal", function()
        package.path = "/?.lua;/?/init.lua;" .. package.path
        local logger = require("logger")
        local term = makeFakeTerm()
        local h = logger.TerminalHandler(nil, term)
        h:handle("test msg", {
            asctime = "2000/01/01 00:00:00",
            level = "INFO",
            loggername = "test"
        })
        expect(term.getBuffer()):str_match("%[test%] 2000/01/01 00:00:00 %[INFO%] test msg")
    end)

    it("generates asctime in format when asctime not provided", function()
        package.path = "/?.lua;/?/init.lua;" .. package.path
        local logger = require("logger")
        local h = logger.TerminalHandler()
        local result = h:format("msg", {
            level = "INFO",
            loggername = "test"
        })
        expect(result):str_match("%[test%] .+ %[INFO%] msg")
    end)

    it("addTo inserts handler into logger handlers list", function()
        package.path = "/?.lua;/?/init.lua;" .. package.path
        local logger = require("logger")
        local log = logger.new("test", true)
        local h = logger.TerminalHandler()
        h:addTo(log)
        expect(#log.handlers):equals(1)
        expect(log.handlers[1]):equals(h)
    end)

    it("uses default terminal when none provided", function()
        package.path = "/?.lua;/?/init.lua;" .. package.path
        local logger = require("logger")
        local h = logger.TerminalHandler()
        expect(h.term):equals(term.current())
    end)
end)
