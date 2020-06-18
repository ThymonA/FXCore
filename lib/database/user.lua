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

User = class('User')

-- Set default values
User:set {
    Users = {}
}

--
-- Returns a list of users
-- @return array List of users
function User:GetAll()
    return User.Users or {}
end

--
-- Load user by id or identifier
-- @search int|string Search by id or identifier
-- @returns object User object
--
function User:Load(search)
    local _type = type(search)
    local userResult = nil

    if (_type == 'string') then
        userResult = MySQL:FetchFirst('SELECT * FROM `users` WHERE `identifier` = @identifier', {
            ['@identifier'] = string.trim(search)
        })
    elseif (_type == 'number') then
        userResult = MySQL:FetchFirst('SELECT * FROM `users` WHERE `id` = @id', {
            ['@id'] = search
        })
    end

    if (userResult == nil) then
        return nil
    end

    local user = class('user')

    user:set {
        id = userResult.id,
        identifier = userResult.identifier,
        name = userResult.name,
        group = userResult.group,
        position = userResult.position,
        isDead = userResult.isDead,
        job = Job:Load(userResult.job),
        job2 = Job:Load(userResult.job2)
    }

    return user
end