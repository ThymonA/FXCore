MySQL = class()

-- Set default vaule
MySQL:set {
    ResourceName = GetCurrentResourceName(),
    IsReady = false
}

--
-- Change parameters to safe parameters
-- @params array Parameters
-- @return array Safe Parameters
--
function MySQL:SafeParameters(params)
    if nil == params then
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
    assert(type(query) == "string", "The SQL Query must be a string")

    if (callback) then
        exports[MySQL.ResourceName]:mysql_execute(query, MySQL:SafeParameters(params), callback)
    else
        local res = 0;
        local finishedQuery = false

        exports[MySQL.ResourceName]:mysql_execute(query, MySQL:SafeParameters(params), function(result)
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
    assert(type(query) == "string", "The SQL Query must be a string")

    if (callback) then
        exports[MySQL.ResourceName]:mysql_fetch_all(query, MySQL:SafeParameters(params), callback)
    else
        local res = {};
        local finishedQuery = false

        exports[MySQL.ResourceName]:mysql_fetch_all(query, MySQL:SafeParameters(params), function(result)
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
    assert(type(query) == "string", "The SQL Query must be a string")

    if (callback) then
        exports[MySQL.ResourceName]:mysql_fetch_scalar(query, MySQL:SafeParameters(params), callback)
    else
        local res = '';
        local finishedQuery = false

        exports[MySQL.ResourceName]:mysql_fetch_scalar(query, MySQL:SafeParameters(params), function(result)
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
    assert(type(query) == "string", "The SQL Query must be a string")

    if (callback) then
        exports[MySQL.ResourceName]:mysql_insert(query, MySQL:SafeParameters(params), callback)
    else
        local res = 0;
        local finishedQuery = false

        exports[MySQL.ResourceName]:mysql_insert(query, MySQL:SafeParameters(params), function(result)
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
    assert(type(queries) == "table", "The SQL queries must be a table")

    if (callback) then
        exports[MySQL.ResourceName]:mysql_transaction(queries, MySQL:SafeParameters(params), callback)
    else
        local res = 0;
        local finishedQuery = false

        exports[MySQL.ResourceName]:mysql_transaction(queries, MySQL:SafeParameters(params), function(result)
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
        while GetResourceState(MySQL.ResourceName) ~= 'started' do
            Citizen.Wait(0)
        end

        while not exports[MySQL.ResourceName]:is_ready() do
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