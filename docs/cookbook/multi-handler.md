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

Because each handler can have its own minimum level, you can route different severities
to different outputs on the **same** logger:

```lua
local logger = require("logger.lua")

local log = logger.new("app", true)
log:setLevel(logger.DEBUG)                -- console sees everything

-- Errors only to the alert file
local alertFile = logger.FileHandler(nil, "alerts.log")
alertFile:setLevel(logger.ERROR)
log:addHandler(alertFile)

-- Everything (DEBUG+) to the dev console
local devConsole = logger.ColoredTerminalHandler()
log:addHandler(devConsole)

log:debug("verbose diagnostic")           -- console only
log:info("normal operation")              -- console only
log:warn("getting risky")                 -- console only
log:error("something broke")              -- console AND alerts.log
log:critical("shutting down")             -- console AND alerts.log
```

Handlers without a `:setLevel()` call inherit the logger's level. You can also raise
one handler's threshold while the rest of the logger stays lower:

```lua
local quiet = logger.FileHandler(nil, "quiet.log")
quiet:setLevel(logger.CRITICAL)           -- only CRITICAL to this file
log:addHandler(quiet)
```

## Related

- [Architecture](../concepts/architecture.md)  how dispatch works
- [Log Levels](../concepts/levels.md)  level filtering
