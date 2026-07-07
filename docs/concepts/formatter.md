# The Formatter

A Formatter holds a **template string** and a **date format string**. Every Handler
calls `formatter:format(msg, extra)` to produce the final output string.

## Default Template

```
[{loggername}] {asctime} [{level}] {message}
```

With the default `datefmt` of `%Y/%m/%e %H:%M:%S`, a typical line looks like:

```
[myApp] 2026/07/06 14:30:01 [INFO] System ready
```

## `{token}` Substitution

The `extra` table is the source for all `{token}` replacement. The Logger populates
three keys **before** passing to handlers:

| Extra Key      | Populated By | Value                                        |
|----------------|-------------|----------------------------------------------|
| `message`      | `Logger:log()` | The raw message string                    |
| `level`        | `Logger:log()` | The level name, e.g. `"INFO"`            |
| `loggername`   | `Logger:log()` | The logger's name (set at construction)  |
| `asctime`      | The formatter    | Auto-set in `:format()` if absent        |

The Logger sets `extra.message = msg` before dispatching to handlers. When the
formatter's `{message}` token is substituted, it expands to the raw message  which may
itself contain `{tokens}` for other extra keys to fill.

Any additional key you add to `extra` becomes available as a `{token}`:

```lua
local logger = require("logger.lua")

local log = logger.new("miner", true)  -- no default handler

-- Custom formatter with a new token
local fmt = logger.Formatter(
    "[{loggername}] [{level}] ({computerID}) {message}"
)

local termH = logger.TerminalHandler(fmt)
log:addHandler(termH)

log:info("Tunnel complete", {
    computerID = os.getComputerID()
})
-- Output: [miner] [INFO] (123) Tunnel complete
```

!!! tip "Any key works"

    There's no limit on token names  the formatter does a simple
    `formatted:gsub("{"..key.."}", tostring(value))` for every key in `extra`.

    `{message}` is substituted **first**, before the `pairs()` loop, so it is always
    resolved regardless of iteration order.

## `{tokens}` in Message Strings

Because the Logger sets `extra.message = msg` before dispatching, the message string
can itself contain `{tokens}` that reference other extra keys:

```lua
local logger = dofile("logger.lua")
local log = logger.new("miner")

log:warn("Fuel critically low: {fuel}", { fuel = 5 })
-- Output: [miner] 2026/07/06 14:30:01 [WARNING] Fuel critically low: 5
```

At runtime: `extra.message` is set to `"Fuel critically low: {fuel}"` by the Logger.
The formatter substitutes `{message}` first (before the `pairs()` loop), expanding it
to the raw string. Then the `pairs()` loop finds `{fuel}` in the expanded message and
replaces it.

You can use this to keep your code concise:

```lua
-- Instead of string concatenation:
log:info("Harvest cycle " .. cycle .. " complete")

-- Use a token in the message:
log:info("Harvest cycle {cycle} complete", { cycle = cycle })
```

!!! tip "Reliable"

    Because `{message}` is substituted explicitly before the `pairs()` loop, tokens
    in the message string are always resolved  no iteration order dependency.

## `logger.Formatter(fmt, datefmt)` {: #loggerformatter}

Constructs a new Formatter. Both parameters are optional.

| Parameter | Type     | Default                                    |
|-----------|----------|--------------------------------------------|
| `fmt`     | `string` | `"[{loggername}] {asctime} [{level}] {message}"` |
| `datefmt` | `string` | `"%Y/%m/%e %H:%M:%S"`                      |

Omitting a parameter keeps the default

```lua
local f1 = logger.Formatter()                         -- both defaults
local f2 = logger.Formatter("{level}: {message}")     -- custom fmt, default datefmt
local f3 = logger.Formatter(nil, "%H:%M:%S")          -- default fmt, custom datefmt
```


## `colors` Table

Every Formatter (including the default prototype) has a `colors` table mapping
level names to `{fg, bg}` color pairs. Used by [ColoredTerminalHandler](../handlers/colored-terminal.md).

| Level      | Foreground          |
|------------|---------------------|
| `DEBUG`    | `colors.blue`       |
| `INFO`     | `colors.white`      |
| `WARNING`  | `colors.yellow`     |
| `ERROR`    | `colors.red`        |
| `CRITICAL` | `colors.purple`     |

To customize colors for a single handler, build a new Formatter and override the
`colors` table:

```lua
local fmt = logger.Formatter()
fmt.colors = {
    INFO = { fg = colors.green },
    ERROR = { fg = colors.red, bg = colors.black }
}
```

## Related

- [Architecture](architecture.md)  where formatting fits in the pipeline
- [ColoredTerminalHandler](../handlers/colored-terminal.md)  the handler that uses `colors`
- [Levels](levels.md)  level constants
