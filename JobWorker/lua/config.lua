module(..., package.seeall)

MYSQL_CONF = {
	m_host 		= "192.168.100.167",
	m_port 		= 3388,
	m_db 		= "kslave",
	m_user 		= "root",
	m_password 	= "",
	
}

REDIS_CONF = {
	m_s_host 	= "192.168.100.167",
	m_n_port 	= 4501,
	m_n_timeout = 5,
}

LINE_CONF = {
	m_s_p_line = "WaiterQ_",
	m_s_c_line = "NotifyQ_",
	m_n_p_sid = 1001,
	m_n_s_sid = 1002,
}

SERVICE_CONF = {
	m_s_url = "", 
}

