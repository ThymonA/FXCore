----------------------- [ ꜰxᴄᴏʀᴇ ] -----------------------
-- ɢɪᴛʟᴀʙ: https://git.tigodev.com/Tigo/fx_core
-- ɢɪᴛʜᴜʙ: https://github.com/TigoDevelopment/FXCore
-- ʟɪᴄᴇɴꜱᴇ: GNU General Public License v3.0
--          https://choosealicense.com/licenses/gpl-3.0/
-- ᴅᴇᴠᴇʟᴏᴘᴇʀ: TigoDevelopment
-- ᴘʀᴏᴊᴇᴄᴛ: FXCore
-- ᴠᴇʀꜱɪᴏɴ: 1.0.0
-- ᴅᴇꜱᴄʀɪᴘᴛɪᴏɴ: FiveM Framework
----------------------- [ ꜰxᴄᴏʀᴇ ] -----------------------

--
-- Custom function for try catch
-- @func function Function to call
-- @catch_func function Trigger when exception has been given
--
local function try(func, catch_func)
    local status, exception = pcall(func)

    if (not status) then
        catch_func(exception)
    end
end

-- Trim string
-- @value string String to trim
-- @result string String after trim
--
local function string_trim(value)
    if value then
		return (string.gsub(value, "^%s*(.-)%s*$", "%1"))
	else
		return nil
	end
end

--
-- Returns `true` if given object is nil or default
-- @value any Value that needs to be checked
-- @return boolean `true` if object is empty
--
local function isNullOrDefault(value)
    if (value == nil) then
        return true
    end

    local _type = type(value)

    if (_type == 'string' and (value == '' or string_trim(value) == '')) then
        return true
    end

    if (_type == 'number' and (value == 0 or tonumber(value) == 0)) then
        return true
    end

    if (_type == 'table') then
        if (#value > 0) then
            return false
        end

        for _key, _value in pairs(value or {}) do
            return false
        end

        return true
    end

    if (_type == 'boolean' and (value == 0 or not value or value == 'false' or tonumber(value) == 0)) then
        return true
    end

    return false
end

-- FiveM manipulation
_ENV.try = try
_G.try = try
_ENV.isNullOrDefault = isNullOrDefault
_G.isNullOrDefault = isNullOrDefault
_ENV.string.trim = string_trim
_G.string.trim = string_trim