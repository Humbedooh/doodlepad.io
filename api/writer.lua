local JSON = require 'cjson'
local elastic = require 'elastic'

function handle(r)
    -- check for websocket upgrade
    if r:wsupgrade() then
        -- Then, we'll write something to the client:
        r:wswrite(JSON.encode({okay = true}))
        local wid = r:sha1(math.random(1,99999999) .. r.clock() .. r.useragent_ip)
        local last = 0
        
        while true do
            -- Receive a line (frame) from the client:
            local line = r:wsread() or "{}"
            
            -- decode the JSON received
            local js = JSON.decode(line)
            
            -- execute command
            if js and js.command then
                js.pad = js.pad or 'default'
                
                if js.command == 'draw' and js.pad then
                    local doc = {
                        pad = js.pad,
                        color = js.color or "rgba(0,0,0,1)",
                        fill = js.fill or "rgba(0,0,0,0)",
                        width = js.width or 1,
                        tool = "pencil",
                        path = js.path or {},
                        timestamp = r.clock(),
                        writer = wid
                    }
                    elastic.index(r, nil, 'draw', doc)
                    r:wswrite(JSON.encode{okay = true, message = "command saved"})
                end
                if js.command == 'fetch' then
                    local now = r.clock()
                    query = {
                        query = {
                            size = 1000,
                                bool = {
                                    must = {
                                        {
                                            term = {
                                                pad = js.pad
                                            }
                                        },
                                        {
                                            range = {
                                                    timestap = {
                                                        from = last,
                                                        to = now
                                                        }
                                                },
                                        },
                                    },
                                    must_not = {
                                        {
                                            term = {
                                                writer = wid
                                            }
                                        }
                                    }
                                }
                            }
                    }
                    last = now
                    local results = elastic.raw(query, 'draw')
                    for res in pairs(results.hits.hits) do
                        cmd = res._source
                        cmd.command = 'draw'
                        r:wswrite(cmd)
                    end
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