----------------------- [ ꜰxᴄᴏʀᴇ ] -----------------------
-- ɢɪᴛʜᴜʙ: https://github.com/jonstoler/class.lua
-- ʟɪᴄᴇɴꜱᴇ: None
-- ᴅᴇᴠᴇʟᴏᴘᴇʀ: jonstoler
-- ᴘʀᴏᴊᴇᴄᴛ: class.lua
-- ᴠᴇʀꜱɪᴏɴ: unknown
-- ᴅᴇꜱᴄʀɪᴘᴛɪᴏɴ: object-oriented library for lua
----------------------- [ ꜰxᴄᴏʀᴇ ] -----------------------

Class = {}

-- default (empty) constructor
function Class:init(...) end

-- create a subclass
function Class:extend(name, obj)
	obj = obj or {}

	local function copyTable(table, destination)
		table = table or {}
		local result = destination or {}

		for k, v in pairs(table) do
			if not result[k] then
				if type(v) == "table" and k ~= "__index" and k ~= "__newindex" then
					result[k] = copyTable(v)
				else
					result[k] = v
				end
			end
		end

		return result
	end

	copyTable(self, obj)

	obj.__class = string.trim(name)
	obj._ = obj._ or {}

	local mt = {}

	-- create new objects directly, like o = Object()
	mt.__call = function(self, ...)
		return self:new(...)
	end

	-- allow for getters and setters
	mt.__index = function(table, key)
		local val = rawget(table._, key)
		if val and type(val) == "table" and (val.get ~= nil or val.value ~= nil) then
			if val.get then
				if type(val.get) == "function" then
					return val.get(table, val.value)
				else
					return val.get
				end
			elseif val.value then
				return val.value
			end
		else
			return val
		end
	end

	mt.__newindex = function(table, key, value)
		local val = rawget(table._, key)
		if val and type(val) == "table" and ((val.set ~= nil and val._ == nil) or val.value ~= nil) then
			local v = value
			if val.set then
				if type(val.set) == "function" then
					v = val.set(table, value, val.value)
				else
					v = val.set
				end
			end
			val.value = v
			if val and val.afterSet then val.afterSet(table, v) end
		else
			table._[key] = value
		end
	end

	setmetatable(obj, mt)

	return obj
end

-- set properties outside the constructor or other functions
function Class:set(prop, value)
	if not value and type(prop) == "table" then
		for k, v in pairs(prop) do
			rawset(self._, k, v)
		end
	else
		rawset(self._, prop, value)
	end
end

-- create an instance of an object with constructor parameters
function Class:new(name, ...)
	local obj = self:extend(name, {})
	if obj.init then obj:init(...) end
	return obj
end


function class(...)
	return Class:extend(...)
end

--
-- Returns class type or default type
-- @obj any Any variable
-- @return string name of Type
--
function typeof(obj)
	local _type = type(obj)

	if (_type == 'table' and type(obj.__class) == 'string') then
		return obj.__class
	end

	return _type
end

-- FiveM manipulation
_ENV.class = class
_ENV.typeof = typeof
_G.class = class
_G.typeof = typeof