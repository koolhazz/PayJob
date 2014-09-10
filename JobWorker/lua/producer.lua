module(..., package.seeall)

local libcurl = require("lib/libcurl")
local redis = require("lib/redis_ffi")

this = {
	__redis 	= nil, -- 队列
	__host 		= nil,
	__port 		= nil,
	__service	= nil, -- 支付请求接口
	__line 		= nil, -- 消费队列
	__curl 		= nil,
}

local function __new_redis(_h, _p)
end

local function __new_curl()
end

function producer:new(o)
	o = o or {}

	setmetatable(o, self)

	self.__index = self

	return o
end

function producer:init()
	self.__redis = __new_redis(self.__host, self.__port)
	self.__curl = __new_curl()
end

function producer:set_host(_h, _p)
end

function producer:set_service(_s)
end

function producer:set_line(_l)
end

function producer:produce()
end


	