// Generated by CoffeeScript 1.9.3
var API, app, canvas, cog, connected, ctx, dataPaths, draw, drawing, e, fetch, genColors, get, globArgs, hsl2rgb, initCanvas, isArray, lineColor, lineWidth, logbuffer, mk, mouseDown, move, pathPushTime, paths, post, postJSON, prevX, prevY, pushPaths, set, snoot_sidebar, snoot_sidebar_hide, ssh, swi, theme, threshold, txt, ws;

mouseDown = 0;

document.body.onmousedown = function(e) {
  return ++mouseDown;
};

document.body.onmouseup = function(e) {
  var drawing, paths;
  --mouseDown;
  if (mouseDown <= 0) {
    drawing = false;
    draw();
    return paths = [];
  }
};

canvas = null;

ctx = null;

lineWidth = 1.25;

lineColor = "rgba(0,0,0,1)";

prevX = 0;

prevY = 0;

threshold = 0.0075;

drawing = false;

paths = [];

pathPushTime = new Date().getTime();

dataPaths = [];

pushPaths = function() {
  var dp, js;
  js = {
    command: 'draw',
    fill: lineColor,
    color: lineColor,
    type: 'pencil',
    path: dataPaths,
    pad: 'default'
  };
  dp = JSON.stringify(js);
  dataPaths = [];
  ws.send(dp);
  return console.log(dp);
};

draw = function() {
  var c, first, j, len, now, path, ppath;
  ctx.lineWidth = lineWidth;
  ctx.fillStyle = lineColor;
  if (paths.length > 1) {
    first = paths.shift();
    c = canvas.getBoundingClientRect();
    ppath = [first];
    ctx.moveTo(first.x * c.width, first.y * c.height);
    for (j = 0, len = paths.length; j < len; j++) {
      path = paths[j];
      ctx.lineTo(path.x * c.width, path.y * c.height);
      ppath.push(path);
      ctx.stroke();
    }
    dataPaths.push(ppath);
    paths = [paths[paths.length - 1]];
    now = new Date().getTime();
    if ((now - pathPushTime) > 250 || dataPaths.length > 10) {
      pushPaths();
      return pathPushTime = now;
    }
  }
};

move = function(e) {
  var X, Y, c, px, py;
  if (mouseDown > 0) {
    if (drawing === false) {
      drawing = true;
      paths = [];
    }
    if (drawing) {
      c = canvas.getBoundingClientRect();
      X = e.pageX - c.left + document.body.scrollLeft;
      Y = e.pageY - c.top + document.body.scrollTop;
      px = X / c.width;
      py = Y / c.height;
      if (((Math.abs(prevX - px)) + (Math.abs(prevY - py))) > threshold) {
        paths.push({
          x: px.toFixed(5),
          y: py.toFixed(5)
        });
        prevX = px;
        prevY = py;
        if (paths.length > 1) {
          return draw();
        }
      }
    }
  } else {
    return paths = [];
  }
};

initCanvas = function() {
  canvas = get('doodlecanvas');
  ctx = canvas.getContext("2d");
  return canvas.addEventListener('mousemove', move);
};

hsl2rgb = function(h, s, l) {
  var fract, min, sh, sv, switcher, v, vsf;
  h = h % 1;
  if (s > 1) {
    s = 1;
  }
  if (l > 1) {
    l = 1;
  }
  if (l <= 0.5) {
    v = l * (1 + s);
  } else {
    v = l + s - l * s;
  }
  if (v === 0) {
    return {
      r: 0,
      g: 0,
      b: 0
    };
  }
  min = 2 * l - v;
  sv = (v - min) / v;
  sh = (6 * h) % 6;
  switcher = Math.floor(sh);
  fract = sh - switcher;
  vsf = v * sv * fract;
  switch (switcher) {
    case 0:
      return {
        r: v,
        g: min + vsf,
        b: min
      };
    case 1:
      return {
        r: v - vsf,
        g: v,
        b: min
      };
    case 2:
      return {
        r: min,
        g: v,
        b: min + vsf
      };
    case 3:
      return {
        r: min,
        g: v - vsf,
        b: v
      };
    case 4:
      return {
        r: min + vsf,
        g: min,
        b: v
      };
    case 5:
      return {
        r: v,
        g: min,
        b: v - vsf
      };
  }
  return {
    r: 0,
    g: 0,
    b: 0
  };
};

genColors = function(numColors, saturation, lightness, hex) {
  var baseHue, c, cls, h, i, j, ref;
  cls = [];
  baseHue = 1.34;
  for (i = j = 1, ref = numColors; 1 <= ref ? j <= ref : j >= ref; i = 1 <= ref ? ++j : --j) {
    c = hsl2rgb(baseHue, saturation, lightness);
    if (hex) {
      h = (Math.round(c.r * 255 * 255 * 255) + Math.round(c.g * 255 * 255) + Math.round(c.b * 255)).toString(16);
      while (h.length < 6) {
        h = '0' + h;
      }
      h = '#' + h;
      cls.push(h);
    } else {
      cls.push({
        r: parseInt(c.r * 255),
        g: parseInt(c.g * 255),
        b: parseInt(c.b * 255)
      });
    }
    baseHue -= 0.23;
    if (baseHue < 0) {
      baseHue += 1;
    }
  }
  return cls;
};

API = 2;

Number.prototype.pretty = function(fix) {
  if (fix) {
    return String(this.toFixed(fix)).replace(/(\d)(?=(\d{3})+\.)/g, '$1,');
  }
  return String(this.toFixed(0)).replace(/(\d)(?=(\d{3})+$)/g, '$1,');
};

fetch = function(url, xstate, callback, snap, nocreds) {
  var xmlHttp;
  xmlHttp = null;
  if (window.XMLHttpRequest) {
    xmlHttp = new XMLHttpRequest();
  } else {
    xmlHttp = new ActiveXObject("Microsoft.XMLHTTP");
  }
  if (!nocreds) {
    xmlHttp.withCredentials = true;
  }
  xmlHttp.open("GET", "https://api.snoot.io" + url, true);
  xmlHttp.send(null);
  return xmlHttp.onreadystatechange = function(state) {
    var e, response;
    if (xmlHttp.readyState === 4 && xmlHttp.status === 500) {
      if (snap) {
        snap(xstate);
      }
    }
    if (xmlHttp.readyState === 4 && xmlHttp.status === 200) {
      if (callback) {
        try {
          response = JSON.parse(xmlHttp.responseText);
          if (response && response.loginRequired) {
            location.href = "/login.html";
            return;
          }
          return callback(response, xstate);
        } catch (_error) {
          e = _error;
          return callback(JSON.parse(xmlHttp.responseText), xstate);
        }
      }
    }
  };
};

post = function(url, args, xstate, callback, snap) {
  var ar, fdata, k, v, xmlHttp;
  xmlHttp = null;
  if (window.XMLHttpRequest) {
    xmlHttp = new XMLHttpRequest();
  } else {
    xmlHttp = new ActiveXObject("Microsoft.XMLHTTP");
  }
  xmlHttp.withCredentials = true;
  ar = [];
  for (k in args) {
    v = args[k];
    if (v && v !== "") {
      ar.push(k + "=" + encodeURIComponent(v));
    }
  }
  fdata = ar.join("&");
  xmlHttp.open("POST", "https://api.snoot.io" + url, true);
  xmlHttp.setRequestHeader("Content-type", "application/x-www-form-urlencoded");
  xmlHttp.send(fdata);
  return xmlHttp.onreadystatechange = function(state) {
    var e, response;
    if (xmlHttp.readyState === 4 && xmlHttp.status === 500) {
      if (snap) {
        snap(xstate);
      }
    }
    if (xmlHttp.readyState === 4 && xmlHttp.status === 200) {
      if (callback) {
        try {
          response = JSON.parse(xmlHttp.responseText);
          return callback(response, xstate);
        } catch (_error) {
          e = _error;
          return callback(JSON.parse(xmlHttp.responseText), xstate);
        }
      }
    }
  };
};

postJSON = function(url, json, xstate, callback, snap) {
  var fdata, xmlHttp;
  xmlHttp = null;
  if (window.XMLHttpRequest) {
    xmlHttp = new XMLHttpRequest();
  } else {
    xmlHttp = new ActiveXObject("Microsoft.XMLHTTP");
  }
  xmlHttp.withCredentials = true;
  fdata = JSON.stringify(json);
  xmlHttp.open("POST", "https://api.snoot.io" + url, true);
  xmlHttp.setRequestHeader("Content-type", "application/json");
  xmlHttp.send(fdata);
  return xmlHttp.onreadystatechange = function(state) {
    var e, response;
    if (xmlHttp.readyState === 4 && xmlHttp.status === 500) {
      if (snap) {
        snap(xstate);
      }
    }
    if (xmlHttp.readyState === 4 && xmlHttp.status === 200) {
      if (callback) {
        try {
          response = JSON.parse(xmlHttp.responseText);
          return callback(response, xstate);
        } catch (_error) {
          e = _error;
          return callback(JSON.parse(xmlHttp.responseText), xstate);
        }
      }
    }
  };
};

mk = function(t, s, tt) {
  var j, k, len, r, v;
  r = document.createElement(t);
  if (s) {
    for (k in s) {
      v = s[k];
      if (v) {
        r.setAttribute(k, v);
      }
    }
  }
  if (tt) {
    if (typeof tt === "string") {
      app(r, txt(tt));
    } else {
      if (isArray(tt)) {
        for (j = 0, len = tt.length; j < len; j++) {
          k = tt[j];
          if (typeof k === "string") {
            app(r, txt(k));
          } else {
            app(r, k);
          }
        }
      } else {
        app(r, tt);
      }
    }
  }
  return r;
};

app = function(a, b) {
  var item, j, len, results;
  if (isArray(b)) {
    results = [];
    for (j = 0, len = b.length; j < len; j++) {
      item = b[j];
      if (typeof item === "string") {
        item = txt(item);
      }
      results.push(a.appendChild(item));
    }
    return results;
  } else {
    return a.appendChild(b);
  }
};

set = function(a, b, c) {
  return a.setAttribute(b, c);
};

txt = function(a) {
  return document.createTextNode(a);
};

get = function(a) {
  return document.getElementById(a);
};

swi = function(obj) {
  var switchery;
  return switchery = new Switchery(obj, {
    color: '#26B99A'
  });
};

cog = function(div, size) {
  var i, idiv;
  if (size == null) {
    size = 200;
  }
  idiv = document.createElement('div');
  idiv.setAttribute("class", "icon");
  idiv.setAttribute("style", "text-align: center; vertical-align: middle; height: 500px;");
  i = document.createElement('i');
  i.setAttribute("class", "fa fa-spin fa-cog");
  i.setAttribute("style", "font-size: " + size + "pt !important; color: #AAB;");
  idiv.appendChild(i);
  idiv.appendChild(document.createElement('br'));
  idiv.appendChild(document.createTextNode('Loading, hang on tight..!'));
  div.innerHTML = "";
  return div.appendChild(idiv);
};

globArgs = {};

theme = {
  color: [],
  title: {
    itemGap: 8,
    textStyle: {
      fontWeight: 'normal',
      color: '#408829'
    }
  },
  dataRange: {
    color: ['#1f610a', '#97b58d']
  },
  toolbox: {
    color: ['#408829', '#408829', '#408829', '#408829']
  },
  tooltip: {
    backgroundColor: 'rgba(0,0,0,0.5)',
    axisPointer: {
      type: 'line',
      lineStyle: {
        color: '#408829',
        type: 'dashed'
      },
      crossStyle: {
        color: '#408829'
      },
      shadowStyle: {
        color: 'rgba(200,200,200,0.3)'
      }
    }
  },
  dataZoom: {
    dataBackgroundColor: '#eee',
    fillerColor: 'rgba(64,136,41,0.2)',
    handleColor: '#408829'
  },
  grid: {
    borderWidth: 0
  },
  categoryAxis: {
    axisLine: {
      lineStyle: {
        color: '#408829'
      }
    },
    splitLine: {
      lineStyle: {
        color: ['#eee']
      }
    }
  },
  valueAxis: {
    axisLine: {
      lineStyle: {
        color: '#408829'
      }
    },
    splitArea: {
      show: true,
      areaStyle: {
        color: ['rgba(250,250,250,0.1)', 'rgba(200,200,200,0.1)']
      }
    },
    splitLine: {
      lineStyle: {
        color: ['#eee']
      }
    }
  },
  timeline: {
    lineStyle: {
      color: '#408829'
    },
    controlStyle: {
      normal: {
        color: '#408829'
      },
      emphasis: {
        color: '#408829'
      }
    }
  },
  k: {
    itemStyle: {
      normal: {
        color: '#68a54a',
        color0: '#a9cba2',
        lineStyle: {
          width: 1,
          color: '#408829',
          color0: '#86b379'
        }
      }
    }
  },
  map: {
    itemStyle: {
      normal: {
        areaStyle: {
          color: '#ddd'
        },
        label: {
          textStyle: {
            color: '#c12e34'
          }
        }
      },
      emphasis: {
        areaStyle: {
          color: '#99d2dd'
        },
        label: {
          textStyle: {
            color: '#c12e34'
          }
        }
      }
    }
  },
  force: {
    itemStyle: {
      normal: {
        linkStyle: {
          strokeColor: '#408829'
        }
      }
    }
  },
  chord: {
    padding: 4,
    itemStyle: {
      normal: {
        lineStyle: {
          width: 1,
          color: 'rgba(128, 128, 128, 0.5)'
        },
        chordStyle: {
          lineStyle: {
            width: 1,
            color: 'rgba(128, 128, 128, 0.5)'
          }
        }
      },
      emphasis: {
        lineStyle: {
          width: 1,
          color: 'rgba(128, 128, 128, 0.5)'
        },
        chordStyle: {
          lineStyle: {
            width: 1,
            color: 'rgba(128, 128, 128, 0.5)'
          }
        }
      }
    }
  },
  gauge: {
    startAngle: 225,
    endAngle: -45,
    axisLine: {
      show: true,
      lineStyle: {
        color: [[0.2, '#86b379'], [0.8, '#68a54a'], [1, '#408829']],
        width: 8
      }
    },
    axisTick: {
      splitNumber: 10,
      length: 12,
      lineStyle: {
        color: 'auto'
      }
    },
    axisLabel: {
      textStyle: {
        color: 'auto'
      }
    },
    splitLine: {
      length: 18,
      lineStyle: {
        color: 'auto'
      }
    },
    pointer: {
      length: '90%',
      color: 'auto'
    },
    title: {
      textStyle: {
        color: '#333'
      }
    },
    detail: {
      textStyle: {
        color: 'auto'
      }
    }
  },
  textStyle: {
    fontFamily: 'Arial, Verdana, sans-serif'
  }
};

isArray = function(value) {
  return value && typeof value === 'object' && value instanceof Array && typeof value.length === 'number' && typeof value.splice === 'function' && !(value.propertyIsEnumerable('length'));
};

snoot_sidebar_hide = false;

snoot_sidebar = function() {
  var e, ssh;
  if (typeof window.localStorage !== "undefined") {
    try {
      ssh = window.localStorage.getItem("snoot_sidebar");
      if (ssh && ssh === 'hide') {
        snoot_sidebar_hide = false;
        return window.localStorage.setItem("snoot_sidebar", 'show');
      } else {
        snoot_sidebar_hide = true;
        return window.localStorage.setItem("snoot_sidebar", 'hide');
      }
    } catch (_error) {
      e = _error;
    }
  }
};

if (typeof window.localStorage !== "undefined") {
  try {
    ssh = window.localStorage.getItem("snoot_sidebar");
    if (ssh && ssh === 'hide') {
      snoot_sidebar_hide = true;
      document.body.setAttribute("class", "nav-sm");
    } else {
      snoot_sidebar_hide = false;
      document.body.setAttribute("class", "nav-md");
    }
  } catch (_error) {
    e = _error;
  }
}

connected = false;

logbuffer = [];

ws = new WebSocket("wss://doodlepad.io/api/writer.lua");

ws.onopen = function() {
  logbuffer.push("Connection established");
  return connected = true;
};

ws.onerror = function(err) {
  logbuffer.push("Connection error: " + err);
  return connected = false;
};

ws.onclose = function() {
  logbuffer.push("Connection closed");
  return connected = false;
};

ws.onmessage = function(event) {
  var msg;
  return msg = JSON.parse(event.data);
};
