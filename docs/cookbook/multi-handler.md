# Multi-Handler Setups

The Logger dispatches every message to **all** registered handlers. This makes it
trivial to send logs to multiple destinations simultaneously.

## Colored Terminal + Rotating File + WebSocket

```lua
local logger = require("logger.lua")

-- Logger without default handler
local log = logger.new("multiApp", true)
log:setLevel(logger.DEBUG)

-- 1. Colored console output
local console = logger.ColoredTerminalHandler()
log:addHandler(console)

-- 2. Rotating file 
local fileFmt = logger.Formatter("{asctime} [{level}] {message}")
local fileH = logger.RotatingFileHandler(fileFmt, "app.log", 8192, 3)
log:addHandler(fileH)

-- 3. WebSocket to remote log server
local ws, err = http.websocket("ws://logs.example.com/ingest")
if ws then
    local wsFmt = logger.Formatter("[{loggername}] {message}")
    local wsH = logger.WebsocketHandler(wsFmt, ws)
    log:addHandler(wsH)
end

-- All three handlers fire for every message
log:debug("Verbose diagnostic")
log:info("User logged in")
log:warn("Disk at 85%")
log:error("Connection timeout")
```

Each handler can have its own Formatter with different templates and date formats:

```lua
-- Terminal: short format
local termFmt = logger.Formatter("{level}: {message}")

-- File: full detail with timestamp
local fileFmt = logger.Formatter("{asctime} [{level}] ({loggername}) {message}")

-- WebSocket: JSON-like key-value
local wsFmt = logger.Formatter("{loggername}|{level}|{message}")
```

## Separating Levels by Handler

Because handlers don't filter by level (only the Logger does), you can create multiple
loggers at different levels targeting different outputs:

```lua
local logger = require("logger.lua")

-- Errors-only logger for alerts
local alertLog = logger.new("alert", true)
alertLog:setLevel(logger.ERROR)
local alertFile = logger.FileHandler(nil, "alerts.log")
alertLog:addHandler(alertFile)

-- Full debug logger for development
local devLog = logger.new("dev", true)
devLog:setLevel(logger.DEBUG)
local devConsole = logger.ColoredTerminalHandler()
devLog:addHandler(devConsole)

-- Use both in the same program
alertLog:info("You won't see this in alerts.log")  -- filtered by alertLog's level
devLog:info("You WILL see this on console")
alertLog:error("But you WILL see this in alerts.log")
```

## Related

- [Architecture](../concepts/architecture.md)  how dispatch works
- [Log Levels](../concepts/levels.md)  level filtering
