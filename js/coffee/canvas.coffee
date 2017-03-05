mouseDown = 0;
isPad = false

document.body.ontouchstart =(e) ->
  isPad = true
  if drawing
    e.preventDefault()
  ++mouseDown;
  
document.body.onmousedown = (e) ->
  if not isPad
    ++mouseDown;
    
document.body.onmouseup = (e) ->
  if not isPad
    --mouseDown;
    if mouseDown <= 0
      drawing = false
      draw()
      paths = []

document.body.ontouchend = (e) ->
  if isPad
    --mouseDown;
    if mouseDown <= 0
      drawing = false
      draw()
      paths = []
    if drawing
      e.preventDefault()

doodlepad_pid = location.search.substr(1)
if doodlepad_pid.length < 2
    doodlepad_pid = parseInt(Math.random() * 999999999).toString(16)
    location.href = '?' + doodlepad_pid
    
canvas = null
ctx = null
lineWidth = 1.25
lineColor = "rgba(0,0,0,1)"
lineCap = 'round'
prevX = 0
prevY = 0
threshold = 0.005
drawing = false
paths = []
pathPushTime = new Date().getTime()
lastDraw = 0
memory = []

dataPaths = []

pushPaths = () ->
  js = {
    command: 'draw'
    fill: lineColor,
    color: lineColor,
    width: lineWidth,
    type: 'pencil',
    tool: 'pencil'
    path: dataPaths,
    pad: doodlepad_pid
  }
  if dataPaths.length > 0
    dp = JSON.stringify(js)
    memory.push(dp)
    dataPaths = []
    ws.send(dp)
  pathPushTime = new Date().getTime()


pencil = (cmd) ->
  for paths in cmd.path
    if paths.length > 1
      ctx.beginPath()
      ctx.lineCap = lineCap
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
    ctx.lineCap = lineCap
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
    lastDraw = now
    if (now - pathPushTime) > 1000 or dataPaths.length > 10
      pushPaths()
  
move = (e) ->
  e.preventDefault()
  if mouseDown > 0
    if drawing == false
      drawing = true
      paths = []
    if drawing
      now = new Date().getTime()
      c = canvas.getBoundingClientRect()
      pageX = e.pageX
      pageY = e.pageY
      if e.targetTouches
        X = e.targetTouches[0].pageX - c.left
        Y = e.targetTouches[0].pageY - c.top
      else
        X = pageX - c.left - document.body.scrollLeft
        Y = pageY - c.top - (window.pageYOffset || document.body.scrollTop)
      px = (X / c.width)
      py = (Y / c.height)
      if ((Math.abs(prevX-px)) + (Math.abs(prevY-py))) > threshold
        paths.push({x: px.toFixed(4), y: py.toFixed(4)})
        prevX = px
        prevY = py
        if paths.length > 1 and (now-lastDraw) > 100
          draw()
  else
    paths = []


sizeCanvas = () ->
    canvas = get('doodlecanvas')
    height = parseInt(window.innerHeight - 100)
    if height < 100
      height = 100
    width = height * 2
    canvas.setAttribute("width", width)
    canvas.setAttribute("height", height)
    
    ## Redraw
    for mem in memory
        pencil(JSON.parse(mem))
    
initCanvas = () ->
    canvas = get('doodlecanvas')
    window.onresize = sizeCanvas
    ctx = canvas.getContext("2d")
    canvas.addEventListener('mousemove', move)
    canvas.addEventListener('touchmove', move)
    sizeCanvas()
    
    
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