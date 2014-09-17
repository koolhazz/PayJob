module(..., package.seeall)

local redis = require("lib/redis_ffi")

consumer = {
	__redis = nil,
	__host 	= nil,
	__port 	= nil,
	__line 	= nil,
}

function consumer:new(o)
	o = o or {}

	setmetatable(o, self)

	self.__index = self

	return o
end

function consumer:init()
	self.__redis = redis.RedisFFI:NEW()

	if not self.__redis then
		return false
	end

	if not self.__redis:CONNECT(self.__host, self.__port) then
		return false
	else
		return true
	end

end

function consumer:set_host(_h, _p)
	self.__host = _h
	self.__port = _p
end

function consumer:set_line(_l)
	self.__line = _l
end

function consumer:consum(_j)
	
end
	

