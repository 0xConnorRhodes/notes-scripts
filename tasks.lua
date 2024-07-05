-- string to order options in fzf
local options_str = [[new task
done task
drop task
hold task
review tasks
undone task
undrop task
unhold task]]

-- table to map options to filenames, arguments
local options_tbl = {
    ['new task'] = 'new-task.lua',
    ['done task'] = 'modify-task.lua done',
    ['drop task'] = 'modify-task.lua drop',
    ['hold task'] = 'modify-task.lua hold',
    ['review tasks'] = 'reivew-tasks.lua',
    ['undone task'] = 'modify-task.lua undone',
    ['undrop task'] = 'modify-task.lua undrop',
    ['unhold task'] = 'modify-task.lua unhold'
}

local notesScriptsDir = os.getenv('HOME')..'/code/notes-scripts/'

local choice = ''
if arg[1] then
    local handle = io.popen('echo "'..options_str..'" | fzf --query '..arg[1])
    choice = handle:read("*a"):gsub("\n$", "") -- remove trailing newline
    handle:close()
else
    local handle = io.popen('echo "'..options_str..'" | fzf')
    -- choice = handle:read("*a")
    choice = handle:read("*a"):gsub("\n$", "") -- remove trailing newline
    handle:close()
end

os.execute('lua '..notesScriptsDir..options_tbl[choice])
