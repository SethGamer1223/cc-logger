# WebsocketHandler / RawWebsocketHandler

Send log messages to a remote server over a ComputerCraft websocket.

## WebsocketHandler

Sends the **formatted string** over the websocket.

```
WebsocketHandler(formatter, websocket)
```

| Parameter   | Type            | Default              | Description                              |
|-------------|-----------------|----------------------|------------------------------------------|
| `formatter` | `table`\|`nil`  | Copied from default  | Formatter for `{token}` substitution     |
| `websocket` | `table`         | *(required)*         | An open websocket from `http.websocket()`|

## RawWebsocketHandler

Sends a **JSON-serialized table** `[message, extra]` over the websocket. No formatter
is applied.

```
RawWebsocketHandler(formatter, websocket)
```

| Parameter   | Type            | Description                                       |
|-------------|-----------------|---------------------------------------------------|
| `formatter` | `any`           | Ignored (the constructor accepts it but never uses it) |
| `websocket` | `table`         | An open websocket from `http.websocket()`          |

## Example: Both Handlers Side by Side

```lua
local logger = require("logger.lua")

-- Establish a websocket connection
local ws, err = http.websocket("ws://logserver.example.com/ingest")
if not ws then
    error("Websocket failed: " .. err)
end

local log = logger.new("client", true)

-- Formatted (human-readable) feed
local wsHandler = logger.WebsocketHandler(nil, ws)
log:addHandler(wsHandler)

-- Raw JSON feed for programmatic parsing
local rawHandler = logger.RawWebsocketHandler(nil, ws)
log:addHandler(rawHandler)

log:info("Client connected", { computerID = os.getComputerID() })
```

On the server side, you would receive two messages for each log call:

```
# From WebsocketHandler:
[client] 2026/07/06 14:30:01 [INFO] Client connected

# From RawWebsocketHandler:
{"Computer 1234","Client connected"}
```

!!! tip "Raw handler JSON format"

    `RawWebsocketHandler` sends `textutils.serializeJSON({log, extra})`, producing an
    array `[message, extra_object]`. The `extra` table includes the auto-populated
    keys (`message`, `level`, `loggername`, `asctime`) plus any custom keys you added.

## Notes

- Neither handler validates that the `websocket` argument is a real websocket object.
  A bad object will error inside `:handle()`.
- The websocket must already be open  the library does not manage connection lifecycle.

## Related

- [ModemHandler / RawModemHandler](modem.md)  network logging over rednet

