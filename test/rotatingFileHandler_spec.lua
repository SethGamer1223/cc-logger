describe("RotatingFileHandler", function()
    local testFile = "/test_rotating.log"

    local function cleanup()
        if fs.exists(testFile) then fs.delete(testFile) end
        for i = 1, 5 do
            local f = testFile .. "." .. i
            if fs.exists(f) then fs.delete(f) end
        end
    end

    it("format returns correctly formatted string with all placeholders", function()
        package.path = "/?.lua;/?/init.lua;" .. package.path
        local logger = require("logger")
        cleanup()
        local h = logger.RotatingFileHandler(nil, testFile, 1000, 2)
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
        local h = logger.RotatingFileHandler(nil, testFile, 1000, 2)
        h:handle("line one", {
            asctime = "2000/01/01 00:00:00",
            level = "INFO",
            loggername = "test"
        })
        expect(fs.exists(testFile)):equals(true)
        local f = fs.open(testFile, "r")
        local content = f.readAll()
        f.close()
        expect(content):str_match("line one")
        cleanup()
    end)

    it("rotates file when size limit exceeded", function()
        package.path = "/?.lua;/?/init.lua;" .. package.path
        cleanup()
        local logger = require("logger")
        local h = logger.RotatingFileHandler(nil, testFile, 5, 2)
        h:handle("AAAA", {
            asctime = "2000/01/01 00:00:00",
            level = "INFO",
            loggername = "test"
        })
        expect(fs.exists(testFile .. ".1")):equals(true)
        cleanup()
    end)

    it("does not rotate when under size limit", function()
        package.path = "/?.lua;/?/init.lua;" .. package.path
        cleanup()
        local logger = require("logger")
        local h = logger.RotatingFileHandler(nil, testFile, 5000, 2)
        h:handle("small", {
            asctime = "2000/01/01 00:00:00",
            level = "INFO",
            loggername = "test"
        })
        expect(fs.exists(testFile .. ".1")):equals(false)
        cleanup()
    end)

    it("limits backup files to backupCount", function()
        package.path = "/?.lua;/?/init.lua;" .. package.path
        cleanup()
        local logger = require("logger")
        local h = logger.RotatingFileHandler(nil, testFile, 5, 2)
        for i = 1, 4 do
            h:handle("AAAA", {
                asctime = "2000/01/01 00:00:00",
                level = "INFO",
                loggername = "test"
            })
        end
        expect(fs.exists(testFile .. ".3")):equals(false)
        expect(fs.exists(testFile .. ".2")):equals(true)
        cleanup()
    end)

    it("tracks existing file length on creation", function()
        package.path = "/?.lua;/?/init.lua;" .. package.path
        cleanup()
        local logger = require("logger")
        local f = fs.open(testFile, "w")
        f.write("existing content")
        f.close()
        local h = logger.RotatingFileHandler(nil, testFile, 4, 2)
        expect(h.length):equals(#"existing content")
        cleanup()
    end)

    it("opens file on first handle when delay is true", function()
        package.path = "/?.lua;/?/init.lua;" .. package.path
        cleanup()
        local logger = require("logger")
        local h = logger.RotatingFileHandler(nil, testFile, 1000, 2, "a", true)
        expect(h.file):equals(nil)
        h:handle("delayed", {
            asctime = "2000/01/01 00:00:00",
            level = "INFO",
            loggername = "test"
        })
        expect(fs.exists(testFile)):equals(true)
        cleanup()
    end)

    it("generates asctime when not provided in format", function()
        package.path = "/?.lua;/?/init.lua;" .. package.path
        cleanup()
        local logger = require("logger")
        local h = logger.RotatingFileHandler(nil, testFile, 1000, 2)
        local result = h:format("msg", {
            level = "CRITICAL",
            loggername = "test"
        })
        expect(result):str_match("%[test%] .+ %[CRITICAL%] msg")
        cleanup()
    end)

    it("addTo inserts handler into logger handlers list", function()
        package.path = "/?.lua;/?/init.lua;" .. package.path
        local logger = require("logger")
        local log = logger.new("test", true)
        cleanup()
        local h = logger.RotatingFileHandler(nil, testFile, 1000, 2)
        h:addTo(log)
        expect(#log.handlers):equals(1)
        expect(log.handlers[1]):equals(h)
        cleanup()
    end)
end)
