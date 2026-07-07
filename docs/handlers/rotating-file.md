# RotatingFileHandler

Like [FileHandler](file.md), but automatically rotates the log file when it exceeds a
size threshold, keeping a configurable number of backup files.

```
RotatingFileHandler(formatter, filename, maxByte, backupCount, mode, delay)
```

## Parameters

| Parameter     | Type            | Default              | Description                                    |
|---------------|-----------------|----------------------|------------------------------------------------|
| `formatter`   | `table`\|`nil`  | Copied from default  | Formatter for `{token}` substitution           |
| `filename`    | `string`        | *(required)*         | Path to the log file                           |
| `maxByte`     | `number`        | *(required)*         | Maximum size in bytes before rotation triggers |
| `backupCount` | `number`        | *(required)*         | Number of old log files to retain (must be > 0 for rotation) |
| `mode`        | `string`\|`nil` | `"a"`                | File open mode                                 |
| `delay`       | `boolean`\|`nil`| `false`              | If `true`, defers file open until first write  |

## Rotation Scheme

When `self.length + #newLine >= maxByte`:

1. Close current file.
2. Delete `filename.N` (the oldest backup).
3. Shift `filename.(N-1)` → `filename.N`, ..., `filename.1` → `filename.2`.
4. Rename current `filename` → `filename.1`.
5. Open fresh `filename` and reset length counter.

So with `backupCount = 3`, after several rotations you might see:

```
log.txt       ← currently being written
log.txt.1     ← most recent full file
log.txt.2
log.txt.3     ← oldest
```

## Important: `backupCount` Must Be > 0

The rotation check is guarded by `if maxByte and backupCount and backupCount > 0`.
If `backupCount` is 0 or `nil`, **rotation never happens** and the handler behaves
like a plain `FileHandler`.

## Example: 8 KB Cap with 3 Backups

```lua
local logger = require("logger.lua")

local fmt = logger.Formatter("{asctime} [{level}] {message}")
local h = logger.RotatingFileHandler(fmt, "turtle.log", 8192, 3)
local log = logger.new("turtle", true)
log:addHandler(h)

for i = 1, 500 do
    log:info("Mined block #" .. i)
end
-- File at most ~8 KB; up to 3 old logs preserved as turtle.log.1, .2, .3
```

## Detecting Existing File Size

On construction, if the file already exists, the handler reads its length via
`fileReader:seek("end")` so the size cap is enforced across restarts.

## Notes

- `maxByte` is compared against a running `self.length` counter that tracks total
  written bytes, **not** the filesystem-reported file size (except on initial load).
- The `.1` suffix is always the most recently rotated file.

## Related

- [FileHandler](file.md)  simpler file logging without rotation
- [TimedRotatingFileHandler](timed-rotating-file.md)  time-based rotation
- [Rotating Logs on Turtles](../cookbook/rotating-turtle-logs.md)  real-world turtle example
