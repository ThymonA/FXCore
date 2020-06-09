--
-- Default FXCore Object
--
FXCore = {
    _ENV = _ENV,
    _G = _G,
    Resources = {},
    Modules = {},
    PreLoadedModules = {},
    IsWindows = true
}

--
-- Load all resources for FXCore and execute the code
--
FXCore.LoadResources = function()
    local resources = GetNumResources()

    for index = 0, resources, 1 do
        local resourceName = GetResourceByFindIndex(index)

        if (resourceName ~= nil and resourceName ~= '') then
            local files = FXCore.ScanDirectory(resourceName)

            for _, file in pairs(files or {}) do
                if (string.lower(file) == 'resource.json') then
                    local rawManifestInfo = LoadResourceFile(resourceName, 'resource.json')

                    if (not rawManifestInfo) then
                        rawManifestInfo = '{}'
                    end

                    local manifestInfo = json.decode(rawManifestInfo) or {}

                    if (not manifestInfo) then
                        manifestInfo = {}
                    end

                    table.insert(FXCore.Resources, {
                        name = resourceName,
                        dir = GetResourcePath(resourceName),
                        manifest = manifestInfo,
                        loaded = false
                    })
                end
            end
        end
    end

    FXCore._ENV._module = FXCore._Module
    FXCore._G._module = FXCore._Module

    for _, resource in pairs(FXCore.Resources or {}) do
        local serverScript = ''

        for _, serverFile in pairs(((resource or {}).manifest or {}).server_scripts or {}) do
            local code    = LoadResourceFile(resource.name, serverFile)

            if (not (not code)) then
                serverScript = serverScript .. code .. '\n'
            end
        end

        local fn      = load(serverScript, '@' .. resource.name .. ':server', 't', FXCore._ENV)
        local success = true

        local status, result = xpcall(fn, function(err)
            success = false

            print(err)
        end)

        resource.loaded = true
    end

    FXCore.LoadPreloadedModules()
end

--
-- Returns a list of files in root directory of resource
--
-- @param string Resource Name
-- @return string[] Filenames in root of resource
--
FXCore.ScanDirectory = function(resourceName)
    local resourcePath = GetResourcePath(resourceName)

    if (FXCore.IsWindows) then
        local result = {}

        for dir in io.popen(('dir "%s" /b'):format(resourcePath)):lines() do
            table.insert(result, dir)
        end

        return result
    end

    return {}
end

--
-- Returns `true` if all resources are loaded and `false` if any resource hasn't loaded
--
-- @return boolean All resource Loaded
--
FXCore.AllResourcesLoaded = function()
    for _, resource in pairs(FXCore.Resources or {}) do
        if (not resource.loaded) then
            return false
        end
    end

    return true
end

--
-- Execute when citizen thread is ready
--
Citizen.CreateThread(function()
    Citizen.Wait(0)

    FXCore.LoadResources()
end)