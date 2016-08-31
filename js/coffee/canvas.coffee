mouseDown = 0;
document.body.onmousedown = () ->
  ++mouseDown;

document.body.onmouseup = () ->
  --mouseDown;



lineWidth = 3
lineColor = "rgba(0,0,0,1)"
drawing = false
paths = []
pathPushTime = new Date().getTime()

draw = () ->
  ctx.lineWidth = lineWidth
  ctx.fillStyle = lineColor
  first = paths.shift()
  ctx.moveTo(first.x, first.y)
  for path in paths
    ctx.lineTo(path.x, path.y)
    ctx.stroke()
  paths = []
  
move = (e) ->
  if mouseDown > 0
    if drawing == false
      drawing = true
      paths = []
    X = e.pageX - canvas.offsetLeft
    Y = e.pageY - canvas.offsetTop
    c = canvas.getBoundingClientRect()
    px = (X / c.width) * 100
    py = (Y / c.height) * 100
    paths.push({x: px, y: py})
    if paths.length > 1
      draw()
  

initCanvas = () ->
    canvas = get('doodlecanvas')
    ctx = canvas.getContext("2d")
    canvas.addEventListener('mousemove', move)