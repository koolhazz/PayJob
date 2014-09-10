module(..., package.seeall)

local redis = require("lib/redis_ffi")

this = {
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
	

