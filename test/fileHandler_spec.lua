describe("FileHandler", function()
    local testFile = "/test_filehandler.log"

    local function cleanup()
        if fs.exists(testFile) then fs.delete(testFile) end
    end

    it("format returns correctly formatted string with all placeholders", function()
        package.path = "/?.lua;/?/init.lua;" .. package.path
        local logger = require("logger")
        local h = logger.FileHandler(nil, testFile)
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
        local h = logger.FileHandler(nil, testFile)
        h:handle("file line", {
            asctime = "2000/01/01 00:00:00",
            level = "INFO",
            loggername = "test"
        })
        expect(fs.exists(testFile)):equals(true)
        local f = fs.open(testFile, "r")
        local content = f.readAll()
        f.close()
        expect(content):equals("[test] 2000/01/01 00:00:00 [INFO] file line\n")
        cleanup()
    end)

    it("defaults to append mode and preserves existing content", function()
        package.path = "/?.lua;/?/init.lua;" .. package.path
        cleanup()
        local logger = require("logger")
        local f = fs.open(testFile, "w")
        f.write("preexisting\n")
        f.close()
        local h = logger.FileHandler(nil, testFile)
        h:handle("second line", {
            asctime = "2000/01/01 00:00:00",
            level = "INFO",
            loggername = "test"
        })
        local rf = fs.open(testFile, "r")
        local content = rf.readAll()
        rf.close()
        expect(content):equals("preexisting\n[test] 2000/01/01 00:00:00 [INFO] second line\n")
        cleanup()
    end)

    it("opens file on first handle when delay is true", function()
        package.path = "/?.lua;/?/init.lua;" .. package.path
        cleanup()
        local logger = require("logger")
        local h = logger.FileHandler(nil, testFile, "a", true)
        expect(h.file):equals(nil)
        h:handle("delayed line", {
            asctime = "2000/01/01 00:00:00",
            level = "DEBUG",
            loggername = "test"
        })
        expect(fs.exists(testFile)):equals(true)
        local f = fs.open(testFile, "r")
        local content = f.readAll()
        f.close()
        expect(content):str_match("delayed line")
        cleanup()
    end)

    it("opens file immediately when delay is nil or false", function()
        package.path = "/?.lua;/?/init.lua;" .. package.path
        cleanup()
        local logger = require("logger")
        local h = logger.FileHandler(nil, testFile, "a", false)
        expect(h.file):not_equals(nil)
        cleanup()
    end)

    it("generates asctime when not provided in format", function()
        package.path = "/?.lua;/?/init.lua;" .. package.path
        local logger = require("logger")
        local h = logger.FileHandler(nil, testFile)
        local result = h:format("msg", {
            level = "ERROR",
            loggername = "test"
        })
        expect(result):str_match("%[test%] .+ %[ERROR%] msg")
        cleanup()
    end)

    it("addTo inserts handler into logger handlers list", function()
        package.path = "/?.lua;/?/init.lua;" .. package.path
        local logger = require("logger")
        local log = logger.new("test", true)
        local h = logger.FileHandler(nil, testFile)
        h:addTo(log)
        expect(#log.handlers):equals(1)
        expect(log.handlers[1]):equals(h)
        cleanup()
    end)
end)
