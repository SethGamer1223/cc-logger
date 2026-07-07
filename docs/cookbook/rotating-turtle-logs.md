# Rotating Logs on Turtles

Computers have limited disk space. Using `RotatingFileHandler` prevents a single log file
from filling the computer's drive.

## Mining Turtle with Size-Capped Log

```lua
-- miner.lua
local logger = require("logger.lua")

local fmt = logger.Formatter("{asctime} [{level}] {message}")
local h = logger.RotatingFileHandler(fmt, "miner.log", 4096, 2)
local log = logger.new("miner", true)
log:addHandler(h)

log:info("Mining program started")

local blocksMined = 0
local fuel = 0

for i = 1, 100 do
    -- fake mining
    blocksMined = blocksMined + 1
    fuel = fuel - 1

    if blocksMined % 10 == 0 then
        log:info("Progress: mined " .. blocksMined .. " blocks", {
            blocks = blocksMined,
            fuel = fuel
        })
    end

    if fuel < 50 then
        log:warn("Fuel critically low: {fuel}",{fuel=fuel})
    end

    if fuel <= 0 then
        log:critical("Out of fuel!!")
        break
    end
end

log:info("Mining session ended. Total blocks: " .. blocksMined)
```

After running, the turtle's disk will contain at most `~4 KB + 2 backups` of log data:

```
miner.log       ← current session (being written)
miner.log.1     ← previous session
miner.log.2     ← session before that
```

## Farming Turtle

```lua
-- farmer.lua
local logger = require("logger.lua")

local fmt = logger.Formatter("{asctime} [{level}] {message}")
local h = logger.RotatingFileHandler(fmt, "farm.log", 2048, 1)
local log = logger.new("farmer", true)
log:addHandler(h)

log:info("Farm program started")

local harvests = 0
for cycle = 1, 50 do
    harvests = harvests + 8  -- 8 crops per cycle
    log:info("Harvest cycle {cycle} complete", {
        totalHarvested = harvests,
        cycle=cycle
    })
end

log:info("Farm run complete: {harvests} items harvested",{harvests=harvests})
```

With only 2 KB cap and 1 backup, this uses minimal disk space.

## Combining Console + File 


```lua
local logger = require("logger.lua")

local log = logger.new("turtle")


-- rotating file
local fileFmt = logger.Formatter("{asctime} [{level}] {message}")
local fileH = logger.RotatingFileHandler(fileFmt, "turtle.log", 4096, 3)
log:addHandler(fileH)

log:info("Now logging to both terminal and rotating file")
```

Since `logger.new()` attaches a default `TerminalHandler`, you only need to add the file
handler.

## Related

- [RotatingFileHandler](../handlers/rotating-file.md)  handler details
- [Multi-Handler Setups](multi-handler.md)  combining handler types
