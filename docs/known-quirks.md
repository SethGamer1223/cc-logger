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

---

## `DiscordWebhookHandler` `advanced` Mode Requires a `discordfg` Color

In `advanced` mode the handler looks up `formatter.colors[extra.level].discordfg`.
Custom levels (or any Formatter whose `colors` table lacks the level) will **error**
inside `:handle()`:

```lua
local fmt = logger.Formatter()
fmt.colors = { INFO = { fg = colors.green } }  -- no discordfg

-- Errors when an INFO message arrives:
logger.DiscordWebhookHandler(fmt, webhookURL, "message", true)
```

Give each level you log a `discordfg` entry if you use `advanced` mode.

---

## `DiscordWebhookHandler` Ignores the Response

Every message is sent with `http.post(...)` and the response is never read. There is
no retry, no error check, and no feedback if the webhook rejects the message.
