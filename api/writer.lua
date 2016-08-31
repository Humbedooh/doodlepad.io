local JSON = require 'cjson'
local elastic = require 'elastic'

function handle(r)
    -- check for websocket upgrade
    if r:wsupgrade() then
        -- Then, we'll write something to the client:
        r:wswrite(JSON.encode({okay = true}))
        
        while true do
            -- Receive a line (frame) from the client:
            local line = r:wsread() or "{}"
            
            -- decode the JSON received
            local js = JSON.decode(line)
            
            -- execute command
            if js and js.command then
                if js.command == 'draw' and js.pad then
                    local doc = {
                        pad = js.pad,
                        color = js.color or "rgba(0,0,0,1)",
                        fill = js.fill or "rgba(0,0,0,0)",
                        tool = "pencil",
                        path = js.path or {}
                    }
                    elastic.index(r, nil, 'draw', doc)
                    r:wswrite(JSON.encode{okay = true, message = "command saved"})
                end
            else
                -- check if client disconnected?
                if not r:wsping() then
                    break
                end
            end
        end
        r:wsclose()
    end
end