-- gate netfd
g_n_gate_fd 			= nil

-- wait queue object
g_t_waiter_redis 		= nil

g_t_log_level = {
	ERROR 	= 	1,
	INFO 	= 	2,
	DEBUG 	= 	3,
}

g_flag_log_level 		= 3

g_s_waiter_queue 		= "WaiterQ_"

g_t_timer_map 			= {}

g_n_rpt_timer_id 		= nil