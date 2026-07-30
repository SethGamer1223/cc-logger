describe("TimedRotatingFileHandler", function()
    local testFile = "/test_timed.log"

    local function cleanup()
        if fs.exists(testFile) then fs.delete(testFile) end
        local dir = fs.getDir(testFile)
        if dir == "" then dir = "/" end
        local base = fs.getName(testFile)
        for _, name in ipairs(fs.list(dir)) do
            if name:match("^" .. base .. "%.") then
                fs.delete(dir .. "/" .. name)
            end
        end
    end

    it("format returns correctly formatted string with all placeholders", function()
        package.path = "/?.lua;/?/init.lua;" .. package.path
        local logger = require("logger")
        cleanup()
        local h = logger.TimedRotatingFileHandler(nil, testFile, "D", 1, 2)
        local result = h:format("hello", {
            asctime = "2000/01/01 00:00:00",
            level = "DEBUG",
            loggername = "test"
        })
        expect(result):equals("[test] 2000/01/01 00:00:00 [DEBUG] hello")
        cleanup()
    end)

    it("handle writes formatted log line to file", function()
        package.path = "/?.lua;/?/init.lua;" .. package.path
        cleanup()
        local logger = require("logger")
        local h = logger.TimedRotatingFileHandler(nil, testFile, "D", 1, 2)
        h:handle("timed line", {
            asctime = "2000/01/01 00:00:00",
            level = "INFO",
            loggername = "test"
        })
        expect(fs.exists(testFile)):equals(true)
        local f = fs.open(testFile, "r")
        local content = f.readAll()
        f.close()
        expect(content):str_match("timed line")
        cleanup()
    end)

    it("rotates file when current time passes rollover_at", function()
        package.path = "/?.lua;/?/init.lua;" .. package.path
        cleanup()
        local logger = require("logger")
        local h = logger.TimedRotatingFileHandler(nil, testFile, "D", 1, 2)
        h:handle("first", {
            asctime = "2000/01/01 00:00:00",
            level = "INFO",
            loggername = "test"
        })
        h.rollover_at = 0
        h:handle("second", {
            asctime = "2000/01/01 00:00:00",
            level = "INFO",
            loggername = "test"
        })
        local dir = fs.getDir(testFile)
        if dir == "" then dir = "/" end
        local base = fs.getName(testFile)
        local rotated = {}
        for _, name in ipairs(fs.list(dir)) do
            if name:match("^" .. base .. "%.") and name ~= base then
                table.insert(rotated, name)
            end
        end
        expect(#rotated):equals(1)
        cleanup()
    end)

    it("sets rollover_at for midnight to a future time within 24 hours", function()
        package.path = "/?.lua;/?/init.lua;" .. package.path
        local logger = require("logger")
        local h = logger.TimedRotatingFileHandler(nil, testFile, "midnight", 1, 2)
        expect(h.rollover_at):not_equals(nil)
        local future = h.rollover_at - os.epoch("local")
        expect(future > 0):equals(true)
        expect(future <= 86400000):equals(true)
        cleanup()
    end)

    it("sets rollover_at for second interval correctly", function()
        package.path = "/?.lua;/?/init.lua;" .. package.path
        local logger = require("logger")
        local h = logger.TimedRotatingFileHandler(nil, testFile, "S", 30, 2)
        local future = h.rollover_at - os.epoch("local")
        expect(future > 0):equals(true)
        expect(future <= 30000):equals(true)
        cleanup()
    end)

    it("sets rollover_at for minute interval", function()
        package.path = "/?.lua;/?/init.lua;" .. package.path
        local logger = require("logger")
        local h = logger.TimedRotatingFileHandler(nil, testFile, "M", 5, 2)
        local future = h.rollover_at - os.epoch("local")
        expect(future > 0):equals(true)
        expect(future <= 300000):equals(true)
        cleanup()
    end)

    it("sets rollover_at for hour interval", function()
        package.path = "/?.lua;/?/init.lua;" .. package.path
        local logger = require("logger")
        local h = logger.TimedRotatingFileHandler(nil, testFile, "H", 2, 2)
        local future = h.rollover_at - os.epoch("local")
        expect(future > 0):equals(true)
        expect(future <= 7200000):equals(true)
        cleanup()
    end)

    it("sets rollover_at for day interval", function()
        package.path = "/?.lua;/?/init.lua;" .. package.path
        local logger = require("logger")
        local h = logger.TimedRotatingFileHandler(nil, testFile, "D", 1, 2)
        local future = h.rollover_at - os.epoch("local")
        expect(future > 0):equals(true)
        expect(future <= 86400000):equals(true)
        cleanup()
    end)

    it("generates asctime when not provided in format", function()
        package.path = "/?.lua;/?/init.lua;" .. package.path
        cleanup()
        local logger = require("logger")
        local h = logger.TimedRotatingFileHandler(nil, testFile, "D", 1, 2)
        local result = h:format("msg", {
            level = "WARNING",
            loggername = "test"
        })
        expect(result):str_match("%[test%] .+ %[WARNING%] msg")
        cleanup()
    end)

    it("addTo inserts handler into logger handlers list", function()
        package.path = "/?.lua;/?/init.lua;" .. package.path
        cleanup()
        local logger = require("logger")
        local log = logger.new("test", true)
        local h = logger.TimedRotatingFileHandler(nil, testFile, "D", 1, 2)
        h:addTo(log)
        expect(#log.handlers):equals(1)
        expect(log.handlers[1]):equals(h)
        cleanup()
    end)
end)
