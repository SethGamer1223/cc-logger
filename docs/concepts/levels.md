# Log Levels

Every message carries a **level**  a small table with a numeric weight and a string name.
Levels control which messages are processed and which are discarded.

## Built-in Levels

| Constant            | Weight | Level Table          |
|---------------------|--------|----------------------|
| `logger.DEBUG`      | 1      | `{1, "DEBUG"}`       |
| `logger.INFO`       | 2      | `{2, "INFO"}`        |
| `logger.WARNING`    | 3      | `{3, "WARNING"}`     |
| `logger.ERROR`      | 4      | `{4, "ERROR"}`       |
| `logger.CRITICAL`   | 5      | `{5, "CRITICAL"}`    |

A level is considered valid by the library when it is a table with a number at index 1
and a string at index 2.

## `setLevel(level)` {: #setlevel}

Sets the logger's minimum threshold. Only messages at or above this weight will be
processed.

```lua
local logger = require("logger.lua")
local log = logger.new("quiet")

log:setLevel(logger.WARNING)   -- only WARNING and above

log:debug("you won't see this")
log:info("or this")
log:warn("but you WILL see this")   -- printed
log:error("and this")               -- printed
```

Returns `true` if the level was valid, `false` otherwise.

!!! tip "Per-handler thresholds"

    Handlers have their own `:setLevel()`. Raising or lowering a handler's level only
    affects that handler; it does not change `log:getEffectiveLevel()` or
    `log:isEnabledFor()`. See [Per-Handler Level Filtering](../handlers/index.md#per-handler-level-filtering).

## `isEnabledFor(level)` {: #isenabledfor}

Check whether a message at the given level would be logged:

```lua
if log:isEnabledFor(logger.DEBUG) then
    log:debug("info is enabled")
end
```

Returns `true` when `level[1] >= current_level[1]` and the level is valid.

## `getEffectiveLevel()` {: #geteffectivelevel}

Returns the level table currently in effect:

```lua
local lv = log:getEffectiveLevel()
print(lv[1]) -- example 1
print(lv[2])  -- example "INFO"
```

## How Filtering Works

Inside `Logger:log()`:

1. If the level table is invalid, the message is dropped.
2. For each handler, the effective threshold is `handler.level` if the handler has one,
   otherwise the logger's `self.level`.
3. If the message's weight is below that handler's threshold, the handler is skipped.
4. Otherwise, the handler's `:handle()` is called.

A handler never sees messages below its own threshold  which defaults to the logger's
level. You can raise or lower individual handlers independently of the logger:

```lua
local logger = require("logger.lua")
local log = logger.new("demo")

local fileH = logger.FileHandler(nil, "debug.log")
fileH:setLevel(logger.DEBUG)   -- this handler accepts DEBUG and up
log:addHandler(fileH)

log:setLevel(logger.WARNING)   -- console handler (default) stays at WARNING

-- DEBUG goes to debug.log but not the console:
log:debug("low-level detail")

-- WARNING goes to debug.log AND the console:
log:warn("warn")
```

## Creating Custom Levels

Any `{number, string}` table works. You could define:

```lua
local TRACE = {0, "TRACE"}
local FATAL = {6, "FATAL"}

log:setLevel(TRACE)
log:log("trace message", TRACE)
```

!!! warning "Levels are just data"

    There is no registration step  any valid level table is accepted. The
    `colors` table in the default Formatter only has entries for the five built-in
    levels, so custom levels won't get colored output unless you add them.

## Related

- [The Formatter](formatter.md)  how `{level}` is substituted
- [API Reference](../api/logger.md)  `setLevel`, `isEnabledFor`, `getEffectiveLevel`
