----------------------- [ ꜰxᴄᴏʀᴇ ] -----------------------
-- ɢɪᴛʟᴀʙ: https://git.tigodev.com/Tigo/fx_core
-- ɢɪᴛʜᴜʙ: https://github.com/TigoDevelopment/fx_core
-- ʟɪᴄᴇɴꜱᴇ: GNU General Public License v3.0
--          https://choosealicense.com/licenses/gpl-3.0/
-- ᴅᴇᴠᴇʟᴏᴘᴇʀ: TigoDevelopment
-- ᴘʀᴏᴊᴇᴄᴛ: FXCore
-- ᴠᴇʀꜱɪᴏɴ: 1.0.0
-- ᴅᴇꜱᴄʀɪᴘᴛɪᴏɴ: FiveM Framework
----------------------- [ ꜰxᴄᴏʀᴇ ] -----------------------

Database = class()

--
-- Get all table from database
-- @return array List of database tables
--
function Database:GetAllTables()
    return MySQL:FetchAll("SELECT `TABLE_NAME` AS `name` FROM INFORMATION_SCHEMA.TABLES WHERE `TABLE_SCHEMA` = @database GROUP BY `TABLE_NAME`", {
        ['database'] = Database.Database
    })
end

--
-- Return current database name
-- @return string Database name
--
function Database:GetDatabaseName()
    local databaseConnecting = GetConvar('mysql_connection_string', '')

    if (databaseConnecting == '' or type(databaseConnecting) ~= 'string') then
        return nil
    end

    local _regex = regex.compile('(database)=(.*?);')
    local search = _regex:search(databaseConnecting)

    if (search ~= nil and search.submatches ~= nil and search.submatches[2] ~= nil) then
        local database = string.sub(databaseConnecting, search.submatches[2][1], search.submatches[2][2])

        database = string.gsub(database, '%;', '')

        return database
    end

    return nil
end

-- Set default values
Database:set {
    Database = Database:GetDatabaseName()
}

MySQL:Ready(function()
    local tables = Database:GetAllTables()

    for _, table in pairs(tables or {}) do
        print(table.name)
    end
end)