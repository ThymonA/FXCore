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
function Module:Exists(module)
    if (module == nil or tostring(module) == '') then
        return false
    end

    module = string.lower(tostring(module))

    return Module:GetModules()[module] ~= nil
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

    for _, module in pairs(Module.Modules or {}) do
        if (module.resource == resourceName) then
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

            if (paramName == nil and paramName == '') then
                error(('Variable at index #%s is empty'):format(i))
                return
            end

            if (string.lower(name) == string.lower(paramName)) then
                error(('Dependency refers to module itself at index #%s'):format(i))
                return
            end

            table.insert(params, paramName)
        end
    end

    local _object = class()

    _object:set {
        name = name,
        resource = CurrentFrameworkResource,
        func = func,
        loaded = false,
        error = false,
        params = params,
        value = nil
    }

    function _object:IsLoaded()
        return self.loaded or false
    end

    function _object:CanStart()
        if (#self.params <= 0) then
            return true
        end

        return false
    end

    return _object
end

--
-- Load a framework module
-- @name string Name of module
-- @func function Function to load module
--
function Module:Load(name, func, override)
    if (name == nil or tostring(name) == '' or name == '') then
        error('Module name is required', 3)
        return
    end

    override = not (not override or false)

    if (not override and Module:Exists(name)) then
        error(("Module %s has already been registerd"):format(name), 3)
        return
    end

    local module = Module:Create(name, func)
end

-- FiveM manipulation
_ENV.module = function(name, func, override) Module:Load(name, func, override) end
_G.module = function(name, func, override) Module:Load(name, func, override) end