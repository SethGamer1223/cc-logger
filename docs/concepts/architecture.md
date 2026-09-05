# Architecture Overview

## Pipeline

Every log message flows through a three-stage pipeline:

```
 Logger                          Handler(s)                   Formatter
┌─────────────┐          ┌──────────────────┐          ┌──────────────────┐
│ log:info()  │  msg,    │  handler:handle  │  msg,    │  formatter:fmt   │
│ log:warn()  │ ──level──▶ (msg, extra,     │ ──extra──▶ + {token}        │
│ log:error() │  extra    │   level)         │          │  substitution    │
└─────────────┘          └───────┬──────────┘          └────────┬─────────┘
                                 │                              │
                                 │                     formatted string
                                 │                              │
                                 ▼                              ▼
                          Output device                Final output
                          (term, file,                  (written,
                           modem, ws, etc.)             transmitted, etc.)
```

A **Logger** holds a minimum level and a list of **Handler** objects. Each **Handler**
owns its own **Formatter**. When you call a logging method (e.g. `log:info(...)`):

1. `Logger:log()` builds an **extra** table with default keys (`message`, `level`,
   `loggername`).
2. For each handler, the effective threshold is the handler's own `level` if set,
   otherwise the logger's threshold.
3. If the message's level weight is below that handler's threshold, the handler is
   skipped. Otherwise its `:handle(msg, extra, level)` is called in sequence.
4. Each handler's `:format(msg, extra)` method substitutes `{token}` patterns using the
   extra table and returns a string. The handler then writes or transmits that string.

```lua
local logger = require("logger.lua")

local log = logger.new("multi")

--  colored terminal
local termH = logger.ColoredTerminalHandler()
log:addHandler(termH)

-- rotating file
local fileH = logger.RotatingFileHandler(
    logger.Formatter(),           -- default format
    "log.txt",                    -- filename
    4096,                         -- 4 KB max
    3                             -- 3 backups
)
log:addHandler(fileH)

log:info("Both handlers fire for this message")
```

Each handler may set its own minimum level with `:setLevel()`; by default all handlers
inherit the logger's level. See [Per-Handler Level Filtering](../handlers/index.md#per-handler-level-filtering).

!!! note "Default handler"

    `logger.new()` attaches a default `TerminalHandler(Formatter)` automatically.
    Pass `true` as the second argument to remove it: `logger.new("mine", true)`.

## Key Types

| Component     | Role | Created By |
|--------------|------|------------|
| **Logger**   | Holds default level, dispatches to handlers | `logger.new(name)` |
| **Handler**  | Receives `(msg, extra, level)`, formats & outputs; may override level with `:setLevel()` | `logger.Handler(...)` |
| **Formatter**| Holds template string & date format, does `{token}` substitution | `logger.Formatter(fmt, datefmt)` |
| **Level**    | A `{weight, name}` table, e.g. `{2, "INFO"}` | `logger.INFO`, etc. |

## Related

- [Log Levels](levels.md)  how level filtering works
- [The Formatter](formatter.md)  template syntax and date formatting
- [Handlers Overview](../handlers/index.md)  all built-in handlers
