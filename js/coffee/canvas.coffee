mouseDown = 0;
document.body.onmousedown = (e) ->
  ++mouseDown;
    
document.body.onmouseup = (e) ->
  --mouseDown;
  if mouseDown <= 0
    drawing = false
    draw()
    paths = []

doodlepad_pid = location.search.substr(1)
if doodlepad_pid.length < 2
    doodlepad_pid = parseInt(Math.random() * 999999999).toString(16)
    location.href = '?' + doodlepad_pid
    
canvas = null
ctx = null
lineWidth = 1.25
lineColor = "rgba(0,0,0,1)"
prevX = 0
prevY = 0
threshold = 0.0075
drawing = false
paths = []
pathPushTime = new Date().getTime()

dataPaths = []

pushPaths = () ->
  js = {
    command: 'draw'
    fill: lineColor,
    color: lineColor,
    width: lineWidth,
    type: 'pencil',
    path: dataPaths,
    pad: doodlepad_pid
  }
  if dataPaths.length > 0
    dp = JSON.stringify(js)
    dataPaths = []
    ws.send(dp)
  pathPushTime = new Date().getTime()


pencil = (cmd) ->
  for paths in cmd.path
    if paths.length > 1
      ctx.beginPath()
      ctx.lineWidth = cmd.width
      ctx.fillStyle = cmd.fill
      ctx.strokeStyle = cmd.color
      first = paths.shift()
      c = canvas.getBoundingClientRect()
      ctx.moveTo(first.x*c.width, first.y*c.height)
      for path in paths
        ctx.lineTo(path.x*c.width, path.y*c.height)
        ctx.stroke()


draw = () ->
  if paths.length > 1
    ctx.beginPath()
    ctx.lineWidth = lineWidth
    ctx.strokeStyle = lineColor
    first = paths.shift()
    c = canvas.getBoundingClientRect()
    ppath = [first]
    ctx.moveTo(first.x*c.width, first.y*c.height)
    for path in paths
      ctx.lineTo(path.x*c.width, path.y*c.height)
      ppath.push(path)
      #alert(path.x*c.width)
      ctx.stroke()
    dataPaths.push(ppath)
    paths = [paths[paths.length-1]]

    now = new Date().getTime()
    if (now - pathPushTime) > 250 or dataPaths.length > 10
      pushPaths()
  
move = (e) ->
  if mouseDown > 0
    if drawing == false
      drawing = true
      paths = []
    if drawing
      c = canvas.getBoundingClientRect()
      X = e.pageX - c.left + document.body.scrollLeft
      Y = e.pageY - c.top + document.body.scrollTop
      px = (X / c.width)
      py = (Y / c.height)
      if ((Math.abs(prevX-px)) + (Math.abs(prevY-py))) > threshold
        paths.push({x: px.toFixed(5), y: py.toFixed(5)})
        prevX = px
        prevY = py
        if paths.length > 1
          draw()
  else
    paths = []

initCanvas = () ->
    canvas = get('doodlecanvas')
    ctx = canvas.getContext("2d")
    canvas.addEventListener('mousemove', move)
    
setColor = (picker) ->
    pushPaths()
    get('color').value = picker.toHEXString()
    a = picker.rgb
    r = parseInt(a[0])
    g = parseInt(a[1])
    b = parseInt(a[2])
    lineColor = "rgba(#{r}, #{g}, #{b}, 1)"
    console.log(lineColor)
    
    
download = () ->
    dt = canvas.toDataURL('image/png')
    location.href = dt