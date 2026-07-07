# TimedRotatingFileHandler

Like [FileHandler](file.md), but rotates the log file at scheduled time intervals
(seconds, minutes, hours, days, or midnight).

```
TimedRotatingFileHandler(formatter, filename, when, interval, backupCount, delay, useUTC)
```

## Parameters

| Parameter     | Type            | Default              | Description                                    |
|---------------|-----------------|----------------------|------------------------------------------------|
| `formatter`   | `table`\|`nil`  | Copied from default  | Formatter for `{token}` substitution           |
| `filename`    | `string`        | *(required)*         | Path to the log file                           |
| `when`        | `string`\|`nil` | `"D"`                | Interval type (see table below)                |
| `interval`    | `number`\|`nil` | `1`                  | Number of `when` units between rotations       |
| `backupCount` | `number`\|`nil` | `0`                  | Number of old log files to keep (0 = unlimited)|
| `delay`       | `boolean`\|`nil`| `false`              | *(see notes  doesn't work as expected)*       |
| `useUTC`      | `boolean`\|`nil`| `false`              | Use UTC instead of local time                  |

## `when` Values

| Value       | Unit         | Notes                                      |
|-------------|--------------|--------------------------------------------|
| `"S"`       | Seconds      | 1000 ms intervals                          |
| `"M"`       | Minutes      | 60 000 ms intervals                        |
| `"H"`       | Hours        | 3 600 000 ms intervals                     |
| `"D"`       | Days         | 86 400 000 ms intervals                    |
| `"midnight"`| Daily at midnight | Rotates at the next 00:00 local time   |

## Rotation Scheme

When `os.epoch("local") >= rollover_at`:

1. Close the current file.
2. Move `filename` → `filename.YYYY-MM-DD_HH-MM-SS`.
3. If `backupCount > 0`, delete the oldest matching backups so that at most
   `backupCount` rotated files remain.
4. Compute the next rollover time.

## Example: Rotate at Midnight, Keep 7 Backups

```lua
local logger = require("logger.lua")

local fmt = logger.Formatter("{asctime} [{level}] {message}")
local h = logger.TimedRotatingFileHandler(fmt, "server.log", "midnight", 1, 7)
local log = logger.new("server", true)
log:addHandler(h)

log:info("Server started -- will rotate at midnight")
```

After a week you'd see:

```
server.log
server.log.2026-07-07_00-00-00
server.log.2026-07-06_00-00-00
server.log.2026-07-05_00-00-00
...
server.log.2026-06-30_00-00-00   ← 8th oldest, deleted
```

## Example: Rotate Every 30 Minutes

```lua
local h = logger.TimedRotatingFileHandler(nil, "quicklog.log", "M", 30, 10)
local log = logger.new("monitor", true)
log:addHandler(h)

log:info("Monitoring temp every 30-min cycle")
```

Rollover filenames look like `quicklog.log.2026-07-06_14-30-00`.

## Known Issues

!!! warning "`delay` parameter has no effect"

    In the current source, `TimedRotatingFileHandler` always opens the file on every
    `:handle()` call regardless of the `delay` flag.  See [Known Quirks](../known-quirks.md).

!!! warning "Backup filenames include timestamps"

    Unlike `RotatingFileHandler` (which uses `.1`, `.2`, ...), this handler appends a
    human-readable timestamp to the filename. The backup matching pattern is
    `base..+` (filename followed by a dot and anything), so other files with dots in
    the same directory could be caught by the cleanup logic.

## Related

- [RotatingFileHandler](rotating-file.md)  size-based rotation
- [FileHandler](file.md)  plain file writing
