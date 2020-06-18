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

Error = class('Error')

--
-- Log a error in file `fxcore_error.log`
-- @msg string Error Message
-- @resource string Resource name
-- @module string Module name
--
function Error:Log(msg, resource, module)
    if (not isNullOrDefault(resource)) then
        resource = (' [%s]'):format(tostring(resource))
    elseif (not isNullOrDefault(CurrentFrameworkResource)) then
        resource = (' [%s]'):format(tostring(CurrentFrameworkResource))
    else
        resource = ''
    end

    if (not isNullOrDefault(module)) then
        module = (' (%s)'):format(tostring(module))
    elseif (not isNullOrDefault(CurrentFrameworkModule)) then
        module = (' (%s)'):format(tostring(CurrentFrameworkModule))
    else
        module = ''
    end

    local currentFile = LoadResourceFile(GetCurrentResourceName(), 'fxcore_error.log') or ''

    if (currentFile) then
    else
        currentFile = ''
    end

    local date_table = os.date("*t")
    local hour, minute, second = date_table.hour, date_table.min, date_table.sec
    local year, month, day = date_table.year, date_table.month, date_table.day
    local timestring = tostring(year)

    if (month < 10) then
        timestring = ('%s-0%s'):format(timestring, month)
    else
        timestring = ('%s-%s'):format(timestring, month)
    end

    if (day < 10) then
        timestring = ('%s-0%s'):format(timestring, day)
    else
        timestring = ('%s-%s'):format(timestring, day)
    end

    if (hour < 10) then
        timestring = ('%s 0%s'):format(timestring, hour)
    else
        timestring = ('%s %s'):format(timestring, hour)
    end

    if (minute < 10) then
        timestring = ('%s:0%s'):format(timestring, minute)
    else
        timestring = ('%s:%s'):format(timestring, minute)
    end

    if (second < 10) then
        timestring = ('%s:0%s'):format(timestring, second)
    else
        timestring = ('%s:%s'):format(timestring, second)
    end

    local newData = ('%s%s ERROR%s%s %s\n'):format(currentFile, timestring, resource, module, msg)

    SaveResourceFile(GetCurrentResourceName(), 'fxcore_error.log', newData)
end

--
-- Create a error message
-- @msg string Error Message
-- @resource string Resource name
-- @module string Module name
--
function Error:Print(msg, resource, module)
    Error:Log(msg, resource, module)

    if (not isNullOrDefault(resource)) then
        resource = ('[+] RESOURCE:                  %s\n'):format(tostring(resource))
    elseif (not isNullOrDefault(CurrentFrameworkResource)) then
        resource = ('[+] RESOURCE:                  %s\n'):format(tostring(CurrentFrameworkResource))
    else
        resource = ''
    end

    if (not isNullOrDefault(module)) then
        module = ('[+] MODULE:                       %s\n'):format(tostring(module))
    elseif (not isNullOrDefault(CurrentFrameworkModule)) then
        module = ('[+] MODULE:                       %s\n'):format(tostring(CurrentFrameworkModule))
    else
        module = ''
    end

    local errorType = 'MODULE'

    if (module == '' and resource ~= '') then
        errorType = 'RESOURCE'
    elseif (module == '' and resource == '') then
        errorType = 'FRAMEWORK'
    end

    print(('[+] ---------------------------------------------------------------------------\n%s%s\n[+] ERROR TYPE:               %s\n[+] ERROR:                         %s\n[+] ---------------------------------------------------------------------------'):format(resource, module, errorType, msg))
end