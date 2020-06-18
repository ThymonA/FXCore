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

fx_version 'adamant'

game 'gta5'

description 'FXCore Framework'
name 'FXCore'
author 'TigoDevelopment'
contact 'me@tigodev.com'

version '1.0.0'

server_scripts {
    'lib/utils.lua',

    'vendors/class.lua',
    'vendors/stacktrace.lua',
    'vendors/regex.lua',

    'shared/common.lua',

    'lib/mysql.lua',
    'lib/error.lua',
    'lib/resource.lua',
    'lib/module.lua',
    'lib/database.lua',
    'lib/database/job.lua',
    'lib/database/user.lua',

    'data/database.lua',

    'server/main.lua'
}