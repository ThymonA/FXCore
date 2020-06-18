----------------------- [ ꜰxᴄᴏʀᴇ ] -----------------------
-- ɢɪᴛʜᴜʙ: https://github.com/brouznouf/fivem-mysql-async
-- ʟɪᴄᴇɴꜱᴇ: MIT License
-- ᴅᴇᴠᴇʟᴏᴘᴇʀ: brouznouf
-- ᴘʀᴏᴊᴇᴄᴛ: fivem-mysql-async
-- ᴠᴇʀꜱɪᴏɴ: 3.2.3
-- ᴅᴇꜱᴄʀɪᴘᴛɪᴏɴ: MySql Async Library for FiveM
----------------------- [ ꜰxᴄᴏʀᴇ ] -----------------------

MySQL = class()

-- Set default vaule
MySQL:set {
    IsReady = false
}

--
-- Change parameters to safe parameters
-- @params array Parameters
-- @return array Safe Parameters
--
function MySQL:SafeParameters(params)
    if isNullOrDefault(params) then
        return {[''] = ''}
    end

    assert(type(params) == "table", "A table is expected")
    assert(params[1] == nil, "Parameters should not be an array, but a map (key / value pair) instead")

    if next(params) == nil then
        return {[''] = ''}
    end

    return params
end

--
-- Execute query on database
-- @query string Query to be executed
-- @params array Parameters for query
-- @callback function Function to be called
--
function MySQL:Execute(query, params, callback)
    assert(type(query) == "string", ("The SQL Query must be a string, type is now %s"):format(type(query)))

    if (callback) then
        exports['mysql-async']:mysql_execute(query, MySQL:SafeParameters(params), callback)
    else
        local res = 0;
        local finishedQuery = false

        exports['mysql-async']:mysql_execute(query, MySQL:SafeParameters(params), function(result)
            res = result
            finishedQuery = true
        end)

        repeat Citizen.Wait(0) until finishedQuery == true

        return res
    end
end

--
-- Fetch all query on database
-- @query string Query to be executed
-- @params array Parameters for query
-- @callback function Function to be called
--
function MySQL:FetchAll(query, params, callback)
    assert(type(query) == "string", ("The SQL Query must be a string, type is now %s"):format(type(query)))

    if (callback) then
        exports['mysql-async']:mysql_fetch_all(query, MySQL:SafeParameters(params), callback)
    else
        local res = {};
        local finishedQuery = false

        exports['mysql-async']:mysql_fetch_all(query, MySQL:SafeParameters(params), function(result)
            res = result
            finishedQuery = true
        end)

        repeat Citizen.Wait(0) until finishedQuery == true

        return res
    end
end

--
-- Fetch scalar query on database
-- @query string Query to be executed
-- @params array Parameters for query
-- @callback function Function to be called
--
function MySQL:FetchScalar(query, params, callback)
    assert(type(query) == "string", ("The SQL Query must be a string, type is now %s"):format(type(query)))

    if (callback) then
        exports['mysql-async']:mysql_fetch_scalar(query, MySQL:SafeParameters(params), callback)
    else
        local res = '';
        local finishedQuery = false

        exports['mysql-async']:mysql_fetch_scalar(query, MySQL:SafeParameters(params), function(result)
            res = result
            finishedQuery = true
        end)

        repeat Citizen.Wait(0) until finishedQuery == true

        return res
    end
end

--
-- Fetch scalar query on database
-- @query string Query to be executed
-- @params array Parameters for query
-- @callback function Function to be called
--
function MySQL:FetchFirst(query, params, callback)
    assert(type(query) == "string", ("The SQL Query must be a string, type is now %s"):format(type(query)))

    if (callback) then
        exports['mysql-async']:mysql_fetch_first(query, MySQL:SafeParameters(params), callback)
    else
        local res = '';
        local finishedQuery = false

        exports['mysql-async']:mysql_fetch_first(query, MySQL:SafeParameters(params), function(result)
            res = result
            finishedQuery = true
        end)

        repeat Citizen.Wait(0) until finishedQuery == true

        return res
    end
end

--
-- Insert query on database
-- @query string Query to be executed
-- @params array Parameters for query
-- @callback function Function to be called
--
function MySQL:Insert(query, params, callback)
    assert(type(query) == "string", ("The SQL Query must be a string, type is now %s"):format(type(query)))

    if (callback) then
        exports['mysql-async']:mysql_insert(query, MySQL:SafeParameters(params), callback)
    else
        local res = 0;
        local finishedQuery = false

        exports['mysql-async']:mysql_insert(query, MySQL:SafeParameters(params), function(result)
            res = result
            finishedQuery = true
        end)

        repeat Citizen.Wait(0) until finishedQuery == true

        return res
    end
end

--
-- Execute multiple queries as one transaction
-- @queries string Query to be executed
-- @params array Parameters for query
-- @callback function Function to be called
--
function MySQL:Transaction(queries, params, callback)
    assert(type(queries) == "table", ("The SQL Queries must be a table, type is now %s"):format(type(queries)))

    if (callback) then
        exports['mysql-async']:mysql_transaction(queries, MySQL:SafeParameters(params), callback)
    else
        local res = 0;
        local finishedQuery = false

        exports['mysql-async']:mysql_transaction(queries, MySQL:SafeParameters(params), function(result)
            res = result
            finishedQuery = true
        end)

        repeat Citizen.Wait(0) until finishedQuery == true

        return res
    end
end

--
-- Trigger function when ready
-- @callback function Function to be triggerd when ready
--
function MySQL:Ready(callback)
    Citizen.CreateThread(function ()
        while GetResourceState('mysql-async') ~= 'started' do
            Citizen.Wait(0)
        end

        while not exports['mysql-async']:is_ready() do
            Citizen.Wait(0)
        end

        try(callback, function(e)
            Error:Print(e)
        end)
    end)
end

--
-- Change ready statement when ready
--
MySQL:Ready(function()
    MySQL.IsReady = true
end)