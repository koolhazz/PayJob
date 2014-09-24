module(..., package.seeall)

local ffi = require("ffi")

ffi.cdef[[
	typedef struct redisReply {
		int type; /* REDIS_REPLY_* */
		long long integer; /* The integer when type is REDIS_REPLY_INTEGER */
		int len; /* Length of string */
		char *str; /* Used for both REDIS_REPLY_ERROR and REDIS_REPLY_STRING */
		size_t elements; /* number of elements, for REDIS_REPLY_ARRAY */
		struct redisReply **element; /* elements vector for REDIS_REPLY_ARRAY */
	} redisReply;

	typedef struct redisReadTask {
		int type;
		int elements; /* number of elements in multibulk container */
		int idx; /* index in parent (array) object */
		void *obj; /* holds user-generated value for a read task */
		struct redisReadTask *parent; /* parent task */
		void *privdata; /* user-settable arbitrary field */
	} redisReadTask;

	typedef struct redisReplyObjectFunctions {
		void *(*createString)(const redisReadTask*, char*, size_t);
		void *(*createArray)(const redisReadTask*, int);
		void *(*createInteger)(const redisReadTask*, long long);
		void *(*createNil)(const redisReadTask*);
		void (*freeObject)(void*);
	} redisReplyObjectFunctions;
	
	typedef struct redisReader {
		int err; /* Error flags, 0 when there is no error */
		char errstr[128]; /* String representation of error when applicable */

		char *buf; /* Read buffer */
		size_t pos; /* Buffer cursor */
		size_t len; /* Buffer length */

		redisReadTask rstack[4];
		int ridx; /* Index of current read task */
		void *reply; /* Temporary reply pointer */

		redisReplyObjectFunctions *fn;
		void *privdata;
	} redisReader;

	typedef struct redisContext {
	    int err; 
		char errstr[128]; 
		int fd;
		int flags;
		char *obuf; 
		redisReader *reader; 
	} redisContext;

	void *redisCommand(redisContext *c, const char *format, ...);
	redisContext *redisConnect(const char *ip, int port);
	redisContext *redisConnectWithTimeout(const char *ip, int port, struct timeval tv);
	
	void freeReplyObject(void *reply);
	void redisFree(redisContext *c);

	int printf(const char *format, ...);

	size_t strlen(const char *s);
]]

local hiredis = ffi.load("hiredis")
local C = ffi.C

local print = print
local setmetatable = setmetatable
local Command = hiredis.redisCommand
local Cast = ffi.cast

local NULL = ffi.cast("void*", 0)

RedisFFI = {
	m_s_host = "",
	m_n_port = 0,
	m_t_redis = nil,
}

local function _freeReplyObject(in_t_reply)
	hiredis.freeReplyObject(in_t_reply)
end

local function _redisFree(in_t_redis)
	hiredis.redisFree(in_t_redis)
end

local function _cast_string(in_t_str)
	return ffi.string(in_t_str, C.strlen(in_t_str))
end

function RedisFFI:NEW(o)
	o = o or {}

	setmetatable(o, self)

	self.__index = self

	return o
end

function RedisFFI:FREE(o)
	if self.m_t_redis then
		_redisFree(self.m_t_redis)
	end
end

function RedisFFI:CONNECT(in_s_host, in_n_port)
	self.m_s_host = in_s_host
	self.m_n_port = in_n_port

	self.m_t_redis = hiredis.redisConnect(in_s_host, in_n_port)
	
	if not self.m_t_redis then
		print("Connect Redis Server is Failed.")
		print("err: "..ffi.string(self.m_t_redis.errstr, C.strlen(self.m_t_redis.errstr)))
		
		_redisFree(self.m_t_redis)

		return false
	else
		print("Connect Redis Server is Success.")
		return true
	end
end

function RedisFFI:PRINT_CONFIG( ... )
	print("HOST: "..self.m_s_host)
	print("PORT: "..self.m_n_port)
end

function RedisFFI:SET(in_s_key, in_s_value)
	local reply = Cast("redisReply*", Command(self.m_t_redis, "SET %s %s", in_s_key, in_s_value))
	local _result = 0

	if reply then
		if reply.type == 1 then
			_result = reply.integer
		end
	end

	_freeReplyObject(reply)

	return _result
end

function RedisFFI:GET(in_s_key)
	local reply = Cast("redisReply*", Command(self.m_t_redis, "GET %s", in_s_key))
	local _result = nil

	if reply then
		if reply.type == 1 then
			_result = ffi.string(reply.str, C.strlen(reply.str))
		end
	end

	_freeReplyObject(reply)

	return _result
end

function RedisFFI:LPOP(in_s_key)
	local reply = Cast("redisReply*", Command(self.m_t_redis, "LPOP %s", in_s_key))
	local _result = nil

	if reply then
		if reply.type == 1 then
			_result = ffi.string(reply.str, C.strlen(reply.str))
		end
	end

	_freeReplyObject(reply)

	return _result
end

function RedisFFI:RPUSH(in_s_key, in_s_value)
	local reply = Cast("redisReply*", Command(self.m_t_redis, "RPUSH %s %s", in_s_key, in_s_value))
	local _result = 0

	if reply then
		if reply.type == 3 then
			_result = reply.integer
		end
	end

	_freeReplyObject(reply)

	return tonumber(_result)
end

function RedisFFI:LLEN(in_s_key)
	local reply = Cast("redisReply*", Command(self.m_t_redis, "LLEN %s", in_s_key))
	local _result = 0

	if reply then
		if reply.type == 3 then
			_result = reply.integer
		end
	end

	_freeReplyObject(reply)

	return tonumber(_result)
end

function RedisFFI:EXPIRE(in_s_key, in_s_sec)
	local reply = Cast("redisReply*", Command(self.m_t_redis, "EXPIRE %s %s", in_s_key, in_s_sec))
	local _result = 0

	if reply then
		if reply.type == 3 then
			_result = reply.integer
		end
	end

	_freeReplyObject(reply)

	return tonumber(_result)
end

function RedisFFI:DEL(in_s_key)
	local reply = Cast("redisReply*", Command(self.m_t_redis, "DEL %s", in_s_key))
	local _result = 0

	if reply then
		if reply.type == 3 then
			_result = reply.integer
		end
	end

	_freeReplyObject(reply)

	return tonumber(_result)
end

function RedisFFI:IsAlived() 
	local reply = Cast("redisReply*", Command(self.m_t_redis, "PING"))
	local _result = false

	if reply then
		if reply.type == 5 then -- reids status
			local str = _cast_string(reply.str, C.strlen(reply.str))
			if str == "PONG" then
				_result = true
			end
		end
	end

	_freeReplyObject(reply)

	return _result  
end
	
function RedisFFI:EXISTS(in_s_key)
	local reply = Cast("redisReply*", Command(self.m_t_redis, "EXISTS %s", in_s_key))
	local _result = 0

	if reply then
		if reply.type == 3 then
			_result = reply.integer
		end
	end

	_freeReplyObject(reply)

	return tonumber(_result)
end

function RedisFFI:HSET(in_s_name, in_s_key, in_s_value)
	local _reply = Cast("redisReply*", Command(self.m_t_redis, "HSET %s %s %s", in_s_name, in_s_key, in_s_value))
	local _result = 0

	if _reply then
		if _reply.type == 3 then
			_result = _reply.integer		
		end
	end

	_freeReplyObject(_reply)

	return tonumber(_result)
end

function RedisFFI:HGET(in_s_name, in_s_key)
	local _reply = Cast("redisReply*", Command(self.m_t_redis, "HGET %s %s", in_s_name, in_s_key))
	local _result = nil

	if _reply then
		if _reply.type == 1 then
			_result = ffi.string(_reply.str, C.strlen(_reply.str))	
		end
	end

	_freeReplyObject(_reply)

	return _result
end

function RedisFFI:HINCRBY(in_s_name, in_s_key, in_s_value)
	local _reply = Cast("redisReply*", Command(self.m_t_redis, "HINCRBY %s %s %s", in_s_name, in_s_key, in_s_value))
	local _result = 0

	if not _reply then
		if _reply.type == 3 then
			_result = _reply.integer		
		end
	end

	_freeReplyObject(_reply)

	return tonumber(_result)
end

function RedisFFI:HGETALL(in_s_name)
		
end

function RedisFFI:HDEL(in_s_name)
	
end

function RedisFFI:PUBLISH(in_s_channel, in_s_message)
	local _reply = Cast("redisReply*", Command(self.m_t_redis, "PUBLISH %s %s", in_s_channel, in_s_message))
	local _result = 0

	if not _reply then
		if _reply.type == 3 then
			_result = _reply.integer		
		end
	end

	_freeReplyObject(_reply)

	return tonumber(_result)	
end

function RedisFFI:SUBSCRIBE(in_s_channel)
	local _reply = Cast("redisReply*", Command(self.m_t_redis, "SUBSCRIBE %s", in_s_channel))
	local _result = nil

	if not _reply then
		if _reply.type == 1 then
			_result = ffi.string(_reply.str, C.strlen(_reply.str))		
		end
	end

	_freeReplyObject(_reply)

	return _result	
end

function RedisFFI:ERROR()
	local _result = _cast_string(self.m_t_redis.errstr)

	return _result
end
	
