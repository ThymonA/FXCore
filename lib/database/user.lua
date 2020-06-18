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
        userResult = MySQL:FetchFirst('SELECT * FROM `users` WHERE `identifier` = @identifier LIMIT 1', {
            ['@identifier'] = string.trim(search)
        })
    elseif (_type == 'number') then
        userResult = MySQL:FetchFirst('SELECT * FROM `users` WHERE `id` = @id LIMIT 1', {
            ['@id'] = search
        })
    end

    if (userResult == nil) then
        return User:Default()
    end

    local user = class('user')

    user:set {
        id = userResult.id,
        identifier = userResult.identifier,
        name = userResult.name,
        group = userResult.group,
        position = json.decode(userResult.position),
        isDead = userResult.isDead,
        grade = Job:LoadGrade(userResult.job),
        grade2 = Job:LoadGrade(userResult.job2)
    }

    function user:update()
        return MySQL:Execute('UPDATE `users` SET `name` = @name, `grade` = @grade, `grade2` = @grade2, `group` = @group, `position` = @position, `isDead` = @isDead WHERE `id` = @id', {
            ['@name'] = self.name,
            ['@grade'] = self.grade.id,
            ['@grade2'] = self.grade.id,
            ['@group'] = self.group,
            ['@position'] = json.encode(self.position),
            ['@isDead'] = self.isDead,
            ['@id'] = self.id
        })
    end

    return user
end

--
-- Default User Object
-- @return object User object
--
function User:Default()
    local user = class('user')

    user:set {
        id = 0,
        identifier = 'default',
        name = 'Default',
        group = 'user',
        position = { x = 0.0, y = 0.0, z = 0.0, h = 0.0 },
        isDead = false,
        grade = Job:DefaultGrade(),
        grade2 = Job:DefaultGrade()
    }

    function user:update() return end

    return user
end