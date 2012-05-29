---[[

local core = require "core.core"
core.set_app()

local controller = require "core.controller"

--ngx.say(mysql)
--mysql.select()
--mysql.close()
--ngx.say(#config.require_path)
--ngx.say(config)

--[[
controller.run()
--]]



--[[
ngx.say('hello, world')
ngx.say(DURAP_HOME)
ngx.say(package.path)
--]]


--[[
local g = _G
setfenv(1, g)
ngx.say(package.path)
ngx.say("<br><br>")
package.path = ngx.var.DURAP_HOME .. "/system/core/?.lua;" .. package.path
ngx.say(package.path)


local mysql = require "resty.mysql"
local db = mysql:new()

db:set_timeout(1000) -- 1 sec

local ok, err, errno, sqlstate = db:connect {
    host = "127.0.0.1",
    port = 3306,
    database = "ngx_test",
    user = "root",
    password = "",
    max_packet_size = 1024 * 1024
}

if not ok then
    ngx.say("failed to connect: ", err, ": ", errno, " ", sqlstate)
    return
end

ngx.say("connected to mysql.")

local res, err, errno, sqlstate =
db:query("drop table if exists cats")
if not res then
    ngx.say("bad result: ", err, ": ", errno, ": ", sqlstate, ".")
    return
end

res, err, errno, sqlstate =
db:query("create table cats "
.. "(id serial primary key, "
.. "name varchar(5))")
if not res then
    ngx.say("bad result: ", err, ": ", errno, ": ", sqlstate, ".")
    return
end

ngx.say("table cats created.")

res, err, errno, sqlstate =
db:query("insert into cats (name) "
.. "values (\'Bob\'),(\'\'),(null)")
if not res then
    ngx.say("bad result: ", err, ": ", errno, ": ", sqlstate, ".")
    return
end

ngx.say(res.affected_rows, " rows inserted into table cats ",
"(last insert id: ", res.insert_id, ")")

res, err, errno, sqlstate =
db:query("select * from cats order by id asc")
if not res then
    ngx.say("bad result: ", err, ": ", errno, ": ", sqlstate, ".")
    return
end

local cjson = require "cjson"
ngx.say("result: ", cjson.encode(res))

-- put it into the connection pool of size 100,
-- with 0 idle timeout
local ok, err = db:set_keepalive(60 * 1000, 100)
if not ok then
    ngx.say("failed to set keepalive: ", err)
    return
end
--]]

-- or just close the connection right away:
-- local ok, err = db:close()
-- if not ok then
--     ngx.say("failed to close: ", err)
--     return
-- end