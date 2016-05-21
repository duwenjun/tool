local ini = require "ini"
local redis = require "resty.redis"
local red = redis:new()
red:set_timeout(1000) -- 1 sec

-- 加载ini配置
local config = ini.load('/var/tmp/redis.ini')
local host = ini.get(config, 'redis_cache', 'host')
local port = ini.get(config, 'redis_cache', 'port')
local passwd = ini.get(config, 'redis_cache', 'passwd')

local ok, err = red:connect(host, port)
if not ok then
    ngx.say("failed to connect: ", err)
    return
end

local res, err = red:auth(passwd)
if not res then
    ngx.say("failed to authenticate: ", err)
    return
end

-- 获取当前url
local key = string.sub(ngx.var.request_uri, 2)

-- 获取短链接真实地址
local url = red:hget('short_link', key);

-- 跳转地址
if (url ~= nil and type(url) == 'string') then
	red:hincrby('short_link_counter', key, 1)
	ngx.redirect(url, ngx.HTTP_MOVED_TEMPORARILY)
else
	ngx.say('Could not find the url')
end
