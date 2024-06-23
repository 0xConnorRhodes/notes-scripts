local options = {
    ['new task'] = 'new-task.lua',
    ['done task'] = 'done-task.lua'
}

local notesScriptsDir = os.getenv('HOME')..'/code/notes-scripts/'

local function presentChoices(options)
    -- generate multiline string of the keys in the options table
    -- pipe that multiline string into fzf for selection
    local choices = {}
    for key, _ in pairs(options) do
       table.insert(choices, key)
    end
    local choices_string = table.concat(choices, '\n')

    local handle = io.popen('echo "'..choices_string..'" | fzf')
    local choice = handle:read("*a")
    handle:close()

    return choice:gsub("\n$", "") -- remove trailing newline
end

local choice = presentChoices(options)

os.execute('lua '..notesScriptsDir..options[choice])