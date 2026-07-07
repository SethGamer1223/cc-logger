# Handlers Overview

A **Handler** receives `(msg, extra, level)` from a Logger, formats the message using
its own Formatter, and writes/transmits it somewhere.

## Common Interface

Every handler  built-in or custom  must implement three methods to work with
`Logger:addHandler()`:

| Method | Purpose |
|--------|---------|
| `:handle(msg, extra, level)` | Produce output (write to file, send over network, etc.) |
| `:format(msg, extra)` | Substitute `{token}` patterns using the formatter |
| `:addTo(logger)` | Insert self into `logger.handlers` (typically `table.insert(logger.handlers, self)`) |

!!! tip "`addTo` vs `addHandler`"

    You can add a handler to a logger with either `handler:addTo(logger)` or
    `logger:addHandler(handler)`. Both do `table.insert(logger.handlers, self)`.

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

## Related

- [Architecture](../concepts/architecture.md)  how handlers fit in the pipeline
- [The Formatter](../concepts/formatter.md)  how `{token}` substitution works
- [Writing a Custom Handler](custom.md)  build your own
