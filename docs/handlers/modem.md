# ModemHandler / RawModemHandler

Transmit log messages over a ComputerCraft modem (wired or wireless). Useful for
aggregating logs from multiple computers onto a central logging server.

## ModemHandler

Transmits the **formatted string** on a specified channel.

```
ModemHandler(formatter, modem, channel)
```

| Parameter   | Type            | Default              | Description                             |
|-------------|-----------------|----------------------|-----------------------------------------|
| `formatter` | `table`\|`nil`  | Copied from default  | Formatter for `{token}` substitution    |
| `modem`     | `table`         | *(required)*         | A wrapped modem peripheral              |
| `channel`   | `number`        | *(required)*         | Channel to transmit on                  |

## RawModemHandler

Transmits the raw **Lua table** `{msg, extra}`  no formatter applied. The receiving
end can inspect the full structured data.

```
RawModemHandler(formatter, modem, channel)
```

| Parameter   | Type            | Description                                       |
|-------------|-----------------|---------------------------------------------------|
| `formatter` | `any`           | Ignored (accepted but never used)                  |
| `modem`     | `table`         | A wrapped modem peripheral                         |
| `channel`   | `number`        | Channel to transmit on                             |

## Example: Wireless Logger

**Transmitter (mining turtle):**

```lua
local logger = require("logger.lua")

local modem = peripheral.wrap("top")
local fmt = logger.Formatter("[{loggername}] {message}")

local h = logger.ModemHandler(fmt, modem, 42)
local log = logger.new("turtle1", true)
log:addHandler(h)

log:info("Starting mining operation")
```

**Receiver (central computer):**

```lua
local modem = peripheral.wrap("back")
modem.open(42)

while true do
    local event, side, channel, replyChannel, message, distance = os.pullEvent("modem_message")
    if channel == 42 then
        print("Received: " .. message)
    end
end
```

## Example: Raw Modem with Structured Data

```lua
local logger = require("logger.lua")

local modem = peripheral.wrap("right")
local h = logger.RawModemHandler(nil, modem, 99)
local log = logger.new("sensor", true)
log:addHandler(h)

log:info("Temperature spike", { temp = 87.3, tank = "reactor_1" })
-- Transmits: {"Temperature spike", {message="Temperature spike", level="INFO",
--              loggername="sensor", temp=87.3, tank="reactor_1"}}
```

Receiving side:

```lua
local modem = peripheral.wrap("left")
modem.open(99)

while true do
    local _, _, channel, _, data = os.pullEvent("modem_message")
    if channel == 99 then
        local msg = data[1]
        local extra = data[2]
        print(("%s [%s] %s"):format(extra.loggername, extra.level, msg))
        if extra.temp then
            print("  Temperature: " .. extra.temp)
        end
    end
end
```

## Notes

- The `modem` must already be a wrapped peripheral object  the handler does not call
  `peripheral.wrap()` for you.
- No validation is performed on the modem object; a bad reference errors inside
  `:handle()`.

## Related

- [WebsocketHandler / RawWebsocketHandler](websocket.md)  network logging over websockets
