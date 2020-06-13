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

Resource = class()

-- Set default values
Resource:set {
    Resources = {}
}

--
-- Returns `true` if resource exits
-- @module string Resource name
-- @return boolean `true` if resource exists
function Resource:Exists(resourceName)
    if (resourceName == nil or tostring(resourceName) == '') then
        return false
    end

    resourceName = string.lower(tostring(resourceName))

    return Resource.Resources[resourceName] ~= nil
end

--
-- Returns `true` if resource is loaded
-- @module string Resource name
-- @return boolean `true` if resource is loaded
function Resource:IsLoaded(resourceName)
    if (resourceName == nil or tostring(resourceName) == '') then
        return true
    end

    resourceName = string.lower(tostring(resourceName))

    if (Resource:Exists(resourceName)) then
        return not (not Resource.Resources[resourceName].loaded or false)
    end
end

--
-- Returns a list of files in root directory of given resource
-- @resourceName string Name of the resource
-- @return array List of files in root directory
--
function Resource:GetResourceFiles(resourceName)
    if (resourceName == nil or tostring(resourceName) == '') then
        return false
    end

    local results, resourcePath = {}, GetResourcePath(resourceName)

    if ((string.lower(OS) == 'win' or string.lower(OS) == 'windows') and resourcePath ~= nil) then
        for _file in io.popen(('dir "%s" /b'):format(resourcePath)):lines() do
            table.insert(results, _file)
        end
    elseif ((string.lower(OS) == 'lux' or string.lower(OS) == 'linux') and resourcePath ~= nil) then
        for _file in io.popen(('ls %s'):format(resourcePath)):lines() do
            table.insert(results, _file)
        end
    end

    return results
end

--
-- Returns `true` if given resource is a framework resource
-- @resourceName string Name of the resource
-- @return boolean `true` if resource is framework resource
--
function Resource:IsFrameworkResource(resourceName)
    local resourceFiles = Resource:GetResourceFiles(resourceName)

    for _, file in pairs(resourceFiles or {}) do
        if (string.lower(file) == 'fxcore.json') then
            return true, resourceFiles
        end
    end

    return false, '/'
end

--
-- Returns a list of framework resources
-- @return array List of framework resources
--
function Resource:GetResources()
    local results = {}
    local resources = GetNumResources()

    for index = 0, resources, 1 do
        local resourceName = GetResourceByFindIndex(index)
        local isFrameworkResource, resourcePath = Resource:IsFrameworkResource(resourceName)

        if (isFrameworkResource) then
            local _object = class()

            _object:set {
                name = resourceName,
                path = resourcePath
            }

            table.insert(results, _object)
        end
    end

    return results
end

--
-- Generates a manifest object for resource
-- @resourceName string Resource name
-- @data array Raw json data from resource
-- @return object Resource manifest object
--
function Resource:GenerateManifestInfo(resourceName, data)
    local _manifest = class()

    _manifest:set {
        name = resourceName,
        raw = data
    }

    for key, value in pairs(data) do
        if (key ~= nil) then
            _manifest:set(key, value)
        end
    end

    function _manifest:GetValue(key)
        if (key == nil or tostring(key) == '') then
            return nil
        end

        if (_manifest.raw ~= nil and _manifest.raw[key] ~= nil) then
            return _manifest.raw[key]
        end

        return nil
    end

    return _manifest
end

--
-- Returns a manifest for given resource
-- @resourceName string Resource name
-- @return object Resource manifest object
--
function Resource:GetManifestInfo(resourceName)
    if (resourceName == nil or tostring(resourceName) == '') then
        return Resource:GenerateManifestInfo(resourceName, {})
    end

    local content = LoadResourceFile(resourceName, 'fxcore.json')

    if (content) then
        local data = json.decode(content)

        if (data) then
            return Resource:GenerateManifestInfo(resourceName, data)
        end
    end

    return Resource:GenerateManifestInfo(resourceName, {})
end

--
-- Execute all framework resources
--
function Resource:ExecuteResources()
    local resources = Resource:GetResources()

    for _, resource in pairs(resources or {}) do
        if (not Resource:IsLoaded(resource.name)) then
            local manifest = Resource:GetManifestInfo(resource.name)
            local script = ''
            local _type = 'client'

            if (SERVER) then
                _type = 'server'
            end

            for _, _file in pairs(manifest:GetValue(('%s_scripts'):format(_type)) or {}) do
                local code = LoadResourceFile(resource.name, _file)

                if (code) then
                    script = script .. code .. '\n'
                end
            end

            _ENV.CurrentFrameworkResource = resource.name

            local fn = load(script, ('@%s:%s'):format(resource.name, _type), 't', _ENV)

            xpcall(fn, function(err)
                Error:Print(err, resource.name)
            end)

            if (not Resource:Exists(resource.name)) then
                local _object = resource:extend()

                _object:set {
                    manifest = manifest,
                    loaded = true
                }

                local resourceName = string.lower(tostring(resource.name))

                Resource.Resources[resourceName] = _object
            end
        end
    end

    _ENV.CurrentFrameworkResource = nil
    _ENV.CurrentFrameworkModule = nil
end