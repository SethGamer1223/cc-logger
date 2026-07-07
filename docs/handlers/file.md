# FileHandler

Writes formatted log lines to a file on the computer's filesystem.

```
FileHandler(formatter, filename, mode, delay)
```

## Parameters

| Parameter   | Type            | Default              | Description                                    |
|-------------|-----------------|----------------------|------------------------------------------------|
| `formatter` | `table`\|`nil`  | Copied from default  | Formatter for `{token}` substitution           |
| `filename`  | `string`        | *(required)*         | Path to the log file                           |
| `mode`      | `string`\|`nil` | `"a"`                | File open mode (`"a"` for append, `"w"` for write) |
| `delay`     | `boolean`\|`nil`| `false`              | If `true`, file is not opened until first write |

## Example: Crash Log

```lua
local logger = dofile("logger.lua")

local fmt = logger.Formatter("{asctime} [{level}] {message}")
local h = logger.FileHandler(fmt, "crash.log", "a", true)
local log = logger.new("app", true)

log:addHandler(h)

-- Simulate a crash sequence
log:error("Unhandled exception in render loop")
log:error("Stack traceback: [redacted]")
```

The file `crash.log` will contain:

```
2026/07/06 14:30:01 [ERROR] Unhandled exception in render loop
2026/07/06 14:30:01 [ERROR] Stack traceback: [redacted]
```

## Using the Same File Across Restarts

With `mode = "a"` (the default), each run appends to the file:

```lua
local h = logger.FileHandler(nil, "server.log")
```

With `mode = "w"`, the file is truncated each time the handler is constructed (or on
first write if `delay` is true):

```lua
local h = logger.FileHandler(nil, "session.log", "w")
```

## Notes

- If `delay` is `true`, the file handle is opened lazily on the first `:handle()` call.
  Useful when you construct the handler early but don't want a file descriptor sitting
  open.
- The `mode` parameter is **not validated** by the handler  see [Known Quirks](../known-quirks.md)
  for details.
- Each call to `:handle()` opens the file (if not already open), writes, and keeps the
  file handle open. Close is only explicit (e.g. via a `RotatingFileHandler` rotation).

## Related

- [RotatingFileHandler](rotating-file.md)  size-based log rotation
- [TimedRotatingFileHandler](timed-rotating-file.md)  time-based log rotation
- [Formatter](../concepts/formatter.md)  format tokens
