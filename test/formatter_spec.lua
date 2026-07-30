describe("Formatter", function()
    it("creates formatter with default values", function()
        package.path = "/?.lua;/?/init.lua;" .. package.path
        local logger = require("logger")
        local fmt = logger.Formatter()
        expect(fmt.fmt):equals("[{loggername}] {asctime} [{level}] {message}")
        expect(fmt.datefmt):equals("%Y/%m/%e %H:%M:%S")
        expect(fmt.colors.DEBUG.fg):equals(colors.blue)
        expect(fmt.colors.INFO.fg):equals(colors.white)
        expect(fmt.colors.WARNING.fg):equals(colors.yellow)
        expect(fmt.colors.ERROR.fg):equals(colors.red)
        expect(fmt.colors.CRITICAL.fg):equals(colors.purple)
    end)

    it("creates formatter with custom fmt", function()
        package.path = "/?.lua;/?/init.lua;" .. package.path
        local logger = require("logger")
        local fmt = logger.Formatter("{level}: {message}")
        expect(fmt.fmt):equals("{level}: {message}")
        expect(fmt.datefmt):equals("%Y/%m/%e %H:%M:%S")
    end)

    it("creates formatter with custom datefmt", function()
        package.path = "/?.lua;/?/init.lua;" .. package.path
        local logger = require("logger")
        local fmt = logger.Formatter(nil, "%H:%M:%S")
        expect(fmt.fmt):equals("[{loggername}] {asctime} [{level}] {message}")
        expect(fmt.datefmt):equals("%H:%M:%S")
    end)

    it("creates formatter with both custom fmt and datefmt", function()
        package.path = "/?.lua;/?/init.lua;" .. package.path
        local logger = require("logger")
        local fmt = logger.Formatter("{asctime} - {message}", "%Y-%m-%d")
        expect(fmt.fmt):equals("{asctime} - {message}")
        expect(fmt.datefmt):equals("%Y-%m-%d")
    end)
end)
