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

Module = class()

-- Set default values
Module:set {
    Modules = {}
}

--
-- Returns a list of framework modules
-- @return array List of framework modules
--
function Module:GetModules()
    return Module.Modules or {}
end

--
-- Returns `true` if module exits
-- @module string Module name
-- @return boolean `true` if module exists
function Module:Exists(_module)
    if (_module == nil or tostring(_module) == '') then
        return false
    end

    _module = string.lower(tostring(_module))

    return Module:GetModules()[_module] ~= nil
end

--
-- Returns `true` if given resource is a framework module
-- @resourceName string Name of the resource
-- @return boolean `true` if resource is framework module
--
function Module:IsResourceAModule(resourceName)
    if (resourceName == nil or tostring(resourceName) == '') then
        return false
    end

    resourceName = string.lower(tostring(resourceName))

    for _, _module in pairs(Module.Modules or {}) do
        if (_module.resource == resourceName) then
            return true
        end
    end

    return false
end

--
-- Returns a module object
-- @name string Name of module
-- @func function Module function
-- @info array Function information
-- @return object Module object
--
function Module:Create(name, func)
    local info = debug.getinfo(func)
    local numberOfParameters = info.nparams or 0
    local params = {}

    if (numberOfParameters > 0) then
        for i = 1, numberOfParameters, 1 do
            local paramName = debug.getlocal(func, i)

            if (isNullOrDefault(paramName)) then
                error(('Dependency at index #%s is empty'):format(i), 4)
                return
            end

            if (string.lower(name) == string.lower(paramName)) then
                error(('Dependency refers to module itself at index #%s'):format(i), 4)
                return
            end

            table.insert(params, paramName)
        end
    end

    local _object = class()

    --
    -- Default module variables
    --
    _object:set {
        name = name,
        resource = CurrentFrameworkResource,
        func = func,
        loaded = false,
        error = false,
        params = params,
        value = nil
    }

    --
    -- Returns `true` if module is loaded and available
    --
    function _object:IsLoaded()
        return self.loaded or false
    end

    --
    -- Returns `true` if module has a error
    --
    function _object:HasError()
        return self.error or false
    end

    --
    -- Returns `true` if module can been started, `false` if module can't be started
    -- Change `error` state when module can't start because of missing dependencies
    --
    function _object:CanStart()
        if (#self.params <= 0) then
            return true
        end

        for i, param in pairs(self.params or {}) do
            local key = string.lower(tostring(param))
            local _module = (Module.Modules or {})[key] or nil

            if (not isNullOrDefault(_module)) then
                if (not _module:IsLoaded() and _module:HasError()) then
                    self.error = true

                    Error:Print(("Dependency '%s' at index #%s failed to load, module can't be started"):format(_module.name, i), self.resource, self.name)

                    return false
                elseif (not _module:IsLoaded()) then
                    return false
                end
            elseif (Resource.AllResourcesLoaded) then
                self.error = true

                Error:Print(("Dependency '%s' at index #%s failed to load, module doesn't exists"):format(key, i), self.resource, self.name)

                return false
            else
                return false
            end
        end

        return true
    end

    --
    -- Returns module
    --
    function _object:Get()
        return self.value or nil
    end

    --
    -- Execute module code
    --
    function _object:Execute()
        if (self:IsLoaded() or self:HasError()) then
            return
        end

        if (func ~= nil and self:CanStart()) then
            if (#self.params <= 0) then
                self.value = self.func()
            else
                local _params = {}

                for _, param in pairs(self.params or {}) do
                    local key = string.lower(tostring(param))
                    local _module = ((Module.Modules or nil)[key] or nil) or nil

                    if (not isNullOrDefault(_module)) then
                        table.insert(_params, _module:Get())
                    else
                        table.insert(_params, nil)
                    end
                end

                self.value = self.func(table.unpack(_params))
            end
        else
            error(("Can't start module '%s'"):format(self.name or 'unknown'))
        end
    end

    return _object
end

--
-- Load a framework module
-- @name string Name of module
-- @func function Function to load module
--
function Module:Load(name, func, override)
    local key = string.lower(tostring(name))

    try(function()
        _ENV.CurrentFrameworkModule = name

        if (isNullOrDefault(name)) then
            error('Module name is required', 3)
            return
        end

        override = not (not override or false)

        if (not override and Module:Exists(name)) then
            error(("Module %s has already been registerd"):format(name), 3)
            return
        end

        local _module = Module:Create(name, func)

        Module.Modules[key] = _module

        if (_module:CanStart()) then
            _module:Execute()
        end
    end, function(e)
        if (Module.Modules[key] ~= nil) then
            Module.Modules[key].error = true

            Error:Print(e, Module.Modules[key].resource, Module.Modules[key].name)
        else
            Error:Print(e, nil, key)
        end
    end)
end

--
-- Load all modules and start missing modules
--
function Module:LoadModules()
    Citizen.CreateThread(function()
        for moduleName, _module in pairs(Module.Modules or {}) do
            if (not _module:HasError() and not _module:IsLoaded()) then
                _ENV.CurrentFrameworkResource = _module.resource
                _ENV.CurrentFrameworkModule = _module.name

                try(function()
                    if (_module:CanStart()) then
                        _module:Execute()
                    end
                end, function(e)
                    Module.Modules[moduleName].error = true

                    Error:Print(e, _module.resource, _module.name)
                end)
            end
        end

        _ENV.CurrentFrameworkResource = nil
        _ENV.CurrentFrameworkModule = nil

        Citizen.Wait(5000)

        Module:LoadModules()
    end)
end

--
-- Returns module if exsits
-- @module string Module name
--
function Module:Get(moduleName)
    if (isNullOrDefault(moduleName)) then
        return nil
    end

    local key = string.lower(tostring(moduleName))

    if (Module:Exists(key)) then
        local _module = Module.Modules[key]

        if (_module:IsLoaded()) then
            return _module:Get()
        end

        if (Module:HasError()) then
            return nil
        end

        Citizen.Wait(500)

        return Module:Get(moduleName)
    end

    return nil
end

-- FiveM manipulation
_ENV.module = function(name, func, override) Module:Load(name, func, override) end
_G.module = function(name, func, override) Module:Load(name, func, override) end
_ENV.m = function(moduleName) return Module:Get(moduleName) end
_G.m = function(moduleName) return Module:Get(moduleName) end