--[[
 Licensed to the Apache Software Foundation (ASF) under one or more
 contributor license agreements.  See the NOTICE file distributed with
 this work for additional information regarding copyright ownership.
 The ASF licenses this file to You under the Apache License, Version 2.0
 (the "License"); you may not use this file except in compliance with
 the License.  You may obtain a copy of the License at

     http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
]]--

-- This is elastic.lua - ElasticSearch library

local http = require 'socket.http'
local ltn12 = require("ltn12")
local JSON = require 'cjson'
local config = {
    es_url = 'http://127.0.0.1/doodlepad/'
}

local default_doc = "pad"

-- http code return check
function checkReturn(code)
    if not code or code ~= 200 then
        if not code or code == "closed" then
            error("Could not contact database backend!")
        else
            error("Backend Database returned code " .. code .. "!")
        end
        return nil
    end
end

-- Standard ES query, returns $size results of any doc of type $doc, sorting by $sitem
function getHits(query, size, doc, sitem)
    doc = doc or "mbox"
    sitem = sitem or "epoch"
    size = size or 10
    query = query:gsub(" ", "+")
    local url = config.es_url .. doc .. "/_search?q="..query.."&size=" .. size
    local result, hc = http.request(url)
    local out = {}
    checkReturn(hc)
    local json = JSON.decode(result)
    local out = {}
    if json and json.hits and json.hits.hits then
        for k, v in pairs(json.hits.hits) do
            v._source.request_id = v._id
            table.insert(out, v._source)
        end
    end
    return out
end

-- Get a single document
function getDoc (ty, id)
    local url = config.es_url  .. ty .. "/" .. id
    local result, hc = http.request(url)
    local out = {}
    if hc == 404 then
        return nil
    end
    local json = JSON.decode(result)
    if json and json._source then
        json._source.request_id = json._id
    end
    return (json and json._source) and json._source or {}
end

-- Get results (a'la getHits), but only return email headers, not the body
-- provides faster transport when we don't need everything
function getHeaders(query, size, doc, includes)
    doc = doc or "mbox"
    size = size or 10
    query = query:gsub(" ", "+")
    local url = config.es_url  .. doc .. "/_search?_source_include="..includes.."&q="..query.."&size=" .. size
    local result, hc = http.request(url)
    local out = {}
    checkReturn(hc)
    local json = JSON.decode(result)
    local out = {}
    if json and json.hits and json.hits.hits then
        for k, v in pairs(json.hits.hits) do
            v._source.request_id = v._id
            table.insert(out, v._source)
        end
    end
    return out
end

-- Same as above, but reverse return order
function getHeadersReverse(query, size, doc)
    doc = doc or "mbox"
    size = size or 10
    query = query:gsub(" ", "+")
    local url = config.es_url .. doc .. "/_search?_source_exclude=body&q="..query.."&size=" .. size
    local result, hc = http.request(url)
    local out = {}
    local json = JSON.decode(result)
    local out = {}
    checkReturn(hc)
    if json and json.hits and json.hits.hits then
        for k, v in pairs(json.hits.hits) do
            v._source.request_id = v._id
            table.insert(out, 1, v._source)
        end
    end
    return out
end

-- Do a raw ES query with a JSON query
function raw(query, doctype)
    local js = JSON.encode(query)
    doctype = doctype or default_doc
    local url = config.es_url .. doctype .. "/_search"
    local result, hc = http.request(url, js)
    local out = {}
    checkReturn(hc)
    local json = JSON.decode(result)
    return json or {}, url
end


-- Do a raw ES delete with a JSON query
function deleteByQuery(query, doctype)
    local js = JSON.encode(query)
    doctype = doctype or default_doc
    respbody = {}
    local url = config.es_url .. doctype .. "/_query"
    local result, hc = http.request{
        url=url,
        source=ltn12.source.string(js),
        method="DELETE",
        headers = {
            ["content-type"] = "application/json",
            ["content-length"] = tostring(#js)
        },
        sink = ltn12.sink.table(respbody)
        }
    local out = {}
    checkReturn(hc)
    local json = JSON.decode(table.concat(respbody))
    return json or {}, url
end

-- raw count
function count(query, doctype)
    local js = JSON.encode(query)
    doctype = doctype or default_doc
    local url = config.es_url .. doctype .. "/_count"
    local result, hc = http.request(url, js)
    local out = {}
    checkReturn(hc)
    local json = JSON.decode(result)
    return json or {}, url
end

-- Raw query with scroll/scan
function scan(query, doctype)
    local js = JSON.encode(query)
    doctype = doctype or default_doc
    local url = config.es_url .. doctype .. "/_search?search_type=scan&scroll=1m"
    local result, hc = http.request(url, js)
    local out = {}
    checkReturn(hc)
    local json = JSON.decode(result)
    if json and json._scroll_id then
        return json._scroll_id
    end
    return nil
end

function scroll(sid)
    doctype = doctype or default_doc
    -- We have to do some gsubbing here, as ES expects us to be at the root of the ES URL
    -- But in case we're being proxied, let's just cut off the last part of the URL
    local url = config.es_url:gsub("[^/]+/?$", "") .. "/_search/scroll?scroll=1m&scroll_id=" .. sid
    local result, hc = http.request(url)
    checkReturn(hc)
    local json = JSON.decode(result)
    if json and json._scroll_id then
        return json, json._scroll_id
    end
    return nil
end

-- Update a document
function update(doctype, id, query, consistency)
    local js = JSON.encode({doc = query })
    doctype = doctype or default_doc
    local url = config.es_url .. doctype .. "/" .. id .. "/_update"
    if consistency then
        url = url .. "?write_consistency=" .. consistency
    end
    local result, hc = http.request(url, js)
    local out = {}
    local json = JSON.decode(result)
    return json or {}, url
end


-- Delete a document
function delete(doctype, id)
    if #id > 0 then
        local url = config.es_url .. doctype .. "/" .. id
        local result, hc = http.request{url=url, method="DELETE"}
        local json = JSON.decode(result)
        return json or {}, url
    end
end


-- Put a new document somewhere
function index(r, id, ty, body, consistency)
    local js = JSON.encode(body)
    if not id then
        id = r:sha1(ty .. (math.random(1,99999999)*os.time()) .. ':' .. r:clock())
    end
    local url = config.es_url .. ty .. "/" .. id
    if consistency then
        url = url .. "?write_consistency=" .. consistency
    end
    local result, hc = http.request(url, js)
    local out = {}
    local json = JSON.decode(result)
    return json or {}
end

function setDefault(typ)
    default_doc = typ
end

-- module defs
return {
    find = getHits,
    findFast = getHeaders,
    findFastReverse = getHeadersReverse,
    get = getDoc,
    raw = raw,
    index = index,
    default = setDefault,
    update = update,
    scan = scan,
    scroll = scroll,
    count = count,
    delete = delete,
    deleteByQuery = deleteByQuery
}