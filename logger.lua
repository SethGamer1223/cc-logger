--------------------------------------------------------------------------------
-- Copyright 2025 SethGamer1223

-- Permission is hereby granted, free of charge, to any person obtaining a copy
-- of this software and associated documentation files (the "Software"), to deal
-- in the Software without restriction, including without limitation the rights
-- to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
-- copies of the Software, and to permit persons to whom the Software is
-- furnished to do so, subject to the following conditions:

-- The above copyright notice and this permission notice shall be included in
-- all copies or substantial portions of the Software.

-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
-- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
-- OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
-- THE SOFTWARE.
--------------------------------------------------------------------------------



local logger = {
    DEBUG = {1, "DEBUG"},
    INFO = {2, "INFO"},
    WARNING = {3, "WARNING"},
    ERROR = {4, "ERROR"},
    CRITICAL = {5, "CRITICAL"}
}

local function istype(object,expected)
    if type(object) == expected then
        return true
    else
        return false
    end
end

function copytemplate(original)
    local copy = {}
    setmetatable(copy, {__index = original})

    return copy
end





function validLevel(level)
    return type(level) == "table" and
           type(level[1]) == "number" and
           type(level[2]) == "string"
end

local Formatter = {
    fmt = "[{loggername}] {asctime} [{level}] {message}",
    datefmt = "%Y/%m/%e %H:%M:%S",
    colors = {
        ["DEBUG"] = {
            ["fg"] = colors.blue
        },
        ["INFO"] = {
            ["fg"] = colors.white
        },
        ["WARNING"] = {
            ["fg"] = colors.yellow
        },
        ["ERROR"] = {
            ["fg"] = colors.red
        },
        ["CRITICAL"] = {
            ["fg"] = colors.purple
        }
    }
}
--- Creates a handler that outputs to the ComputerCraft terminal.
--- @param formatter table|nil Optional custom formatter object
--- @param terminal table|nil Optional terminal object (defaults to term.current())
--- @return table Handler object

logger["TerminalHandler"] = function(formatter,terminal)
    local self = {}
    if not terminal then
        self.term = term.current()
    else
        self.term = terminal
    end

    self.formatter = formatter or copytemplate(Formatter)


    function self:format(message,extra)
        if not extra.asctime then extra.asctime = os.date(self.formatter.datefmt) end
        local formatted = self.formatter.fmt
        for key, value in pairs(extra) do
            formatted = formatted:gsub("{"..key.."}", tostring(value))
        end
        return formatted
    end


    function self:handle(log,extra)

        print(self:format(log,extra).."\n")
    end


    function self:addTo(logger)
        table.insert(logger.handlers, self)
    end

    return self
end
local function writeLine(term, text)
    local w, h = term.getSize()

    local function newLine()
        local _, y = term.getCursorPos()
        if y >= h then
            term.scroll(1)
            term.setCursorPos(1, h)
        else
            term.setCursorPos(1, y + 1)
        end
    end

    for rawLine in string.gmatch(text, "([^\n]*)\n?") do
        local words = {}
        for word in rawLine:gmatch("%S+") do
            table.insert(words, word)
        end

        for i, word in ipairs(words) do
            local x, y = term.getCursorPos()
            local spaceLeft = w - x + 1

            local prefix = (x > 1) and " " or ""
            local needed = #prefix + #word

            if needed > spaceLeft then
                newLine()
                prefix = ""
            end

            while #word > 0 do
                local x2 = select(1, term.getCursorPos())
                local room = w - x2 + 1

                if room == 0 then
                    newLine()
                    room = w
                end

                local chunk = word:sub(1, room)
                word = word:sub(#chunk + 1)

                term.write(prefix .. chunk)
                prefix = ""

                if #word > 0 then
                    newLine()
                end
            end
        end


        newLine()
    end
end
--- Creates a handler that outputs colored text to the terminal based on log level.
--- @param formatter table|nil Optional custom formatter
--- @param terminal table|nil Optional terminal object
--- @return table Handler object

logger["ColoredTerminalHandler"] = function(formatter, terminal)
    local self = {}

    self.term = terminal or term.current()
    self.formatter = formatter or copytemplate(Formatter)

    function self:format(message, extra)
        if not extra.asctime then
            extra.asctime = os.date(self.formatter.datefmt)
        end

        local formatted = self.formatter.fmt
        for key, value in pairs(extra) do
            formatted = formatted:gsub("{" .. key .. "}", tostring(value))
        end
        return formatted
    end

    function self:handle(log, extra, level)
        level = string.upper(level[2])

        local term = self.term
        local oldText = term.getTextColor()
        local oldBg = term.getBackgroundColor()

        local color = self.formatter.colors[level]
        if color then
            if color.bg then term.setBackgroundColor(color.bg) end
            if color.fg then term.setTextColor(color.fg) end
        end

        writeLine(term,self:format(log, extra))

        term.setTextColor(oldText)
        term.setBackgroundColor(oldBg)
    end

    function self:addTo(logger)
        table.insert(logger.handlers, self)
    end

    return self
end
--- Creates a handler that writes logs to a file.
--- @param formatter table|nil Optional custom formatter
--- @param filename string The path to the log file
--- @param mode string|nil File mode (default "a")
--- @param delay boolean|nil If true, file is not opened until first log
--- @return table Handler object

logger["FileHandler"] = function(formatter,filename,mode,delay)
    local self = {}
    assert(type(filename,"string")=="string","Filename must be a string")
    assert(type(filename)=="string" or nil,"File opening mode must be provided or left nil for default (a)")
    if not mode then
        mode = "a"
    end
    if not delay then
        self.file = fs.open(filename,mode)
    end

    self.formatter = formatter or copytemplate(Formatter)


    function self:format(message,extra)
        if not extra.asctime then extra.asctime = os.date(self.formatter.datefmt) end
        local formatted = self.formatter.fmt
        for key, value in pairs(extra) do
            formatted = formatted:gsub("{"..key.."}", tostring(value))
        end
        return formatted
    end

    function self:handle(log,extra)
        if not self.file then
            self.file = fs.open(filename,mode)
        end
        self.file.write(self:format(log,extra).."\n")
    end


    function self:addTo(logger)
        table.insert(logger.handlers, self)
    end

    return self
end

--- Creates a file handler that rotates based on file size.
--- @param formatter table|nil Optional custom formatter
--- @param filename string The path to the log file
--- @param maxByte number Maximum size in bytes before rotation
--- @param backupCount number Number of old log files to keep
--- @param mode string|nil File mode
--- @param delay boolean|nil If true, delays file opening
--- @return table Handler object

logger["RotatingFileHandler"] = function(formatter,filename,maxByte,backupCount,mode,delay)
    local self = {}
    self.length = 0
    assert(type(filename,"string")=="string","Filename must be a string")
    assert(type(filename)=="string" or nil,"File opening mode must be provided or left nil for default (a)")
    if not mode then
        mode = "a"
    end
    if fs.exists(filename) then
        local lengthReader = fs.open(filename,"r")
        self.length = lengthReader.seek("end")
        lengthReader.close()
    end
    if not delay then
        self.file = fs.open(filename,mode)
    end

    self.formatter = formatter or copytemplate(Formatter)


    function self:format(message,extra)
        if not extra.asctime then extra.asctime = os.date(self.formatter.datefmt) end
        local formatted = self.formatter.fmt
        for key, value in pairs(extra) do
            formatted = formatted:gsub("{"..key.."}", tostring(value))
        end
        return formatted
    end


    function self:handle(log, extra)

        if not self.file then
            self.file = fs.open(filename, mode)
        end

        local formatted = self:format(log, extra) .. "\n"
        local length = #formatted


        if maxByte and backupCount and backupCount > 0 then
            if self.length + length >= maxByte then
                self.file.close()
                self.file = nil

                local oldest = filename .. "." .. backupCount
                if fs.exists(oldest) then
                    fs.delete(oldest)
                end


                for i = backupCount - 1, 1, -1 do
                    local src = filename .. "." .. i
                    local dst = filename .. "." .. (i + 1)
                    if fs.exists(src) then
                        fs.move(src, dst)
                    end
                end

                if fs.exists(filename) then
                    fs.move(filename, filename .. ".1")
                end


                self.file = fs.open(filename, mode)
                self.length = 0
            end
        end

        self.file.write(formatted)
        self.length = self.length + length
    end

    function self:addTo(logger)
        table.insert(logger.handlers, self)
    end

    return self
end
--- Creates a file handler that rotates based on time intervals.
--- @param formatter table|nil Optional custom formatter
--- @param filename string Path to the file
--- @param when string Interval type: "S", "M", "H", "D", or "midnight"
--- @param interval number Frequency of rotation
--- @param backupCount number Number of logs to retain
--- @param delay boolean|nil Delay file opening
--- @param useUTC boolean Use UTC time instead of local
--- @return table Handler object
logger["TimedRotatingFileHandler"] = function(
    formatter,
    filename,
    when,
    interval,
    backupCount,
    delay,
    useUTC
)
    local self = {}
    assert(type(filename) == "string", "Filename must be a string")
    when = when or "D"
    interval = interval or 1
    backupCount = backupCount or 0
    useUTC = useUTC or false

    local function now()
        -- CC: os.time() returns days, but os.epoch("local") returns ms
        return os.epoch("local")  -- milliseconds since epoch
    end

    local function nextRollover(current)
        local unit = ({
            S = 1000,
            M = 60000,
            H = 3600000,
            D = 86400000
        })[when]

        if unit then
            return current + unit * interval
        end

        if when == "midnight" then
            local t = textutils.unserializeJSON(textutils.serializeJSON({ os.date("*t") }))
            t.hour, t.min, t.sec = 0, 0, 0
            local base = os.time(t) * 1000
            local nextMid = base + 86400000

            return nextMid
        end
    end

    self.formatter = formatter or copytemplate(Formatter)
    self.rollover_at = nextRollover(now())
    self.file = nil

    local function openFile()
        if not self.file then
            self.file = fs.open(filename, "a")
        end
    end

    local function getTimestampString()
        local t = useUTC and os.date("!*t") or os.date("*t")
        return string.format("%04d-%02d-%02d_%02d-%02d-%02d",
            t.year, t.month, t.day, t.hour, t.min, t.sec
        )
    end

    local function rotate()
        if self.file then
            self.file.close()
            self.file = nil
        end

        local newname = filename .. "." .. getTimestampString()

        if fs.exists(newname) then
            fs.delete(newname)
        end

        if fs.exists(filename) then
            fs.move(filename, newname)
        end

        -- cleanup old backups
        if backupCount > 0 then
            -- gather all rotated files matching pattern
            local dir = fs.getDir(filename)
            if dir == "" then dir = "/" end
            local base = fs.getName(filename)
            local list = fs.list(dir)

            local rotated = {}
            for _, f in ipairs(list) do
                if f:match("^" .. base .. "%..+") then
                    table.insert(rotated, dir .. "/" .. f)
                end
            end

            table.sort(rotated) -- chronological because timestamp is sortable

            while #rotated > backupCount do
                fs.delete(rotated[1])
                table.remove(rotated, 1)
            end
        end

        -- new rollover time
        self.rollover_at = nextRollover(now())
    end

    function self:format(message, extra)
        if not extra.asctime then extra.asctime = os.date(self.formatter.datefmt) end
        local formatted = self.formatter.fmt
        for k, v in pairs(extra) do
            formatted = formatted:gsub("{"..k.."}", tostring(v))
        end
        return formatted
    end

    function self:handle(log, extra)
        local current = now()
        if current >= self.rollover_at then
            rotate()
        end

        if not delay then openFile() end
        openFile()

        local formatted = self:format(log, extra) .. "\n"
        self.file.write(formatted)
    end

    function self:addTo(logger)
        table.insert(logger.handlers, self)
    end

    return self
end

logger["WebsocketHandler"] = function(formatter,websocket)
    local self = {}
    self.websocket = websocket

    self.formatter = formatter or copytemplate(Formatter)


    function self:format(message,extra)
        if not extra.asctime then extra.asctime = os.date(self.formatter.datefmt) end
        local formatted = self.formatter.fmt
        for key, value in pairs(extra) do
            formatted = formatted:gsub("{"..key.."}", tostring(value))
        end
        return formatted
    end


    function self:handle(log,extra)
        self.websocket.send(self:format(log,extra))
    end


    function self:addTo(logger)
        table.insert(logger.handlers, self)
    end

    return self
end
--- Handler that sends raw JSON-serialized log data over a Websocket.
-- Sends a table: {message, extra_data}
-- @tparam any _ Ignored formatter (raw data uses no template)
-- @tparam table websocket An established CC websocket object
logger["RawWebsocketHandler"] = function(formatter,websocket)
    local self = {}
    self.websocket = websocket



    function self:handle(log,extra)
        self.websocket.send(textutils.serializeJSON({log,extra}))
    end


    function self:addTo(logger)
        table.insert(logger.handlers, self)
    end

    return self
end
--- Handler that transmits formatted strings via a ComputerCraft Modem.
-- @tparam[opt] table formatter Custom formatter
-- @tparam table modem The modem peripheral object
-- @tparam number channel The channel to transmit on

logger["ModemHandler"] = function(formatter,modem,channel)
    local self = {}
    self.modem = modem

    self.formatter = formatter or copytemplate(Formatter)


    function self:format(message,extra)
        if not extra.asctime then extra.asctime = os.date(self.formatter.datefmt) end
        local formatted = self.formatter.fmt
        for key, value in pairs(extra) do
            formatted = formatted:gsub("{"..key.."}", tostring(value))
        end
        return formatted
    end


    function self:handle(log,extra)
        self.modem.transmit(channel,channel,self:format(log,extra))
    end


    function self:addTo(logger)
        table.insert(logger.handlers, self)
    end

    return self
end

--- Handler that transmits raw tables via a ComputerCraft Modem.
-- Transmits a table: {message, extra_data}
-- @tparam any _ Ignored formatter
-- @tparam table modem The modem peripheral object
-- @tparam number channel The channel to transmit on
logger["RawModemHandler"] = function(formatter,modem,channel)
    local self = {}
    self.modem = modem



    function self:handle(log,extra)
        self.modem.transmit(channel,channel,{log,extra})
    end


    function self:addTo(logger)
        table.insert(logger.handlers, self)
    end

    return self
end

-- Enhanced Formatter implementation
logger["Formatter"] = function(fmt,datefmt)
    local formatter = copytemplate(Formatter)
    if fmt then formatter.fmt = fmt end
    if datefmt then formatter.datefmt = datefmt end
    return formatter
end

--- Creates a new Logger instance.
-- @tparam[opt] string name Logger name (default "root")
-- @tparam[opt] boolean RemoveDefaultHandle If true, ignores the default TerminalHandler
-- @treturn table The logger instance
logger["new"] = function(name,RemoveDefaultHandle)
    local self = setmetatable({}, {__index = logger})

    self.name = name or "root"
    self.level = logger.INFO  -- Default level
    self.handlers = {}
    if not RemoveDefaultHandle then
        table.insert(self.handlers,logger.TerminalHandler(Formatter))
    end
    --- Set the minimum logging level.
    -- @tparam table level The level table (e.g. logger.DEBUG)
    -- @treturn boolean
    function self:setLevel(level)
        if validLevel(level) then
            self.level = level
            return true
        else
            return false
        end
    end

    function self:isEnabledFor(level)
        if validLevel(level) and level[1] >= self.level[1] then
            return true
        else
            return false
        end
    end

    function self:getEffectiveLevel()
        return self.level
    end

    function self:basicConfig(...)
        for i, v in pairs(...) do
            config[i] = v
        end
    end
    --- Add a custom handler to this logger.
    -- @tparam table handler The handler instance
    function self:addHandler(handler)
        table.insert(self.handlers, handler)
    end
    --- Core logging function.
    -- @tparam string msg The message
    -- @tparam table level Log level
    -- @tparam[opt] table extra Table for template variables
    function self:log(msg, level, extra, ...)
        if not msg then return end
        if not extra then extra = {} end
        if not extra.message then extra.message = msg end
        if not extra.level then extra.level = level[2] end
        if not loggername then extra.loggername = self.name end
        if not validLevel(level) then return end
        if level[1] < self.level[1] then return end

        for i,v in pairs(self.handlers) do
            v:handle(msg,extra,level)
        end

    end

    -- Fixed level-specific methods
    --- Log at DEBUG level.
    -- @tparam string msg
    -- @tparam[opt] table extra
    function self:debug(msg, extra, ...) self:log(msg, logger.DEBUG, extra,  ...) end
    --- Log at INFO level.
    -- @tparam string msg
    -- @tparam[opt] table extra
    function self:info(msg, extra, ...) self:log(msg, logger.INFO, extra, ...) end
    --- Log at WARNING level.
    -- @tparam string msg
    -- @tparam[opt] table extra
    function self:warn(msg, extra, ...) self:log(msg, logger.WARNING, extra, ...) end
    --- Log at ERROR level.
    -- @tparam string msg
    -- @tparam[opt] table extra
    function self:error(msg, extra, ...) self:log(msg, logger.ERROR, extra, ...) end
    --- Log at CRITICAL level.
    -- @tparam string msg
    -- @tparam[opt] table extra
    function self:critical(msg, extra, ...) self:log(msg, logger.CRITICAL, extra, ...) end

    return self
end

return logger
