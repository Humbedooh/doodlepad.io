connected = false
logbuffer = []
# Establish websocket connection
ws = new WebSocket("wss://doodlepad.io/api/writer.lua")

# onopen: set connected var to true (means we get to send stuff)
ws.onopen = () ->
    logbuffer.push("Connection established")
    connected = true
    
# onerror: set connected to false
ws.onerror = (err) ->
    logbuffer.push("Connection error: " + err)
    connected = false
    
# onclose: clean shutdown
ws.onclose = () ->
    logbuffer.push("Connection closed")
    connected = false
    
# onmessage: responses from the server
ws.onmessage = (event) ->
    msg = JSON.parse(event.data)
    if msg.command == 'draw'
        if msg.tool == 'pencil'
            console.log("Got foreign pencil command")
            pencil(msg)

fetchNews = () ->
    ws.send('{"command": "fetch"}')
    
window.setInterval(fetchNews, 2000)
