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

Error = class()

--
-- Create a error message
--
function Error:Print(msg, resource, module)
    if (resource ~= nil and resource ~= '' and tostring(resource) ~= '') then
        resource = ('[ %s ] '):format(tostring(resource))
    else
        resource = ''
    end

    if (module ~= nil and module ~= '' and tostring(module) ~= '') then
        module = ('[ %s ] '):format(tostring(module))
    else
        module = ''
    end

    print(('[FXCore] [ERROR] %s%s> %s'):format(resource, module, msg))
end