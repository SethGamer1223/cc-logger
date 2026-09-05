# DiscordWebhookHandler

Sends formatted log messages to a Discord server through a
[webhook](https://support.discord.com/hc/en-us/articles/228383668-Intro-to-Webhooks).
Uses the `http` API, which must be enabled on the computer.

```
DiscordWebhookHandler(formatter, webhookURL, mode, advanced)
```

!!! warning "Performance"

    Every logged message triggers a separate HTTP request to Discord, which blocks
    until the request completes. This **slows down logging heavily**  only attach this
    handler for important logs (e.g. `ERROR`/`CRITICAL`), and consider using a
    different logger or handler level for high-frequency messages:

    ```lua
    local discord = logger.DiscordWebhookHandler(nil, webhook, "user")
    discord:setLevel(logger.ERROR)   -- only errors go to Discord
    log:addHandler(discord)
    ```

    See [Per-Handler Level Filtering](index.md#per-handler-level-filtering).

## Parameters

| Parameter    | Type             | Default             | Description                                              |
|--------------|------------------|---------------------|----------------------------------------------------------|
| `formatter`  | `table`\|`nil`  | Copied from default | Formatter used for `{token}` substitution                |
| `webhookURL` | `string`         | *(required)*        | The Discord webhook URL                                  |
| `mode`       | `string`\|`nil` | `"message"`         | `"message"` or `"user"` (see below)                     |
| `advanced`   | `boolean`\|`nil`| `nil` (off)         | Wrap the message in an ANSI-colored code block           |

## Modes

`mode` controls which fields are set on the webhook payload:

| Mode        | Behaviour                                                              |
|-------------|------------------------------------------------------------------------|
| `"message"` | Sends only `content`  the formatted log line.                         |
| `"user"`    | Sets `username` to the logger's name (`extra.loggername`).            |

## Advanced (ANSI) Formatting

When `advanced = true`, the message is wrapped in an ANSI code block
(` ```ansi ... ``` `) and colored using the level's `discordfg` value from the
Formatter's `colors` table:

| Level      | `discordfg` | Color   |
|------------|-------------|---------|
| `DEBUG`    | `34`        | blue    |
| `INFO`     | `37`        | white   |
| `WARNING`  | `33`        | yellow  |
| `ERROR`    | `31`        | red     |
| `CRITICAL` | `35`        | pink    |

## Example

```lua
local logger = require("logger.lua")

local webhook = "https://discord.com/api/webhooks/your-id/your-token"
local h = logger.DiscordWebhookHandler(nil, webhook, "user", true)
local log = logger.new("miner", true)
log:addHandler(h)

log:warn("Low fuel", { fuel = 5 })
log:error("Chest full")
```

## Notes

- Every message is sent with `http.post(...)` and the response is never read or
  checked. The request is synchronous and blocks until it completes.
- In `advanced` mode the handler looks up `formatter.colors[level].discordfg`. A level
  missing from the `colors` table (e.g. a custom level) will error inside `:handle()`
  unless you add a `discordfg` entry for it.
- Any `mode` other than `"user"` behaves like `"message"`.

## Related

- [The Formatter](../concepts/formatter.md)  the `colors` table including `discordfg`
- [Handlers Overview](index.md)  all built-in handlers