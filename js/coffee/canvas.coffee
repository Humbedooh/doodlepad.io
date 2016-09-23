mouseDown = 0;
document.body.onmousedown = (e) ->
  ++mouseDown;
    
document.body.onmouseup = (e) ->
  --mouseDown;
  if mouseDown <= 0
    drawing = false
    draw()
    paths = []

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
    type: 'pencil',
    path: dataPaths,
    pad: 'default'
  }
  dp = JSON.stringify(js)
  dataPaths = []
  ws.send(dp)
  console.log(dp)
  

draw = () ->
  ctx.lineWidth = lineWidth
  ctx.fillStyle = lineColor
  if paths.length > 1
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
      pathPushTime = now
  
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