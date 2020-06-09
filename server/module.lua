--
-- Will be triggerd when any code is calling _module(...)
--
-- @param string Module Name
-- @param function Function that returns a object
--
FXCore._Module = function(name, func)
    if (FXCore.Modules == nil) then
        FXCore.Modules = {}
    end

    if (FXCore.Modules[string.lower(name)] ~= nil) then
        print('[FXCore] Module: ' .. name .. ' has already been loaded and can\'t be overridden')
        return
    end

    local info = debug.getinfo(func)
    local numberOfParameters = info.nparams or 0

    if (numberOfParameters <= 0) then
        FXCore.Modules[string.lower(name)] = func()
    else
        local params = {}

        for i = 1, numberOfParameters, 1 do
            local variableName = debug.getlocal(func, i)

            if (variableName == nil and variableName == '') then
                print('[FXCore] Module: ' .. name .. ' failed to load, empty variable has been found index: #' .. i)
                return
            end

            local variableExits = FXCore.Modules[string.lower(variableName)] ~= nil

            if (not variableExits) then
                local parameters = {}

                for y = 1, numberOfParameters, 1 do
                    parameters[y] = debug.getlocal(func, y)
                end

                FXCore.PreLoadedModules[string.lower(name)] = {
                    params = parameters,
                    name = string.lower(name),
                    loaded = false,
                    error = false,
                    func = func
                }
                return
            else
                table.insert(params, FXCore.Modules[string.lower(variableName)])
            end
        end

        FXCore.Modules[string.lower(name)] = func(table.unpack(params))
    end
end

--
-- Load all modules that could not be loaded and try to load them later
--
FXCore.LoadPreloadedModules = function()
    Citizen.CreateThread(function()
        Citizen.Wait(0)

        for moduleName, module in pairs(FXCore.PreLoadedModules or {}) do
            if (not module.loaded and not module.error) then
                for i, param in pairs(module.params or {}) do
                    if (string.lower(param) == string.lower(moduleName)) then
                        FXCore.PreLoadedModules[moduleName].error = true

                        print('[FXCore] Module: ' .. moduleName .. ' failed to load, one of the dependencies refers to module itself, index #' .. i)
                    else
                        local paramExits = false

                        if (FXCore.Modules ~= nil and FXCore.Modules[string.lower(param)] ~= nil) then
                            paramExits = true
                        end

                        for _, moduleInfo in pairs(FXCore.PreLoadedModules or {}) do
                            if (string.lower(moduleInfo.name) == string.lower(param)) then
                                paramExits = true

                                if (not (not moduleInfo.error)) then
                                    FXCore.PreLoadedModules[moduleName].error = true

                                    print('[FXCore] Module: ' .. moduleName .. ' failed to load, dependency ' .. param .. ' has failed to load, index #' .. i)
                                end
                            end
                        end

                        if (not paramExits) then
                            FXCore.PreLoadedModules[moduleName].error = true

                            print('[FXCore] Module: ' .. moduleName .. ' failed to load, dependency ' .. param .. ' doesn\'t exists, index #' .. i)
                        else
                            local paramIsPreLoaded = FXCore.PreLoadedModules[string.lower(param)] ~= nil

                            if (paramIsPreLoaded) then
                                local preloadedParams = FXCore.PreLoadedModules[string.lower(param)].params or {}

                                for _, preloadParam in pairs(preloadedParams or {}) do
                                    if (string.lower(preloadParam) == string.lower(moduleName)) then
                                        FXCore.PreLoadedModules[moduleName].error = true

                                        print('[FXCore] Module: ' .. moduleName .. ' failed to load, dependency ' .. preloadParam .. ' causes a dependency loop, index #' .. i)
                                    end
                                end
                            end
                        end
                    end
                end

                if (not FXCore.PreLoadedModules[moduleName].error) then
                    FXCore.PreLoadedModules[moduleName].loaded = true
                    FXCore._Module(module.name, module.func)
                end
            end
        end

        local anyModuleNotLoaded = false

        for _, module in pairs(FXCore.PreLoadedModules or {}) do
            if (not module.loaded and not module.error) then
                anyModuleNotLoaded = true
            end
        end

        Citizen.Wait(10000)

        if (anyModuleNotLoaded) then
            FXCore.LoadPreloadedModules()
        end
    end)
end