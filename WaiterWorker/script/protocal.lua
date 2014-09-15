require("script/defs")
require("script/cmd")

package.cpath = package.cpath .. ";./lib/?.so"

local config 	= require("script/config")
local utils 	= require("script/utils")
local json 		= require("cjson")
local logger 	= require("script/logger")

local __END__ 	= logger.__END__
local __BEGIN__ = logger.__BEGIN__
local __DEBUG__ = logger.__DEBUG__
local __INFO__ 	= logger.__INFO__
local __ERROR__ = logger.__ERROR__

local G 		= _G
local packet 	= packet
local os 		= os
local timer 	= timer
local table 	= table
local pairs 	= pairs
local ipairs 	= ipairs 
local string 	= string

protocal_define_table = {
	CB_PAY_REQ 			= { 0x8001, "dds", 	"fd, ReqType, ReqMsg", 	"cb_pay_req_handler" },
	CB_WAITER_STAT_REQ 	= { 0x8002, "d",	"fd", 					"cb_waiter_stat_req_handler"},  
}

function cb_pay_req_handler(_n_fd, _n_req_type, _s_req_msg)
	if not G["g_n_gate_fd"] then
		G["g_n_gate_fd"] = _n_fd
	end

	if G["g_t_waiter_redis"] then
		local __queue = G["g_s_waiter_queue"]..G["global_command_args"]["s"]
		G["g_t_waiter_redis"]:RPUSH(__queue, _s_req_msg)
		__DEBUG__("queue: "..__queue.." json: ".._s_req_msg)
	else
		__ERROR__("redis is null.")
	end

	return 0
end

function cb_waiter_stat_req_handler(_n_fd)
	if not G["g_n_gate_fd"] then
		G["g_n_gate_fd"] = _n_fd
	end

	local _q_len = 0

	if G["g_t_waiter_redis"] then
		local __queue = G["g_s_waiter_queue"]..G["global_command_args"]["s"]
		_q_len = G["g_t_waiter_redis"]:LLEN(__queue)	
	end

	packet.write_begin(RES_CMD.RES_WAITER_STAT)

	packet.write_int(_q_len)
	packet.write_int(os.time())

	packet.write_end()

	local _n_slen = packet.send_packet(_n_fd)

	if _n_slen <= 0 then
		__ERROR__("send failed.")
	end

	return 0
end


	
	

