require("script/defs")
require("script/protocal")

local config 	= require("script/config")
local logger 	= require("script/logger")
local redis 	= require("lib/redis_ffi")

local __END__ 	= logger.__END__
local __BEGIN__ = logger.__BEGIN__
local __DEBUG__ = logger.__DEBUG__
local __INFO__ 	= logger.__INFO__
local __ERROR__ = logger.__ERROR__

local server 	= server
local timer 	= timer
local table 	= table
local G 		= _G

local l_t_timer_map = g_t_timer_map

local function __redis_init()
	G["g_t_notify_redis"] = redis.RedisFFI:NEW()

	if G["g_t_notify_redis"] then
		if G["g_t_notify_redis"]:CONNECT(config.REDIS_CONF.m_s_host, config.REDIS_CONF.m_n_port) then
			__DEBUG__("redis connect success.")
			return true
		else
			__ERROR__("redis connect failed.")	
			return false
		end
	end

	return false
end

function handle_init()
	__BEGIN__("handle_init")
	local l_n_port 		= global_command_args["p"]
	local l_s_server_ip = global_command_args["h"]
	local l_n_level 	= tonumber(global_command_args["l"])
	local l_n_sid 		= global_command_args["s"]
	
	if not __redis_init() then
		return -1
	end

    local l_ret = server.create_listener(l_n_port)
	if l_ret == -1 then 
		__ERROR__("create listen socket failed, port=" .. l_n_port)
		return -1
	end

	__INFO__("Server init success")

	start_report_timer()

	__END__("handle_init")
	
return 0
end

function handle_fini()
	log.info("Server will stop")
	return 0
end

function handle_accept(socket)
	__BEGIN__("handle_accept")
	__DEBUG__("new connection: "..socket)

	__END__("handle_accept")
	return 0	
end

function handle_input(socket, buffer, length)
	log.debug("Recv buffer: "..buffer)
	return 0
end

function handle_server_socket_close(socket, in_nconn_type)
	__BEGIN__("handle_server_socket_close")
	__DEBUG__("Remote server socket has closed, socket = " 
    .. socket ..", connection type = " .. in_nconn_type)

	__END__("handle_server_socket_close")
	return 0
end

function handle_client_socket_close(in_n_socket)
	__BEGIN__("handle_client_socket_close")
	__DEBUG__(string.format("Socket %d had Closed.", in_n_socket))
	
	G["g_n_gate_fd"] = nil

	__END__("handle_client_socket_close")
	return 0
end

function handle_timeout(in_ntimerid)
    __BEGIN__("handle_timeout")
    __DEBUG__("TimerID: "..in_ntimerid)

    local l_timer = l_t_timer_map[in_ntimerid]
    
    if l_timer then
        --  add current timer_id
		if l_timer.m_t_params then
			table.insert(l_timer.m_t_params, in_ntimerid)
		end

		l_timer.m_f_callback(l_timer.m_t_params)
        timer.stop_timer(in_ntimerid)
        timer.clear_timer(in_ntimerid)
    else
    	__ERROR__("Timer is not found: "..in_ntimerid)
    end
    
    __END__("handle_timeout")
	return 0
end

function reload_config()
	log.debug("-------- reload_config begin --------")
	package.loaded["script/global"] = nil
	require("script/global")

	if g_flag_reload then
		log.debug("reload true")
	else
		log.debug("reload false")
	end
	
	log.debug("-------- reload_config end --------")
	return 0
end

function dump(in_b_flag)
	package.path = package.path.."?.lua;../?.lua;../lib/?.lua;../../../lib/?.lua;/home/AustinChen/tools/luajit-2.0/src/?.lua;"
	if in_b_flag then
		local dump = require("jit.dump")
		dump.on(nil, "jit.log")
	else
		local dump = require("jit.v")
		dump.on("jit.log."..global_command_args["s"])
	end
end
