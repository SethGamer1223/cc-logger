# Writing a Custom Handler

A handler just needs three methods to work with `Logger:addHandler()`:

| Method | Signature | Purpose |
|--------|-----------|---------|
| `:handle` | `(msg, extra, level)` | Produce output |
| `:format` | `(msg, extra)` → `string` | Apply template substitution (optional for raw handlers) |
| `:addTo` | `(logger)` | Register with a logger |

## Minimal Shape

```lua
local MyHandler = {}

function MyHandler.new(formatter)
    local self = {}

    self.formatter = formatter or logger.Formatter()

    function self:format(msg, extra)
        if not extra.asctime then
            extra.asctime = os.date(self.formatter.datefmt)
        end
        local formatted = self.formatter.fmt
        formatted = formatted:gsub("{message}", tostring(message))
        for k, v in pairs(extra) do
            formatted = formatted:gsub("{" .. k .. "}", tostring(v))
        end
        return formatted
    end

    function self:handle(msg, extra, level)
        -- Your output logic here
    end

    function self:addTo(logger)
        table.insert(logger.handlers, self)
    end

    return self
end
```

## Worked Example: Discord Webhook via `http.post`

This handler sends each log line as a Discord embed using an `http.post` request:

```lua
local logger = dofile("logger.lua")

local DiscordHandler = {}

function DiscordHandler.new(webhookUrl, formatter)
    local self = {}

    self.url = webhookUrl
    self.formatter = formatter or logger.Formatter()

    -- Color mapping for Discord embed side-bar
    local embedColors = {
        DEBUG    = 0x555555,
        INFO     = 0x00AA00,
        WARNING  = 0xFFAA00,
        ERROR    = 0xAA0000,
        CRITICAL = 0xAA00AA,
    }

    function self:format(msg, extra)
        if not extra.asctime then
            extra.asctime = os.date(self.formatter.datefmt)
        end
        local formatted = self.formatter.fmt
        for k, v in pairs(extra) do
            formatted = formatted:gsub("{" .. k .. "}", tostring(v))
        end
        return formatted
    end

    function self:handle(msg, extra, level)
        local text = self:format(msg, extra)
        local levelName = level and level[2] or "UNKNOWN"
        local color = embedColors[levelName] or 0x000000

        local payload = textutils.serializeJSON({
            embeds = {{
                description = text,
                color = color,
                footer = { text = levelName },
                timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ")
            }}
        })

        http.post(self.url, payload, {
            ["Content-Type"] = "application/json"
        })
    end

    function self:addTo(logger)
        table.insert(logger.handlers, self)
    end

    return self
end

-- Usage
local webhook = "https://discord.com/api/webhooks/your-id/your-token"
local h = DiscordHandler.new(webhook)
local log = logger.new("server")
log:addHandler(h)

log:critical("Server room on fire") 
```

## Raw Handlers

A handler that doesn't use a formatter can skip the `:format` method entirely:

```lua
function MyRawHandler:handle(msg, extra, level)
    -- send raw data
    modem.transmit(channel, channel, {msg, extra})
end
```

Both `RawWebsocketHandler` and `RawModemHandler` follow this pattern  they accept a
`formatter` parameter for API consistency but never call `:format()`.

## Related

- [Handlers Overview](index.md)  common interface and all built-in handlers
- [The Formatter](../concepts/formatter.md)  `{token}` substitution details
