describe("ColoredTerminalHandler", function()
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
        local h = logger.ColoredTerminalHandler()
        local result = h:format("hello", {
            asctime = "2000/01/01 00:00:00",
            level = "INFO",
            loggername = "test"
        })
        expect(result):equals("[test] 2000/01/01 00:00:00 [INFO] hello")
    end)

    it("handle writes formatted output to the terminal", function()
        package.path = "/?.lua;/?/init.lua;" .. package.path
        local logger = require("logger")
        local term = makeFakeTerm()
        local h = logger.ColoredTerminalHandler(nil, term)
        h:handle("test msg", {
            asctime = "2000/01/01 00:00:00",
            level = "INFO",
            loggername = "test"
        }, logger.INFO)
        expect(term.getBuffer()):str_match("%[test%] 2000/01/01 00:00:00 %[INFO%] test msg")
    end)

    it("preserves original text color after handle", function()
        package.path = "/?.lua;/?/init.lua;" .. package.path
        local logger = require("logger")
        local originalColor = term.getTextColor()
        local h = logger.ColoredTerminalHandler()
        h:handle("msg", {
            asctime = "2000/01/01 00:00:00",
            level = "INFO",
            loggername = "test"
        }, logger.INFO)
        expect(term.getTextColor()):equals(originalColor)
    end)

    it("generates asctime when not provided in format", function()
        package.path = "/?.lua;/?/init.lua;" .. package.path
        local logger = require("logger")
        local h = logger.ColoredTerminalHandler()
        local result = h:format("msg", {
            level = "WARNING",
            loggername = "test"
        })
        expect(result):str_match("%[test%] .+ %[WARNING%] msg")
    end)

    it("uses custom colors from formatter without error", function()
        package.path = "/?.lua;/?/init.lua;" .. package.path
        local logger = require("logger")
        local term = makeFakeTerm()
        local fmt = logger.Formatter()
        fmt.colors = {
            INFO = { fg = colors.red, bg = colors.blue }
        }
        local h = logger.ColoredTerminalHandler(fmt, term)
        h:handle("custom color msg", {
            asctime = "2000/01/01 00:00:00",
            level = "INFO",
            loggername = "test"
        }, logger.INFO)
        expect(term.getBuffer()):str_match("custom color msg")
    end)

    it("addTo inserts handler into logger handlers list", function()
        package.path = "/?.lua;/?/init.lua;" .. package.path
        local logger = require("logger")
        local log = logger.new("test", true)
        local h = logger.ColoredTerminalHandler()
        h:addTo(log)
        expect(#log.handlers):equals(1)
        expect(log.handlers[1]):equals(h)
    end)
end)
