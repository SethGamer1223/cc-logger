# Handlers Overview

A **Handler** receives `(msg, extra, level)` from a Logger, formats the message using
its own Formatter, and writes/transmits it somewhere.

## Common Interface

Every handler  built-in or custom  implements the following methods to work with
`Logger:addHandler()`:

| Method | Purpose |
|--------|---------|
| `:handle(msg, extra, level)` | Produce output (write to file, send over network, etc.) |
| `:format(msg, extra)` | Substitute `{token}` patterns using the formatter |
| `:addTo(logger)` | Insert self into `logger.handlers` (typically `table.insert(logger.handlers, self)`) |
| `:setLevel(level)` | **Optional.** Override this handler's minimum level. If set, the handler only fires for messages at or above `level`; otherwise it inherits the logger's level. Returns `true`/`false` |

!!! tip "`addTo` vs `addHandler`"

    You can add a handler to a logger with either `handler:addTo(logger)` or
    `logger:addHandler(handler)`. Both do `table.insert(logger.handlers, self)`.

## Per-Handler Level Filtering

Every handler can have its own minimum level via `:setLevel(level)`. When logging a
message, each handler only fires if the message's level weight is at or above its own
threshold. A handler that never calls `:setLevel` inherits the logger's level:

```lua
local logger = require("logger.lua")

local log = logger.new("app", true)

local console = logger.ColoredTerminalHandler()
local fileH = logger.FileHandler(nil, "app.log")

log:addHandler(console)              -- no setLevel: inherits logger's INFO
fileH:setLevel(logger.ERROR)         -- errors only to the file
log:addHandler(fileH)

log:info("shown on console, NOT written to file")
log:error("shown on console AND written to file")
```

## All Built-in Handlers

| Handler | Output | Page |
|---------|--------|------|
| `TerminalHandler` | Plain text to terminal or monitor | [TerminalHandler](terminal.md) |
| `ColoredTerminalHandler` | Per-level colored text with word-wrapping | [ColoredTerminalHandler](colored-terminal.md) |
| `FileHandler` | Append to a file | [FileHandler](file.md) |
| `RotatingFileHandler` | File rotation by byte-size | [RotatingFileHandler](rotating-file.md) |
| `TimedRotatingFileHandler` | File rotation by time interval | [TimedRotatingFileHandler](timed-rotating-file.md) |
| `WebsocketHandler` | Formatted string over websocket | [WebsocketHandler](websocket.md) |
| `RawWebsocketHandler` | Raw JSON `{msg, extra}` over websocket (no formatter) | [WebsocketHandler](websocket.md) |
| `ModemHandler` | Formatted string over rednet/modem | [ModemHandler](modem.md) |
| `RawModemHandler` | Raw `{msg, extra}` table over modem (no formatter) | [ModemHandler](modem.md) |
| `DiscordWebhookHandler` | Formatted message to a Discord webhook | [DiscordWebhookHandler](discord-webhook.md) |

## Related

- [Architecture](../concepts/architecture.md)  how handlers fit in the pipeline
- [The Formatter](../concepts/formatter.md)  how `{token}` substitution works
- [Writing a Custom Handler](custom.md)  build your own
