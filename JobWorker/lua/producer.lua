module(..., package.seeall)

package.cpath = package.cpath .. ";./lib/?.so"

local curl 		= require("lib/libcurl")
local redis 	= require("lib/redis_ffi")
local ffi 		= require("ffi")
local json 		= require("cjson")
local logger 	= require("lua/logger")

local __END__ 	= logger.__END__
local __BEGIN__ = logger.__BEGIN__
local __DEBUG__ = logger.__DEBUG__
local __INFO__ 	= logger.__INFO__
local __ERROR__ = logger.__ERROR__

producer = {
	__redis 	= nil, 
	__host 		= nil,
	__port 		= nil,
	__service	= nil, -- 支付请求接口
	__line 		= nil, -- 消费队列
	__curl 		= nil,
}

local __response = {}

local function __get_job(_r, _l)
	__BEGIN__("__get_job")
	if _r then
		local __job = _r:LPOP(_l)
		
		__END__("__get_job")
		return __job
	end
	
	__END__("__get_job")
end

function __write_response(ptr, sz, nu, userdata)
	local _str = ffi.string(ptr, sz * nu)

	if _str then
		table.insert(__response, _str)
	end
end

local function __do_job(_c, _s, _j)
	if _c and _s and _j then
		_c:set_url(_s)
		_c:set_post(1)
		_c:set_postfields("json=".._j)
		_c:set_writefunction(__write_response)

		local _res = _c:perform() 

		return _res
	end

	return 0
end

function producer:new(o)
	o = o or {}

	setmetatable(o, self)

	self.__index = self

	return o
end

function producer:init()
	self.__redis = redis.RedisFFI:NEW()
	self.__curl = curl.CURL:new()

	if not self.__redis then
		return false
	end

	if not self.__curl then
		return false
	end

	if not self.__redis:CONNECT(self.__host, self.__port) then
		return false
	end

	if not self.__curl:init() then
		return false
	end

	return true
end

function producer:set_host(_h, _p)
	self.__host = _h
	self.__port = _p
end

function producer:set_service(_s)
	self.__service = _s
end

function producer:set_line(_l)
	self.__line = _l
end

function producer:produce()
	__BEGIN__("producer:produce")
	local __job = __get_job(self.__redis, self.__line)
	
	if not job then
		__END__("producer:produce", 3)
		return  nil
	end
	
	local _o = json.decode(__job)
	
	local __res = __do_job(self.__curl, self.__service, __job)

	if __res == 0 then
		if _o then
			_o.result = table.concat(__response, nil)
		end	
		
		__END__("producer:produce", 1)
		return json.encode(_o)
	else
		__ERROR__("__do_job failed.")

		if _o then
			_o.result = ""
		end
		
		__END__("producer:produce", 2)
		return json.encode(_o)
	end
end


	