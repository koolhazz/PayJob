require("script/defs")
require("script/cmd")

package.cpath = package.cpath .. ";./lib/?.so"

local config 	= require("script/config")
local utils 	= require("script/utils")
local json 		= require("cjson")
local logger 	= require("script/logger")
local mytimer 	= require("script/mytimer")

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
	CB_NOTIFY_STAT_REQ 	= { 0x8003, "d",	"fd", 					"cb_notify_stat_req_handler"},  
}

function cb_notify_stat_req_handler(_n_fd)
	__BEGIN__("cb_notify_stat_req_handler")
	if not G["g_n_gate_fd"] then
		G["g_n_gate_fd"] = _n_fd
	end

	local _q_len = 0

	if G["g_t_notify_redis"] then
		local __queue = G["g_s_notify_queue"]..G["global_command_args"]["s"]
		_q_len = G["g_t_notify_redis"]:LLEN(__queue)	
	end

	packet.write_begin(RES_CMD.RES_NOTIFY_STAT)

	packet.write_int(_q_len)
	packet.write_int(os.time())

	packet.write_end()

	local _n_slen = packet.send_packet(_n_fd)

	if _n_slen <= 0 then
		__ERROR__("send failed.")
	end

	__END__("cb_notify_stat_req_handler")
	return 0
end

function notify_stat_report(_t_params)
	__BEGIN__("notify_stat_report")
	local _fd = _t_params[1] or G["g_n_gate_fd"]
	local _redis = _t_params[2] or G["g_t_notify_redis"]

	stop_report_timer(G["g_n_rpt_timer_id"])

	if not _fd then
		__ERROR__("_fd is nil.")
		start_report_timer()
		__END__("notify_stat_report", 1)
		return 
	end

	if not _redis then
		__ERROR__("_redis is nil.")
		start_report_timer()
		__END__("notify_stat_report", 2)
		return 
	end

	if _redis:IsAlived() then
		cb_notify_stat_req_handler(_fd)		
	end

	start_report_timer()
	__END__("notify_stat_report")
	return 0
end

function start_report_timer()
	__BEGIN__("start_report_timer")
	G["g_n_rpt_timer_id"] = mytimer.start_timer{ 
								m_n_second 		= 60,
								m_t_params 		= {G["g_n_gate_fd"], G["g_t_notify_redis"]},
								m_f_callback 	= notify_stat_report
							}
	__END__("start_report_timer")
end

function stop_report_timer(_n_timer_id)
	if _n_timer_id then
		mytimer.stop_timer(_n_timer_id)
	end
end

function notify_worker()
	__BEGIN__("notify_worker")

	local _redis = G["g_t_notify_redis"]
	local _notify_cnt = 10
	local _queue = G["g_s_notify_queue"]..G["global_command_args"]["s"]

	__DEBUG__("QUEUE: ".._queue)
	
	if _redis then
		for i = 1, _notify_cnt do 
			local _job = _redis:LPOP(_queue)

			if _job then

				__DEBUG__("JSON: ".._job)
				packet.write_begin(RES_CMD.RES_PAY)

				packet.write_byte(0)
				packet.write_string(_job)

				packet.write_end()

				__DEBUG__("slen: "..packet.send_packet(G["g_n_gate_fd"]))				
			end
		end			
	end

	__END__("notify_worker")

	return 0
end
	
	

