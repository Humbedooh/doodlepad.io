API = 2

Number.prototype.pretty = (fix) ->
    if (fix)
        return String(this.toFixed(fix)).replace(/(\d)(?=(\d{3})+\.)/g, '$1,');
    return String(this.toFixed(0)).replace(/(\d)(?=(\d{3})+$)/g, '$1,');


fetch = (url, xstate, callback, snap, nocreds) ->
    xmlHttp = null;
    # Set up request object
    if window.XMLHttpRequest
        xmlHttp = new XMLHttpRequest();
    else
        xmlHttp = new ActiveXObject("Microsoft.XMLHTTP");
    if not nocreds
        xmlHttp.withCredentials = true
    # GET URL
    xmlHttp.open("GET", "https://api.snoot.io" + url, true);
    xmlHttp.send(null);
    
    xmlHttp.onreadystatechange = (state) ->
            if xmlHttp.readyState == 4 and xmlHttp.status == 500
                if snap
                    snap(xstate)
            if xmlHttp.readyState == 4 and xmlHttp.status == 200
                if callback
                    # Try to parse as JSON and deal with cache objects, fall back to old style parse-and-pass
                    try
                        response = JSON.parse(xmlHttp.responseText)
                        if response && response.loginRequired
                            location.href = "/login.html"
                            return
                        callback(response, xstate);
                    catch e
                        callback(JSON.parse(xmlHttp.responseText), xstate)

post = (url, args, xstate, callback, snap) ->
    xmlHttp = null;
    # Set up request object
    if window.XMLHttpRequest
        xmlHttp = new XMLHttpRequest();
    else
        xmlHttp = new ActiveXObject("Microsoft.XMLHTTP");
    xmlHttp.withCredentials = true
    # Construct form data
    ar = []
    for k,v of args
        if v and v != ""
            ar.push(k + "=" + encodeURIComponent(v))
    fdata = ar.join("&")
    
    
    # POST URL
    xmlHttp.open("POST", "https://api.snoot.io" + url, true);
    xmlHttp.setRequestHeader("Content-type", "application/x-www-form-urlencoded");
    xmlHttp.send(fdata);
    
    xmlHttp.onreadystatechange = (state) ->
            if xmlHttp.readyState == 4 and xmlHttp.status == 500
                if snap
                    snap(xstate)
            if xmlHttp.readyState == 4 and xmlHttp.status == 200
                if callback
                    # Try to parse as JSON and deal with cache objects, fall back to old style parse-and-pass
                    try
                        response = JSON.parse(xmlHttp.responseText)
                        callback(response, xstate);
                    catch e
                        callback(JSON.parse(xmlHttp.responseText), xstate)


postJSON = (url, json, xstate, callback, snap) ->
    xmlHttp = null;
    # Set up request object
    if window.XMLHttpRequest
        xmlHttp = new XMLHttpRequest();
    else
        xmlHttp = new ActiveXObject("Microsoft.XMLHTTP");
    xmlHttp.withCredentials = true
    # Construct form data
    fdata = JSON.stringify(json)
    
    # POST URL
    xmlHttp.open("POST", "https://api.snoot.io" + url, true);
    xmlHttp.setRequestHeader("Content-type", "application/json");
    xmlHttp.send(fdata);
    
    xmlHttp.onreadystatechange = (state) ->
            if xmlHttp.readyState == 4 and xmlHttp.status == 500
                if snap
                    snap(xstate)
            if xmlHttp.readyState == 4 and xmlHttp.status == 200
                if callback
                    # Try to parse as JSON and deal with cache objects, fall back to old style parse-and-pass
                    try
                        response = JSON.parse(xmlHttp.responseText)
                        callback(response, xstate);
                    catch e
                        callback(JSON.parse(xmlHttp.responseText), xstate)

mk = (t, s, tt) ->
    r = document.createElement(t)
    if s
        for k, v of s
            if v
                r.setAttribute(k, v)
    if tt
        if typeof tt == "string"
            app(r, txt(tt))
        else
            if isArray tt
                for k in tt
                    if typeof k == "string"
                        app(r, txt(k))
                    else
                        app(r, k)
            else
                app(r, tt)
    return r

app = (a,b) ->
    if isArray b
        for item in b
            if typeof item == "string"
                item = txt(item)
            a.appendChild(item)
    else
        return a.appendChild(b)


set = (a, b, c) ->
    return a.setAttribute(b,c)

txt = (a) ->
    return document.createTextNode(a)

get = (a) ->
    return document.getElementById(a)

swi = (obj) ->
    switchery = new Switchery(obj, {
                color: '#26B99A'
            })

cog = (div, size = 200) ->
        idiv = document.createElement('div')
        idiv.setAttribute("class", "icon")
        idiv.setAttribute("style", "text-align: center; vertical-align: middle; height: 500px;")
        i = document.createElement('i')
        i.setAttribute("class", "fa fa-spin fa-cog")
        i.setAttribute("style", "font-size: " + size + "pt !important; color: #AAB;")
        idiv.appendChild(i)
        idiv.appendChild(document.createElement('br'))
        idiv.appendChild(document.createTextNode('Loading, hang on tight..!'))
        div.innerHTML = ""
        div.appendChild(idiv)

globArgs = {}


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
                  normal: {color: '#408829'},
                  emphasis: {color: '#408829'}
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

isArray = ( value ) ->
    value and
        typeof value is 'object' and
        value instanceof Array and
        typeof value.length is 'number' and
        typeof value.splice is 'function' and
        not ( value.propertyIsEnumerable 'length' )
        
snoot_sidebar_hide = false
snoot_sidebar = () ->
    if (typeof(window.localStorage) != "undefined") 
        try
            ssh = window.localStorage.getItem("snoot_sidebar")
            if ssh and ssh == 'hide'
                snoot_sidebar_hide = false
                window.localStorage.setItem("snoot_sidebar", 'show')
            else
                snoot_sidebar_hide = true
                window.localStorage.setItem("snoot_sidebar", 'hide')
        catch e
            #


# Resize menu bar if set so
if (typeof(window.localStorage) != "undefined") 
    try
        ssh = window.localStorage.getItem("snoot_sidebar")
        if ssh and ssh == 'hide'
            snoot_sidebar_hide = true
            document.body.setAttribute("class", "nav-sm")
        else
            snoot_sidebar_hide = false
            document.body.setAttribute("class", "nav-md")
    catch e
        #