# Known Quirks & Limitations

This page documents real behaviors found in the code that may be unexpected

---

## Default Level Is `INFO`, Not Configurable at Construction

There is no way to set the initial level when calling `logger.new()`. The level is
always `logger.INFO`. To change it, you must call `:setLevel()` afterward:

```lua
local log = logger.new("app")
log:setLevel(logger.DEBUG)  -- explicit second step
```

---

## `RotatingFileHandler` Tracks Length In-Memory

The byte counter `self.length` is maintained in memory and seeded from the file's
`seek("end")` on construction. If another process writes to the same file, the in-memory
counter drifts from the real file size.
