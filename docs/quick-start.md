# Quick Start

Get a working logger in under two minutes.

## 1. Install

On your ComputerCraft computer, run:

```lua
wget https://raw.githubusercontent.com/SethGamer1223/cc-logger/main/logger.lua
```



## 2. Minimal Logger

Create a file `test-logger.lua`:

```lua
local logger = require("logger.lua")

-- Create a logger named test
local log = logger.new("test")

-- Log messages at each level
log:debug("Debug info")       -- doesnt show (default logging level is INFO)
log:info("System ready")
log:warn("Low memory")
log:error("Disk write failed")
log:critical("REACTOR MELTDOWN")
```

outputs:

```
[test] 2026/07/06 14:30:01 [INFO] System ready
[test] 2026/07/06 14:30:01 [WARNING] Low memory
[test] 2026/07/06 14:30:01 [ERROR] Disk write failed
[test] 2026/07/06 14:30:01 [CRITICAL] REACTOR MELTDOWN
```

The `DEBUG` line is silent because the default minimum level is `INFO`.
The default [Formatter](concepts/formatter.md) produces the `[name] timestamp [LEVEL] message` pattern above.

## 3. What's Next

- [Architecture Overview](concepts/architecture.md) understand Logger → Handler → Formatter
- [Log Levels](concepts/levels.md)  `setLevel`, `isEnabledFor`, and numeric weights
- [Handlers](handlers/index.md)  send logs to files, modems, websockets, and more
