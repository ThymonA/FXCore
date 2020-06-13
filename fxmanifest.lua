fx_version 'adamant'

game 'gta5'

description 'FXCore Framework'
name 'FXCore'
author 'TigoDevelopment'
contact 'me@tigodev.com'

version '1.0.0'

server_scripts {
    'vendors/class.lua',
    'vendors/stacktrace.lua',

    'shared/common.lua',

    'lib/error.lua',
    'lib/resource.lua',
    'lib/module.lua',

    'server/main.lua'
}