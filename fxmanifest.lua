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
    'vendors/mysql-async/mysql-async.js',
    'vendors/mysql-async/MySQL.lua',
    'vendors/regex.lua',

    'shared/common.lua',

    'lib/error.lua',
    'lib/resource.lua',
    'lib/module.lua',
    'lib/database.lua',

    'server/main.lua'
}