module(..., package.seeall)

local ffi = require 'ffi'

ffi.cdef[[
	typedef unsigned char uuid_t[16];
	void uuid_generate(uuid_t out);
	void uuid_generate_random(uuid_t out);
	void uuid_generate_time(uuid_t out);
	int uuid_generate_time_safe(uuid_t out);

	void uuid_unparse(const uuid_t uu, char *out);
]]

local uuid = ffi.load('libuuid')

function normal()
	if uuid then
		local uuid_t = ffi.new("uuid_t")
		local uuid_out = ffi.new("char[?]", 64)

		uuid.uuid_generate(uuid_t)
		uuid.uuid_unparse(uuid_t, uuid_out)
		result = ffi.string(uuid_out)

		return result
	end
end


function random()
	if uuid then
		local uuid_t = ffi.new("uuid_t")
		local uuid_out = ffi.new("char[?]", 64)

		uuid.uuid_generate_random(uuid_t)
		uuid.uuid_unparse(uuid_t, uuid_out)
		result = ffi.string(uuid_out)

		return result
	end
end

function time()
	if uuid then
		local uuid_t = ffi.new("uuid_t")
		local uuid_out = ffi.new("char[?]", 64)

		uuid.uuid_generate_time(uuid_t)
		uuid.uuid_unparse(uuid_t, uuid_out)
		result = ffi.string(uuid_out)

		return result
	end	
end

	
