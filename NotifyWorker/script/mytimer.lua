module(..., package.seeall)

require("script/defs")

local utils 		= require("script/utils")
local timer 		= timer
local l_t_timer_map = g_t_timer_map

-- 清空定时器的table类型的参数
local function free_timer(in_n_timer_id)
	if l_t_timer_map[in_n_timer_id] then
		local l_t_temp = l_t_timer_map[in_n_timer_id]
		utils.table.clear(l_t_temp.m_t_params)
		utils.table.clear(l_t_temp)
		l_t_timer_map[in_n_timer_id] = nil
	end
end

-- in_t_timer_info format is {m_n_second, m_t_params = {}, m_f_callback = xxxxxx, }
function start_timer(in_t_timer_info) 
	local l_n_timer_id = timer.create_timer()

	timer.start_timer(l_n_timer_id, in_t_timer_info.m_n_second)

	l_t_timer_map[l_n_timer_id] = { 
									m_n_id 			= l_n_timer_id,
									m_t_params 		= in_t_timer_info.m_t_params,
									m_f_callback 	= in_t_timer_info.m_f_callback,
								}

	return l_n_timer_id
end

function stop_timer(in_n_timer_id)
	timer.stop_timer(in_n_timer_id)
	timer.clear_timer(in_n_timer_id)

	free_timer(in_n_timer_id)
end

