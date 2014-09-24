require("lua/defs")

local producer 	= require("lua/producer")
local consumer 	= require("lua/consumer")
local config 	= require("lua/config")
local logger 	= require("lua/logger")
local redis 	= require("lib/redis_ffi")
local ffi		= require("ffi")

local __END__ 	= logger.__END__
local __BEGIN__ = logger.__BEGIN__
local __DEBUG__ = logger.__DEBUG__
local __INFO__ 	= logger.__INFO__
local __ERROR__ = logger.__ERROR__

ffi.cdef[[
	unsigned int sleep(unsigned int seconds);
	void usleep(unsigned long usec);
]]

local C = ffi.C

local O = {
	__pd 		= nil,
	__cs 		= nil,
	__pd_cnt 	= 0,
	__cs_cnt 	= 0,
	__er_cnt 	= 0, 
}



local function __init()
	O.__pd = producer.producer:new()

	if O.__pd then
		local __pd = O.__pd 

		__pd:set_host(config.REDIS_CONF.m_s_host, config.REDIS_CONF.m_n_port)
		__pd:set_line(config.LINE_CONF.m_s_p_line..config.LINE_CONF.m_n_p_sid)
		__pd:set_service(config.SERVICE_CONF.m_s_url)

		if not __pd:init() then
			__ERROR__("__pd init failed.")
			return false	
		end
	else
		__ERROR__("O.__pd new failed.")
	end

	O.__cs = consumer.consumer:new()

	if O.__cs then
		local __cs = O.__cs 

		__cs:set_host(config.REDIS_CONF.m_s_host, config.REDIS_CONF.m_n_port)
		__cs:set_line(config.LINE_CONF.m_s_c_line..config.LINE_CONF.m_n_c_sid)

		if not __cs:init() then
			__ERROR__("__cs init failed.")
			return false	
		end
	else
		__ERROR__("O.__cs new failed.")		
	end

	return true
end

local function __run()
	__BEGIN__("__run")
	while true do
		local __json = O.__pd:produce()
		if __json then
			O.__pd_cnt = O.__pd_cnt + 1
			
			__DEBUG__("JSON: "..__json)

			O.__cs:consume(__json)		

			O.__cs_cnt = O.__cs_cnt + 1
		else
			C.sleep(1);
		end
	end
	__END__("__run")
end

local function __redis_test()
	local _rds = redis.RedisFFI:NEW()
	
	if _rds:CONNECT("192.168.100.167", 4501) then
		_rds:SET("chenbo", "11111");
	end
	
	return 0
end

function start()
	__BEGIN__("start")
	if __init() then
		__INFO__("system init success.")
	else
		__ERROR__("system init failed.")
		return -1
	end

	__run()
		
	__END__("start")
	
	return 0
end


