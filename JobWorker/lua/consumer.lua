module(..., package.seeall)

local redis 	= require("lib/redis_ffi")
local logger 	= require("lua/logger")

local __END__ 	= logger.__END__
local __BEGIN__ = logger.__BEGIN__
local __DEBUG__ = logger.__DEBUG__
local __INFO__ 	= logger.__INFO__
local __ERROR__ = logger.__ERROR__

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

function consumer:consume(_j)
	__BEGIN__("consumer:consume")
	__DEBUG__("LINE: "..self.__line)

	if self.__redis then
		local _res = self.__redis:RPUSH(self.__line, _j)

		__DEBUG__("RES: ".._res)

		if _res >= 0 then
			__DEBUG__("consum success.")
		else
			__DEBUG__("ERROR: "..self.__redis:ERROR())
			__ERROR__("consum failed.")
		end
	end	

	__END__("consumer:consume")
end
	

