# Logger API Reference

A `Logger` object is created with `logger.new()`. It holds a name, a minimum level, and
a list of handlers. Every method below is available on the returned instance.

## `logger.new(name, RemoveDefaultHandle)` {: #new}

Creates a new Logger instance.

| Parameter           | Type                  | Default   | Description                                    |
|---------------------|-----------------------|-----------|------------------------------------------------|
| `name`              | `string`\|`nil`       | `"root"`  | Used in `{loggername}` token substitution       |
| `RemoveDefaultHandle`| `boolean`\|`nil`     | `false`   | If `true`, skip attaching default `TerminalHandler` |

The default level is `logger.INFO`.

```lua
local logger = require("logger.lua")

-- With default TerminalHandler
local log1 = logger.new("app")

-- No handlers at all
local log2 = logger.new("noHandlers", true)
```

## `:setLevel(level)` {: #setlevel}

Set the minimum logging threshold. Returns `true` if the level was valid, `false` otherwise.

| Parameter | Type    | Description               |
|-----------|---------|---------------------------|
| `level`   | `table` | A level table (e.g. `logger.WARNING`) |

```lua
local log = logger.new("demo")
local ok = log:setLevel(logger.WARNING)
print(ok)  -- true
log:setLevel({99, "NONSENSE"})  -- the level is valid (any {number, string} table works)
```

## `:isEnabledFor(level)` {: #isenabledfor}

Check whether a message at the given level would be logged (without actually logging it).

| Parameter | Type    | Description |
|-----------|---------|-------------|
| `level`   | `table` | Level table to check |

Returns `true` when `level[1] >= self.level[1]` and the level is valid.

```lua
local log = logger.new("checker")
log:setLevel(logger.WARNING)

print(log:isEnabledFor(logger.DEBUG))    -- false (1 < 3)
print(log:isEnabledFor(logger.WARNING))  -- true  (3 >= 3)
print(log:isEnabledFor(logger.ERROR))    -- true  (4 >= 3)
```

## `:getEffectiveLevel()` {: #geteffectivelevel}

Returns the current level table.

```lua
local log = logger.new("demo")
local lv = log:getEffectiveLevel()
print(lv[1])  -- 2 (INFO)
print(lv[2])  -- "INFO"
```

## `:addHandler(handler)` {: #addhandler}

Register a handler. The handler must implement `:handle(msg, extra, level)`,
`:format(msg, extra)`, and `:addTo(logger)`.

| Parameter | Type    | Description             |
|-----------|---------|-------------------------|
| `handler` | `table` | A handler instance |

```lua
local log = logger.new("multi", true)
local termH = logger.ColoredTerminalHandler()
log:addHandler(termH)
```

## `:log(msg, level, extra)` {: #log}

The core logging method. All other logging methods (`:debug`, `:info`, etc.) call this.

| Parameter | Type            | Default     | Description                              |
|-----------|-----------------|-------------|------------------------------------------|
| `msg`     | `string`        | *(required)*| The log message                          |
| `level`   | `table`         | *(required)*| Level table (e.g. `logger.INFO`)         |
| `extra`   | `table`\|`nil`  | `{}`        | Extra key-value pairs for `{token}` substitution |

The method auto-populates these keys in `extra` before processing:

| Key          | Value                        |
|--------------|------------------------------|
| `message`    | The raw `msg` string         |
| `level`      | The level name (e.g. `"INFO"`) |
| `loggername` | The logger's name            |

```lua
local log = logger.new("custom")
log:log("Something happened", logger.WARNING, {
    component = "reactor",
    temp = 873
})
```

## `:debug(msg, extra)` {: #debug}

Log at `DEBUG` level. Shorthand for `log(msg, logger.DEBUG, extra)`.

```lua
log:debug("Entering function parseConfig")
```

## `:info(msg, extra)` {: #info}

Log at `INFO` level.

```lua
log:info("Server listening on port 1234")
```

## `:warn(msg, extra)` {: #warn}

Log at `WARNING` level.

```lua
log:warn("Fuel below 10%")
```

## `:error(msg, extra)` {: #error}

Log at `ERROR` level.

```lua
log:error("Failed to open file: permission denied")
```

## `:critical(msg, extra)` {: #critical}

Log at `CRITICAL` level.

```lua
log:critical("Reactor temperature critical – emergency shutdown")
```

## `:basicConfig(...)` {: #basicconfig}

!!! warning "Not functional"

    This method references an undefined global `config` and will **error at runtime**
    if called. See [Known Quirks](../known-quirks.md).

```lua
-- This will error:
-- log:basicConfig({ level = logger.DEBUG })
```

## Full Example: Building a Logger from Scratch

```lua
local logger = require("logger.lua")

-- 1. Create logger with no default handler
local log = logger.new("factory", true)

-- 2. Set level
log:setLevel(logger.DEBUG)

-- 3. Build handlers
local console = logger.ColoredTerminalHandler()

local fileFmt = logger.Formatter("{asctime} [{level}] ({loggername}) {message}")
local fileH = logger.RotatingFileHandler(fileFmt, "factory.log", 16384, 5)

-- 4. Attach handlers
log:addHandler(console)
log:addHandler(fileH)

-- 5. Use every level
log:debug("Initializing subsystems")
log:info("Factory online")
log:warn("Conveyor belt speed low")
log:error("Robot arm fault at station 3")
log:critical("Safety interlock triggered – full stop")
```

## Related

- [Architecture](../concepts/architecture.md)  how Logger dispatches to handlers
- [Log Levels](../concepts/levels.md)  `setLevel`, `isEnabledFor`, `getEffectiveLevel`
- [Handlers Overview](../handlers/index.md)  all handler types
