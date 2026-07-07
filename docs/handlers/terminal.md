# TerminalHandler

Sends formatted log lines to a ComputerCraft terminal (or any object that supports the
terminal API  `getSize()`, `write()`, `getCursorPos()`, `setCursorPos()`, `scroll()`).

```
TerminalHandler(formatter, terminal)
```

## Parameters

| Parameter   | Type            | Default                    | Description                          |
|-------------|-----------------|----------------------------|--------------------------------------|
| `formatter` | `table`\|`nil`  | Copied from default prototype | Formatter to use for `{token}` substitution |
| `terminal`  | `table`\|`nil`  | `term.current()`           | Terminal object to write to          |

## Default Handler

`logger.new()` automatically attaches a `TerminalHandler(Formatter)` unless you pass
`true` for the `RemoveDefaultHandle` parameter:

```lua
-- Default handler is present:
local logA = logger.new("myApp")       -- has default TerminalHandler

-- No default handler:
local logB = logger.new("myApp", true) -- no handlers at all
```

## Example: Monitor as Log Output

You can point a TerminalHandler at a monitor peripheral instead of the default terminal:

```lua
local logger = require("logger.lua")

local monitor = peripheral.wrap("top")
local fmt = logger.Formatter("{asctime} [{level}] {message}")

local h = logger.TerminalHandler(fmt, monitor)
local log = logger.new("reactor", true)
log:addHandler(h)

log:info("Reactor online")
log:warn("Temperature approaching limit")
```

## Example: Custom Formatter with TerminalHandler

```lua
local logger = require("logger.lua")

local fmt = logger.Formatter("[{loggername}] {message}")
local h = logger.TerminalHandler(fmt)
local log = logger.new("minebot", true)
log:addHandler(h)

log:info("Started mining cycle")
```

## Notes

- The handler uses `print(self:format(log, extra) .. "\n")` to output. This means each
  log line gets an extra blank line after it.
- No color, no word-wrapping  see [ColoredTerminalHandler](colored-terminal.md) for
  those features.
- If you pass a monitor, make sure it is already `peripheral.wrap()`'d before
  constructing the handler.

## Related

- [ColoredTerminalHandler](colored-terminal.md)  colored, word-wrapped output
- [Formatter](../concepts/formatter.md)  `{token}` substitution
