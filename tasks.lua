-- string to order options in fzf
local options_str = [[new task
done task
drop task
undone task
undrop task]]

-- table to map options to filenames, arguments
local options_tbl = {
    ['new task'] = 'new-task.lua',
    ['done task'] = 'modify-task.lua done',
    ['drop task'] = 'modify-task.lua drop',
    ['undone task'] = 'modify-task.lua undone',
    ['undrop task'] = 'modify-task.lua undrop'
}

local notesScriptsDir = os.getenv('HOME')..'/code/notes-scripts/'

local function presentChoices(choices_string)
    local handle = io.popen('echo "'..choices_string..'" | fzf')
    local choice = handle:read("*a")
    handle:close()

    return choice:gsub("\n$", "") -- remove trailing newline
end

local choice = presentChoices(options_str)

os.execute('lua '..notesScriptsDir..options_tbl[choice])