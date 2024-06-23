-- string to order options in fzf
local options_str = [[new task
done task]]

-- table to map options to filenames, arguments
local options_tbl = {
    ['done task'] = 'done-task.lua',
    ['new task'] = 'new-task.lua'
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