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

Database = class('Database')

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

--
-- Create a table if not exits or update a table if exits
-- @tableName string Table name
-- @columns array List of columns for tables
-- @rows array List of default rows to insert
--
function Database:InitializeTable(tableName, columns, rows)
    if (isNullOrDefault(tableName)) then error('[DB] Table name is required') return end
    if (isNullOrDefault(columns)) then error('[DB] Columns is required') return end
    if (type(tableName) ~= 'string') then error('[DB] Table name must be a string') return end
    if (type(columns) ~= 'table') then error('[DB] Columns must be a table') return end
    if (type(rows) ~= 'table' and type(rows) ~= 'nil') then error('[DB] Rows must be a table') return end

    table.insert(Database.Queue, {
        name = tableName,
        columns = columns,
        rows = rows
    })
end

--
-- Create a query for adding new tables
-- @tableName string Table name
-- @columns array List of columns for tables
-- @return string Database CREATE TABLE query
--
function Database:CreateNewTableQuery(tableName, columns)
    if (isNullOrDefault(tableName)) then error('[DB] Table name is required') return end
    if (isNullOrDefault(columns)) then error('[DB] Columns is required') return end
    if (type(tableName) ~= 'string') then error('[DB] Table name must be a string') return end
    if (type(columns) ~= 'table') then error('[DB] Columns must be a table') return end

    local primaries = {}
    local uniques = {}
    local foreign_keys = {}
    local query = ('CREATE TABLE IF NOT EXISTS `%s` ('):format(tableName)

    for name, column in pairs(columns or {}) do
        local column_data = {
            name = name or '',
            primary = column.primary or false,
            unique = column.unique or false,
            required = column.required or false,
            type = column.type or 'VARCHAR',
            length = column.length or 0,
            default = column.default or nil,
            foreign_key = column.foreign_key or nil,
            extra = column.extra or nil
        }

        if (column_data.foreign_key ~= nil) then
            local foreign_key_data = {
                table = column_data.foreign_key.table or '',
                column = column_data.foreign_key.column or ''
            }

            if (Database.Tables[foreign_key_data.name] == nil and 1 == 2) then
                error(('[DB] Column `%s` contains foreign key to a non existing table `%s`'):format(column_data.name, foreign_key_data.name))
                return
            end

            query = ('%s\n    `%s` INT'):format(query, column_data.name)

            table.insert(foreign_keys, {
                name = column_data.name,
                table = foreign_key_data.table,
                column = foreign_key_data.column
            })
        else
            query = ('%s\n    `%s` %s'):format(query, column_data.name, column_data.type)

            if (column_data.length > 0) then
                query = ('%s(%s)'):format(query, column_data.length)
            end
        end

        if (column_data.required) then
            query = ('%s NOT NULL'):format(query, column_data.length)
        end

        if (column_data.default and isNullOrDefault(column_data.foreign_key)) then
            query = ("%s DEFAULT '%s'"):format(query, column_data.default)
        end

        if (column_data.extra) then
            query = ('%s %s'):format(query, column_data.extra)
        end

        if (column_data.primary) then
            table.insert(primaries, column_data)
        end

        if (column_data.unique) then
            table.insert(uniques, column_data)
        end

        query = ('%s,'):format(query)
    end

    if (#primaries > 1) then
        error(('[DB] Table `%s` contains more than one primary key'):format(tableName))
    elseif (#primaries > 0) then
        query = ('%s\n    PRIMARY KEY (`%s`),'):format(query, primaries[1].name)
    end

    if (#foreign_keys > 0) then
        for _, foreign_key_data in pairs(foreign_keys or {}) do
            query = ('%s\n    FOREIGN KEY (`%s`) REFERENCES `%s`(`%s`),'):format(query, foreign_key_data.name, foreign_key_data.table, foreign_key_data.column)
        end
    end

    if (#uniques > 0) then
        query = ("%s\n    CONSTRAINT `UC_%s` UNIQUE ("):format(query, tableName)

        for i = 1, #uniques, 1 do
            if (i < #uniques) then
                query = ('%s`%s`,'):format(query, uniques[i].name)
            else
                query = ('%s`%s`),'):format(query, uniques[i].name)
            end
        end
    end

    query = string.sub(query, 1, -2)
    query = ('%s\n);'):format(query)

    return query
end

--
-- Generate a class for table
-- @tableName string Table name
-- @columns array List of columns of table
-- @return object Table object
--
function Database:CreateTableClass(tableName, columns)
    if (isNullOrDefault(tableName)) then error('[DB] Table name is required') return end
    if (isNullOrDefault(columns)) then error('[DB] Columns is required') return end
    if (type(tableName) ~= 'string') then error('[DB] Table name must be a string') return end
    if (type(columns) ~= 'table') then error('[DB] Columns must be a table') return end

    for name, column in pairs(columns or {}) do
        local _type = column.type or 'VARCHAR'
        local luaType = DatabaseType:GetValue(_type)
    end
end

-- Set default values
Database:set {
    Database = Database:GetDatabaseName(),
    IsReady = false,
    Tables = {},
    Queue = {}
}

-- Set ready statement when MySQL is ready
MySQL:Ready(function()
    Database.IsReady = MySQL.IsReady
end)

-- Add missing tables to database
Citizen.CreateThread(function()
    while true do
        if (#Database.Queue > 0 and Database.IsReady) then
            for _, queue in pairs(Database.Queue) do
                local createTableQuery = Database:CreateNewTableQuery(queue.name, queue.columns)
                local done = false
                local missingForeingKey = false

                for _, column in pairs(queue.columns or {}) do
                    if (column.foreign_key ~= nil and Database.Tables[(column.foreign_key.table or '')] ~= nil) then
                    elseif (column.foreign_key ~= nil) then
                        missingForeingKey = true
                    end
                end

                if (not missingForeingKey) then
                    MySQL:Execute(createTableQuery, {}, function()
                        done = true
                    end)

                    repeat Citizen.Wait(0) until done == true

                    Database.Tables[queue.name] = {}

                    print(('[DB] Table `%s` has been created and added to database `%s`'):format(queue.name, Database.Database))

                    table.remove(Database.Queue, _)
                end
            end

            Citizen.Wait(0)
        else
            Citizen.Wait(100)
        end
    end
end)