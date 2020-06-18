 --
-- Initialize `jobs` table in database
--
Database:InitializeTable('jobs', {
    id =    { primary = true,   unique = false, required = false, type = 'INT',     length = nil,   default = nil,  foreign_key = nil, extra = 'AUTO_INCREMENT' },
    name =  { primary = false,  unique = true,  required = true, type = 'VARCHAR',  length = 40,    default = nil,  foreign_key = nil, extra = nil },
    label = { primary = false,  unique = false, required = true, type = 'VARCHAR',  length = 40,    default = nil,  foreign_key = nil, extra = nil },
}, {
    { id = 1, name = 'unemployed', label = 'Unemployed' }
})

--
-- Initialize `job_grades` table in database
--
Database:InitializeTable('job_grades', {
    id =    { primary = true,   unique = false, required = true, type = 'INT',      length = nil,   default = nil,          foreign_key = nil, extra = 'AUTO_INCREMENT' },
    job =   { primary = false,  unique = true,  required = true, type = 'INT',      length = nil,   default = nil,          foreign_key = {
        table = 'jobs', column = 'id'
    }, extra = nil },
    grade = { primary = false,  unique = true,  required = true, type = 'INT',      length = nil,   default = 0,            foreign_key = nil, extra = nil },
    name =  { primary = false,  unique = false, required = true, type = 'VARCHAR',  length = 40,    default = nil,          foreign_key = nil, extra = nil },
    label = { primary = false,  unique = false, required = true, type = 'VARCHAR',  length = 40,    default = nil,          foreign_key = nil, extra = nil },
}, {
    { id = 1, job = 1, grade = 0, name = 'unemployed', label = 'Unemployed' }
})

--
-- Initialize `users` table in database
--
Database:InitializeTable('users', {
    ['id'] =            { primary = true,   unique = false, required = true,    type = 'INT',       length = nil,   default = nil,                                      foreign_key = nil, extra = 'AUTO_INCREMENT' },
    ['identifier'] =    { primary = false,  unique = true,  required = true,    type = 'VARCHAR',   length = 40,    default = nil,                                      foreign_key = nil, extra = nil },
    ['name'] =          { primary = false,  unique = false, required = false,   type = 'LONGTEXT',  length = nil,   default = 'NONE',                                   foreign_key = nil, extra = nil },
    ['group'] =         { primary = false,  unique = false, required = true,    type = 'VARCHAR',   length = 40,    default = 'USER',                                   foreign_key = nil, extra = nil },
    ['job'] =           { primary = false,  unique = false, required = true,    type = 'INT',       length = nil,   default = 'unemployed',                             foreign_key = {
        table = 'job_grades', column = 'id'
    }, extra = nil },
    ['job2'] =          { primary = false,  unique = false, required = true,    type = 'INT',       length = nil,   default = 'unemployed',                             foreign_key = {
        table = 'job_grades', column = 'id'
    }, extra = nil },
    ['position'] =      { primary = false,  unique = false, required = true,    type = 'LONGTEXT',  length = nil,   default = '{"x":0.0,"y":0.0,"z":0.0,"h":0.0}',      foreign_key = nil, extra = nil },
    ['isDead'] =        { primary = false,  unique = false, required = true,    type = 'INT',       length = 1,     default = 0,                                        foreign_key = nil, extra = nil }
})