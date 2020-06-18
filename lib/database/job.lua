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

Job = class()

-- Set default values
Job:set {
    Jobs = {}
}

--
-- Returns a list of jobs
-- @return array List of jobs
function Job:GetAll()
    return Job.Jobs or {}
end

--
-- Load job by name or id
-- @search int|string Search by id or name
-- @returns object Job object
--
function Job:Load(search)
    local _type = type(search)
    local jobResults = {}

    if (_type == 'string') then
        jobResults = MySQL:FetchAll('SELECT `j`.`id` AS `job_id`, `j`.`label` AS `job_label`, `j`.`name` AS `job_name`, `jg`.`id` AS `grade_id`, `jg`.`grade` AS `grade_grade`, `jg`.`name` AS `grade_name`, `jg`.`label` AS `grade_label` FROM `job_grades` AS `jg` LEFT JOIN `jobs` AS `j` ON `jg`.`job` = `j`.`id` WHERE `j`.`name` = @name ORDER BY `jg`.`grade`', {
            ['@name'] = string.trim(search)
        })
    elseif (_type == 'number') then
        jobResults = MySQL:FetchAll('SELECT `j`.`id` AS `job_id`, `j`.`label` AS `job_label`, `j`.`name` AS `job_name`, `jg`.`id` AS `grade_id`, `jg`.`grade` AS `grade_grade`, `jg`.`name` AS `grade_name`, `jg`.`label` AS `grade_label` FROM `job_grades` AS `jg` LEFT JOIN `jobs` AS `j` ON `jg`.`job` = `j`.`id` WHERE `j`.`id` = @id ORDER BY `jg`.`grade`', {
            ['@id'] = search
        })
    end

    if (jobResults == nil or #jobResults <= 0) then
        return nil
    end

    local job = class()

    job:set {
        grades = {}
    }

    for _, jobResult in pairs(jobResults or {}) do
        job:set {
            id = jobResult.job_id,
            name = jobResult.job_name,
            label = jobResult.job_label
        }

        local grade = tostring(jobResult.grade_grade)

        job.grades[grade] = class()
        job.grades[grade]:set {
            id = jobResult.grade_id,
            grade = jobResult.grade_grade,
            name = jobResult.grade_name,
            label = jobResult.grade_label
        }
    end

    return job
end