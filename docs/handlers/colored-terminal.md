# ColoredTerminalHandler

Like [TerminalHandler](terminal.md), but applies per-level foreground/background colors
and uses a word-wrapping writer.

```
ColoredTerminalHandler(formatter, terminal)
```

## Parameters

| Parameter   | Type            | Default                    | Description                        |
|-------------|-----------------|----------------------------|------------------------------------|
| `formatter` | `table`\|`nil`  | Copied from default prototype | Formatter whose `colors` table drives per-level styling |
| `terminal`  | `table`\|`nil`  | `term.current()`           | Terminal or monitor object         |

## How Colors Work

When `:handle()` is called, it reads the level name, looks up `formatter.colors[LEVEL]`,
and applies the `fg` / `bg` values before writing. The previous colors are restored
after each line.

The default `colors` table:

| Level      | Foreground          | Background |
|------------|---------------------|------------|
| `DEBUG`    | `colors.blue`       | (none)     |
| `INFO`     | `colors.white`      | (none)     |
| `WARNING`  | `colors.yellow`     | (none)     |
| `ERROR`    | `colors.red`        | (none)     |
| `CRITICAL` | `colors.purple`     | (none)     |

## Example: Default Colors

```lua
local logger = require("logger.lua")

local h = logger.ColoredTerminalHandler()
local log = logger.new("miner", true)
log:addHandler(h)

log:debug("Starting scan")
log:info("Found deposit")
log:warn("Low fuel")
log:error("Chest full")
log:critical("Stuck in loop")
```

Each level prints in its configured color automatically.

## Example: Custom Color Scheme

```lua
local logger = require("logger.lua")

local fmt = logger.Formatter()
fmt.colors = {
    DEBUG    = { fg = colors.gray },
    INFO     = { fg = colors.green },
    WARNING  = { fg = colors.orange },
    ERROR    = { fg = colors.red,   bg = colors.black },
    CRITICAL = { fg = colors.white, bg = colors.red },
}

local h = logger.ColoredTerminalHandler(fmt)
local log = logger.new("server", true)
log:addHandler(h)

log:info("Green means good")
log:critical("Red alert!")
```

## Word-Wrapping

The internal `writeLine()` function performs word-wrapping: long lines are broken at
word boundaries to fit the terminal width, and the terminal scrolls when the cursor
reaches the bottom. Multi-line messages (`\n`) are handled line-by-line.

## Notes

- The `colors` table is read from the **Formatter**, not from the handler itself. To
  customize per-handler, create a new Formatter and set its `colors`.
- Background colors are optional  if `color.bg` is nil, the background is not changed.
- See [Formatter `colors` table](../concepts/formatter.md#colors-table) for the default structure.

## Related

- [TerminalHandler](terminal.md)  plain-text terminal output
- [The Formatter](../concepts/formatter.md)  the `colors` table, token substitution
