# cc-logger

A **Python-[logging](https://docs.python.org/3/library/logging.html)-style** logger for [CC: Tweaked](https://tweaked.cc/),
written in pure Lua.  Install it with a single `wget`, then use `logger.new()` to get a
Logger that sends formatted messages to the terminal, files, modems, websockets, or 
custom handlers.

## Level Hierarchy

| Level     | Weight | Constant         |
|-----------|--------|------------------|
| `DEBUG`   | 1      | `logger.DEBUG`   |
| `INFO`    | 2      | `logger.INFO`    |
| `WARNING` | 3      | `logger.WARNING` |
| `ERROR`   | 4      | `logger.ERROR`   |
| `CRITICAL`| 5      | `logger.CRITICAL`|

Messages below the logger's current level are dropped silently. Default level is `INFO`.

## Install

```lua
wget https://raw.githubusercontent.com/SethGamer1223/cc-logger/main/logger.lua
```

## At a Glance

```lua
local logger = require("logger.lua")

local log = logger.new("myApp")
log:info("System started")
log:warn("Disk space low")
log:error("Something broke")
```

## Next Steps

- [Quick Start](quick-start.md) first logger 
- [Architecture Overview](concepts/architecture.md) how logger, handler, and formatter fit together
- [API Reference](api/logger.md) every function documented
- [Cookbook](cookbook/multi-handler.md)

## License

MIT  see [LICENSE](https://github.com/SethGamer1223/cc-logger/blob/main/LICENSE).
