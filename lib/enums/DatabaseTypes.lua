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

DatabaseType = class('DatabaseType')

-- Set default enum values
DatabaseType:set {
    values = {
        ['TINYINT']     = 'number',
        ['SMALLINT']    = 'number',
        ['MEDIUMINT']   = 'number',
        ['INT']         = 'number',
        ['BIGINT']      = 'number',
        ['DECIMAL']     = 'number',
        ['FLOAT']       = 'number',
        ['DOUBLE']      = 'number',
        ['BIT']         = 'number',
        ['BOOLEAN']     = 'boolean',
        ['BOOL']        = 'boolean',
        ['CHAR']        = 'string',
        ['VARCHAR']     = 'string',
        ['BINARY']      = 'string',
        ['VARBINARY']   = 'string',
        ['TINYBLOB']    = 'string',
        ['BLOB']        = 'string',
        ['MEDIUMBLOB']  = 'string',
        ['LONGBLOB']    = 'string',
        ['TINYTEXT']    = 'string',
        ['TEXT']        = 'string',
        ['MEDIUMTEXT']  = 'string',
        ['LONGTEXT']    = 'string',
        ['ENUM']        = 'string',
        ['SET']         = 'string',
        ['DATE']        = 'number',
        ['TIME']        = 'number',
        ['DATETIME']    = 'number',
        ['TIMESTAMP']   = 'number',
        ['YEAR']        = 'number',
        ['JSON']        = 'table'
    },
    default = 'string'
}

--
-- Returns value of given key
-- @key string Enum key
-- @return string Enum value or default
--
function DatabaseType:GetValue(key)
    if (isNullOrDefault(key)) then
        return DatabaseType.default
    end

    key = string.upper(string.trim(key))

    return DatabaseType.values[key] or DatabaseType.default
end

--
-- Returns value of given key
-- @key string Enum key
-- @value string Object type
-- @return boolean If value match with enum or default
--
function DatabaseType:Valid(key, value)
    if (isNullOrDefault(value)) then
        return false
    end

    local requiredValue = DatabaseType:GetValue(key)

    return string.lower(requiredValue) == string.lower(string.trim(value))
end